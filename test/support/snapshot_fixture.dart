import 'package:drift/drift.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/control_type.dart';

/// A rig recorded on one date, with a pedal in it and a reading off that pedal.
///
/// Kept apart from the rest of [fillVault] because there is no repository left to
/// write it: the rigs feature is gone, and these rows only reach a fixture the way
/// they now only reach a backup - straight off the table. What they are here for is
/// to make a restore that quietly dropped them fail a test.
Future<void> fillSnapshot(
  AppDatabase database, {
  required int pedalboardId,
  required int pedalId,
  required DateTime moment,
}) async {
  final snapshotId = await database
      .into(database.rigSnapshots)
      .insert(
        RigSnapshotsCompanion.insert(
          pedalboardId: pedalboardId,
          name: 'Easter 2026',
          notes: const Value('Both services'),
          capturedAt: moment,
          endpointSummary: const Value('Out to the desk on stage left'),
        ),
      );

  final entryId = await database
      .into(database.rigSnapshotEntries)
      .insert(
        RigSnapshotEntriesCompanion.insert(
          snapshotId: snapshotId,
          pedalId: pedalId,
          position: 0,
          configurationName: const Value('Worship Lead'),
        ),
      );

  await database
      .into(database.rigSnapshotValues)
      .insert(
        RigSnapshotValuesCompanion.insert(
          entryId: entryId,
          controlName: 'Gain',
          controlPedalName: const Value('Caline PureSky'),
          controlType: ControlType.clock,
          value: 0.7,
          displayOrder: 0,
        ),
      );
}
