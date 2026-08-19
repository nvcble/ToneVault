import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pedal_dao.dart';
import '../../../core/errors/app_failure.dart';
import 'pedal_draft.dart';
import 'pedal_validator.dart';

/// Pedal inventory operations.
///
/// Owns what the database cannot express on its own: input validation,
/// createdAt/updatedAt bookkeeping, and turning driver exceptions into
/// [AppFailure]s whose message can be shown to the user as-is.
class PedalRepository {
  PedalRepository(this._dao, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final PedalDao _dao;

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

    final matched = await _guard(
      () => _dao.updatePedal(
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
      ),
      'Could not update this pedal.',
    );

    if (!matched) {
      throw const AppFailure('That pedal no longer exists.');
    }
  }

  Future<void> deletePedal(int pedalId) async {
    bool deleted;
    try {
      deleted = await _dao.deletePedal(pedalId);
    } catch (error) {
      // The only constraint a pedal delete can violate is a foreign key:
      // configurations, change logs and replacement records all reference
      // pedals with ON DELETE RESTRICT. Retiring is the intended path.
      throw AppFailure(
        'This pedal has configurations or history attached. Change its status '
        'instead of deleting it.',
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
