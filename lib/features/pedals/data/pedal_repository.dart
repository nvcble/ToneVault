import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pedal_dao.dart';
import '../../../core/errors/app_failure.dart';
import '../../history/data/change_entry.dart';
import '../../history/data/change_log_repository.dart';
import 'pedal_draft.dart';
import 'pedal_validator.dart';

/// Pedal inventory operations.
///
/// Owns what the database cannot express on its own: input validation,
/// createdAt/updatedAt bookkeeping, and turning driver exceptions into
/// [AppFailure]s whose message can be shown to the user as-is.
///
/// Of everything an edit can change about a pedal, only its status is history:
/// a pedal moving from the board to the backup bag is a rig decision, while a
/// corrected brand name is a typo being fixed.
class PedalRepository {
  PedalRepository(this._dao, this._changeLog, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final PedalDao _dao;
  final ChangeLogRepository _changeLog;

  /// Injectable so tests can assert on exact timestamps.
  final DateTime Function() _clock;

  Stream<List<Pedal>> watchPedals() => _dao.watchPedals();

  Stream<Pedal?> watchPedal(int pedalId) => _dao.watchPedal(pedalId);

  Future<int> createPedal(PedalDraft draft) async {
    final pedal = _validated(draft);
    final now = _clock();

    return _guard(
      () => _dao.insertPedal(
        PedalsCompanion.insert(
          name: pedal.name,
          brand: Value(pedal.brand),
          type: pedal.type,
          category: pedal.category,
          status: Value(pedal.status),
          photoPath: Value(pedal.photoPath),
          purchaseDate: Value(pedal.purchaseDate),
          notes: Value(pedal.notes),
          createdAt: now,
          updatedAt: now,
        ),
      ),
      'Could not save this pedal.',
    );
  }

  Future<void> updatePedal(int pedalId, PedalDraft draft) async {
    final pedal = _validated(draft);

    // Read first: the status the pedal is leaving is not in the draft, and it is
    // half of what the history entry says.
    final existing = await _dao.findPedal(pedalId);
    if (existing == null) {
      throw const AppFailure('That pedal no longer exists.');
    }

    await _guard(
      () => _dao.transaction(() async {
        await _dao.updatePedal(
          pedalId,
          PedalsCompanion(
            name: Value(pedal.name),
            brand: Value(pedal.brand),
            type: Value(pedal.type),
            category: Value(pedal.category),
            status: Value(pedal.status),
            photoPath: Value(pedal.photoPath),
            purchaseDate: Value(pedal.purchaseDate),
            notes: Value(pedal.notes),
            updatedAt: Value(_clock()),
          ),
        );

        if (existing.status != pedal.status) {
          await _changeLog.record(
            ChangeEntry.pedalStatusChanged(
              pedal: existing.copyWith(status: pedal.status),
              previousStatus: existing.status,
            ),
          );
        }
      }),
      'Could not update this pedal.',
    );
  }

  Future<void> deletePedal(int pedalId) async {
    bool deleted;
    try {
      deleted = await _dao.deletePedal(pedalId);
    } catch (error) {
      // The only constraint a pedal delete can violate is a foreign key:
      // configurations, change logs, replacement records, rig slots and snapshot
      // entries all reference pedals with ON DELETE RESTRICT. Retiring is the
      // intended path.
      throw AppFailure(
        'This pedal is on a rig, or has configurations, history or snapshots '
        'attached. Take it off the rig, or change its status rather than '
        'deleting it.',
        cause: error,
      );
    }

    if (!deleted) {
      throw const AppFailure('That pedal no longer exists.');
    }
  }

  PedalDraft _validated(PedalDraft draft) {
    final normalized = draft.normalized();
    final problem = PedalValidator.draft(normalized, now: _clock());
    if (problem != null) {
      throw AppFailure(problem);
    }
    return normalized;
  }

  Future<T> _guard<T>(Future<T> Function() operation, String message) async {
    try {
      return await operation();
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw AppFailure(message, cause: error);
    }
  }
}
