import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pedalboard_dao.dart';
import '../../../core/database/daos/rig_snapshot_dao.dart';
import '../../../core/database/daos/signal_chain_dao.dart';
import '../../../core/errors/app_failure.dart';
import '../../pedalboards/data/chain_endpoints.dart';
import '../../pedalboards/data/chain_order.dart';
import '../../pedalboards/data/endpoint_summary.dart';
import 'snapshot_draft.dart';
import 'snapshot_readings.dart';
import 'snapshot_settings.dart';
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
    this._chainDao,
    this._settings, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final RigSnapshotDao _dao;
  final PedalboardDao _pedalboardDao;
  final SignalChainDao _chainDao;

  /// Where the choices made on screen are turned into readings, and checked
  /// against the database as it stands.
  final SnapshotSettings _settings;

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
  /// set to, and [sceneChoices] maps a multi-effects unit to the scene it was on -
  /// a unit has no configurations of its own, so a scene is what says where it
  /// stood. A pedal in neither is captured as being on the board with nothing
  /// dialled in, which is the honest answer for a wah, and for a pedal whose
  /// settings the user simply did not record.
  Future<int> captureSnapshot(
    int pedalboardId,
    SnapshotDraft draft, {
    Map<int, int> configurationChoices = const {},
    Map<int, int> sceneChoices = const {},
  }) async {
    final snapshot = _validated(draft);

    final rig = await _pedalboardDao.findPedalboard(pedalboardId);
    if (rig == null) {
      throw const AppFailure('That rig no longer exists.');
    }

    // The chain as the screen reads it, not as the rows happen to sit: a rig
    // wired with cables, or out through an amplifier's loop and back, runs in an
    // order position alone does not say, and a snapshot filed in the wrong order
    // is a record of a rig nobody played.
    final rows = await _chainDao.chainRows(pedalboardId);
    final chain = chainInSignalOrder(rows);

    // Only the blocks with a pedal in them: an empty block is a place the rig
    // has kept for something, and a snapshot records what was played, not what
    // is still to be bought.
    final filled = [
      for (final entry in chain)
        if (entry.pedal != null) entry.block,
    ];
    if (filled.isEmpty) {
      throw AppFailure(
        'There is nothing on ${rig.name} to record yet. Add some pedals to the '
        'rig first.',
      );
    }

    final chosen = await _settings.resolve(
      onTheRig: {for (final block in filled) block.pedalId!},
      configurationChoices: configurationChoices,
      sceneChoices: sceneChoices,
    );

    return _guard(
      () => _dao.transaction(() async {
        final snapshotId = await _dao.insertSnapshot(
          RigSnapshotsCompanion.insert(
            pedalboardId: pedalboardId,
            name: snapshot.name,
            notes: Value(snapshot.notes),
            capturedAt: _clock(),
            endpointSummary: Value(_edgesOf(chain, rows.endpoints)),
          ),
        );

        // The index, not the block's own position: a snapshot's positions are
        // 0, 1, 2 by construction, whatever gaps the chain happens to hold.
        for (final (position, block) in filled.indexed) {
          await _captureEntry(
            snapshotId: snapshotId,
            block: block,
            position: position,
            setting: chosen[block.pedalId],
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
  /// The setting's name is copied as text rather than referenced, so renaming or
  /// deleting the configuration or scene later cannot rewrite what the snapshot
  /// says. Whether the block was switched on is copied for the same reason, and
  /// because a pedal sat there bypassed is part of how the rig was set up.
  Future<void> _captureEntry({
    required int snapshotId,
    required SignalBlock block,
    required int position,
    required SnapshotSetting? setting,
  }) async {
    final entryId = await _dao.insertEntry(
      RigSnapshotEntriesCompanion.insert(
        snapshotId: snapshotId,
        pedalId: block.pedalId!,
        position: position,
        configurationName: Value(setting?.label),
        isEnabled: Value(block.isEnabled),
      ),
    );

    if (setting == null) {
      return;
    }

    await _dao.insertValues(
      frozenReadings(
        entryId: entryId,
        controls: setting.controls,
        positions: setting.positions,
      ),
    );
  }

  /// Where the rig reached at either end, in the words the chain itself read.
  ///
  /// Text rather than a reference to the blocks that said it, for the reason a
  /// configuration's name is copied: those blocks can be rewired the next morning,
  /// and a record that changed with them would not be a record. Null on a rig that
  /// never said, which is most rigs and no kind of gap.
  String? _edgesOf(List<ChainBlock> chain, List<SignalEndpoint> endpoints) {
    final lines = endpointSummaries(
      chain: chain,
      endpoints: ChainEndpoints(endpoints),
    );
    if (lines.isEmpty) return null;

    // In signal order, so a rig that says both ends reads from the guitar out.
    return [for (final entry in chain) ?lines[entry.block.id]].join('\n');
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
