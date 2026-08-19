import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/configuration_dao.dart';
import '../../../core/database/daos/pedal_control_dao.dart';
import '../../../core/database/daos/pedalboard_dao.dart';
import '../../../core/database/daos/rig_snapshot_dao.dart';
import '../../../core/errors/app_failure.dart';
import 'snapshot_draft.dart';
import 'snapshot_readings.dart';
import 'snapshot_validator.dart';

/// Snapshots of a rig: taking one, correcting what it is called, removing one.
///
/// Capture reads the rig as it stands and copies what it finds. Nothing in a
/// stored snapshot points at a configuration or a control, so re-tweaking a
/// pedal afterwards cannot rewrite what was played - which is the whole reason
/// for taking one. The pedal itself stays a reference, so a snapshot can still
/// be read through to the pedal it names.
///
/// A captured snapshot is not editable beyond its name and notes. There is no
/// "adjust what I played at Easter": that would make the record a guess.
///
/// None of this is pedal history. A snapshot is a record of a rig on a date, and
/// ChangeType names no rig event, so capturing one records nothing against the
/// pedals on it.
class RigSnapshotRepository {
  RigSnapshotRepository(
    this._dao,
    this._pedalboardDao,
    this._configurationDao,
    this._controlDao, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final RigSnapshotDao _dao;
  final PedalboardDao _pedalboardDao;
  final ConfigurationDao _configurationDao;
  final PedalControlDao _controlDao;

  /// Injectable so tests can assert on exact timestamps.
  final DateTime Function() _clock;

  Stream<List<RigSnapshot>> watchSnapshots(int pedalboardId) =>
      _dao.watchSnapshots(pedalboardId);

  Stream<RigSnapshot?> watchSnapshot(int snapshotId) =>
      _dao.watchSnapshot(snapshotId);

  Stream<List<SnapshotEntry>> watchEntries(int snapshotId) =>
      _dao.watchEntries(snapshotId);

  /// Records the rig as it stands and returns the new snapshot's id.
  ///
  /// [configurationChoices] maps a pedal on the rig to the configuration it was
  /// set to. A pedal left out of it is captured as being on the board with
  /// nothing dialled in, which is the honest answer for a wah, and for a pedal
  /// whose settings the user simply did not record.
  Future<int> captureSnapshot(
    int pedalboardId,
    SnapshotDraft draft, {
    Map<int, int> configurationChoices = const {},
  }) async {
    final snapshot = _validated(draft);

    final rig = await _pedalboardDao.findPedalboard(pedalboardId);
    if (rig == null) {
      throw const AppFailure('That rig no longer exists.');
    }

    final slots = await _pedalboardDao.slotsOf(pedalboardId);
    if (slots.isEmpty) {
      throw AppFailure(
        'There is nothing on ${rig.name} to record yet. Add some pedals to the '
        'rig first.',
      );
    }

    final chosen = await _chosenConfigurations(slots, configurationChoices);

    return _guard(
      () => _dao.transaction(() async {
        final snapshotId = await _dao.insertSnapshot(
          RigSnapshotsCompanion.insert(
            pedalboardId: pedalboardId,
            name: snapshot.name,
            notes: Value(snapshot.notes),
            capturedAt: _clock(),
          ),
        );

        // The index, not the slot's own position: a snapshot's positions are
        // 0, 1, 2 by construction, whatever the chain happens to hold.
        for (final (position, slot) in slots.indexed) {
          await _captureEntry(
            snapshotId: snapshotId,
            pedalId: slot.pedalId,
            position: position,
            configuration: chosen[slot.pedalId],
          );
        }

        return snapshotId;
      }),
      'Could not save this snapshot.',
    );
  }

  /// Corrects what a snapshot is called, or what it says about the day.
  ///
  /// [RigSnapshots.capturedAt] and every reading are left alone: what the rig
  /// was is not up for editing.
  Future<void> updateSnapshot(int snapshotId, SnapshotDraft draft) async {
    final snapshot = _validated(draft);

    final matched = await _guard(
      () => _dao.updateSnapshot(
        snapshotId,
        RigSnapshotsCompanion(
          name: Value(snapshot.name),
          notes: Value(snapshot.notes),
        ),
      ),
      'Could not rename this snapshot.',
    );

    if (!matched) {
      throw const AppFailure('That snapshot no longer exists.');
    }
  }

  /// Removes a snapshot and the readings under it.
  ///
  /// The pedals it named are untouched, and so is the rig: only the record of
  /// that one day goes.
  Future<void> deleteSnapshot(int snapshotId) async {
    final deleted = await _guard(
      () => _dao.deleteSnapshot(snapshotId),
      'Could not delete this snapshot.',
    );

    if (!deleted) {
      throw const AppFailure('That snapshot no longer exists.');
    }
  }

  /// Stores one pedal's place in the chain, with the readings it was set to.
  ///
  /// The configuration's name is copied as text rather than referenced, so
  /// renaming or deleting it later cannot rewrite what the snapshot says.
  Future<void> _captureEntry({
    required int snapshotId,
    required int pedalId,
    required int position,
    required Configuration? configuration,
  }) async {
    final entryId = await _dao.insertEntry(
      RigSnapshotEntriesCompanion.insert(
        snapshotId: snapshotId,
        pedalId: pedalId,
        position: position,
        configurationName: Value(configuration?.name),
      ),
    );

    if (configuration == null) {
      return;
    }

    await _dao.insertValues(
      frozenReadings(
        entryId: entryId,
        controls: await _controlDao.controlsOf(pedalId),
        values: await _configurationDao.valuesOf(configuration.id),
      ),
    );
  }

  /// The configuration chosen for each pedal, checked against the rig as it
  /// stands.
  ///
  /// A choice made on screen before someone edited the rig or the pedal would
  /// otherwise be captured as fact, or fail as a constraint violation with
  /// nothing readable in it.
  Future<Map<int, Configuration>> _chosenConfigurations(
    List<PedalboardSlot> slots,
    Map<int, int> choices,
  ) async {
    final onTheRig = {for (final slot in slots) slot.pedalId};
    final chosen = <int, Configuration>{};

    for (final choice in choices.entries) {
      if (!onTheRig.contains(choice.key)) {
        throw const AppFailure(
          'One of those pedals is no longer on this rig. Reopen the rig and try '
          'again.',
        );
      }

      final configuration = await _configurationDao.findConfiguration(
        choice.value,
      );
      if (configuration == null || configuration.pedalId != choice.key) {
        throw const AppFailure(
          'One of those configurations is no longer on its pedal. Reopen the '
          'rig and try again.',
        );
      }

      chosen[choice.key] = configuration;
    }

    return chosen;
  }

  SnapshotDraft _validated(SnapshotDraft draft) {
    final normalized = draft.normalized();
    final problem = SnapshotValidator.draft(normalized);
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
