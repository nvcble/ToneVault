import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pedalboard_dao.dart';
import '../../../core/errors/app_failure.dart';
import 'pedalboard_draft.dart';
import 'pedalboard_validator.dart';

/// Rig operations: naming a pedalboard, describing it, and removing one.
///
/// Owns what the database cannot express on its own: input validation,
/// createdAt/updatedAt bookkeeping, and turning driver exceptions into
/// [AppFailure]s whose message can be shown to the user as-is.
///
/// None of this is pedal history. A change log entry belongs to a pedal and
/// ChangeType names no rig event, so renaming a rig records nothing; what
/// happened to a pedal is recorded when the pedal itself changes.
///
/// Deleting a rig is allowed, unlike deleting a pedal with anything recorded
/// about it: a rig is a grouping of pedals the user still owns, so removing it
/// takes nothing away from them. Once snapshots have been taken of it, though,
/// deleting the rig would take those with it, so it is refused until they go.
class PedalboardRepository {
  PedalboardRepository(this._dao, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final PedalboardDao _dao;

  /// Injectable so tests can assert on exact timestamps.
  final DateTime Function() _clock;

  Stream<List<Pedalboard>> watchPedalboards() => _dao.watchPedalboards();

  Stream<Pedalboard?> watchPedalboard(int pedalboardId) =>
      _dao.watchPedalboard(pedalboardId);

  Future<int> createPedalboard(PedalboardDraft draft) async {
    final pedalboard = _validated(draft);
    await _ensureNameIsFree(pedalboard.name);
    final now = _clock();

    return _guard(
      () => _dao.insertPedalboard(
        PedalboardsCompanion.insert(
          name: pedalboard.name,
          description: Value(pedalboard.description),
          createdAt: now,
          updatedAt: now,
        ),
      ),
      'Could not save this rig.',
    );
  }

  Future<void> updatePedalboard(int pedalboardId, PedalboardDraft draft) async {
    final pedalboard = _validated(draft);

    final existing = await _dao.findPedalboard(pedalboardId);
    if (existing == null) {
      throw const AppFailure('That rig no longer exists.');
    }
    await _ensureNameIsFree(pedalboard.name, exceptPedalboardId: pedalboardId);

    final matched = await _guard(
      () => _dao.updatePedalboard(
        pedalboardId,
        PedalboardsCompanion(
          name: Value(pedalboard.name),
          description: Value(pedalboard.description),
          updatedAt: Value(_clock()),
        ),
      ),
      'Could not update this rig.',
    );

    if (!matched) {
      throw const AppFailure('That rig no longer exists.');
    }
  }

  Future<void> deletePedalboard(int pedalboardId) async {
    // `rig_snapshots` references the rig with RESTRICT, so without this the
    // delete would surface as a constraint failure with nothing readable in it.
    final snapshots = await _dao.countSnapshots(pedalboardId);
    if (snapshots > 0) {
      throw AppFailure(
        'This rig has $snapshots '
        '${snapshots == 1 ? 'snapshot' : 'snapshots'} of how it was set up. '
        'Delete those first if you no longer want the rig.',
      );
    }

    final deleted = await _guard(
      () => _dao.deletePedalboard(pedalboardId),
      'Could not delete this rig.',
    );

    if (!deleted) {
      throw const AppFailure('That rig no longer exists.');
    }
  }

  PedalboardDraft _validated(PedalboardDraft draft) {
    final normalized = draft.normalized();
    final problem = PedalboardValidator.draft(normalized);
    if (problem != null) {
      throw AppFailure(problem);
    }
    return normalized;
  }

  /// The unique key on `pedalboards.name` would catch an exact repeat, but only
  /// exactly: "Home" and "home" are equally ambiguous to choose between in a
  /// list, and a checked name gives the user the name in the message.
  Future<void> _ensureNameIsFree(String name, {int? exceptPedalboardId}) async {
    final clash = await _dao.findByName(name);

    if (clash != null && clash.id != exceptPedalboardId) {
      throw AppFailure('A rig called "${clash.name}" already exists.');
    }
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
