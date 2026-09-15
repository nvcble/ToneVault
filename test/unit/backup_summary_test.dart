import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/backup_dao.dart';
import 'package:tone_vault/core/database/migrations.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/backup/data/backup_document.dart';
import 'package:tone_vault/features/backup/data/backup_summary.dart';

/// What the app says a backup holds, before it replaces everything with it.
void main() {
  final moment = DateTime.utc(2026, 8, 19, 12);

  Pedal pedal(int id) => Pedal(
    id: id,
    name: 'Pedal $id',
    type: PedalType.analog,
    category: PedalCategory.overdrive,
    status: PedalStatus.active,
    createdAt: moment,
    updatedAt: moment,
  );

  Pedalboard rig(int id) =>
      Pedalboard(id: id, name: 'Rig $id', createdAt: moment, updatedAt: moment);

  VaultRows vaultOf({int pedals = 0, int rigs = 0}) => (
    pedals: [for (var id = 1; id <= pedals; id++) pedal(id)],
    controls: const [],
    configurations: const [],
    configurationValues: const [],
    patches: const [],
    scenes: const [],
    scenePedals: const [],
    sceneValues: const [],
    changeLogs: const [],
    replacements: const [],
    pedalboards: [for (var id = 1; id <= rigs; id++) rig(id)],
    signalBlocks: const [],
    signalConnections: const [],
    signalEndpoints: const [],
    snapshots: const [],
    snapshotEntries: const [],
    snapshotValues: const [],
    academyCourses: const [],
    academyModules: const [],
    academyLessons: const [],
    academyExercises: const [],
    academyProgress: const [],
    academyExerciseProgress: const [],
    academyPracticeSessions: const [],
    academyBookmarks: const [],
    midiParameterOverrides: const [],
    midiPatchSelectionSettings: const [],
    midiDeviceLinks: const [],
    midiPatchProgramNumbers: const [],
    midiSceneNumbers: const [],
    midiPatchFavorites: const [],
    midiPatchRecents: const [],
  );

  VaultBackup backupOf(VaultRows rows, {int? schemaVersion}) => (
    formatVersion: backupFormatVersion,
    schemaVersion: schemaVersion ?? currentSchemaVersion,
    // A local time, since the user reads it on their own clock.
    exportedAt: DateTime(2026, 8, 20, 7, 15),
    rows: rows,
  );

  test('counts what a person would count', () async {
    final tally = tallyVault(vaultOf(pedals: 12));

    expect(tally, (pedals: 12));
  });

  test('leaves the boards of the old rigs feature out of the count', () async {
    // The file still carries them and a restore still puts them back, but there
    // is nowhere left in the app to go and look at them, so a number here would
    // only raise a question the user cannot follow up on.
    expect(
      describeBackup(backupOf(vaultOf(pedals: 12, rigs: 3))),
      isNot(contains('rig')),
    );
  });

  test('describes a backup by its date and what is in it', () async {
    final described = describeBackup(backupOf(vaultOf(pedals: 12)));

    expect(described, 'Taken 2026-08-20 07:15, with 12 pedals in it.');
  });

  test('counts of one read as one', () async {
    final described = describeBackup(backupOf(vaultOf(pedals: 1)));

    expect(described, 'Taken 2026-08-20 07:15, with 1 pedal in it.');
  });

  test('a backup of an empty vault says so in words', () async {
    // "0 pedals" reads like a fault; an empty backup is a real thing to have.
    expect(
      describeBackup(backupOf(vaultOf())),
      'Taken 2026-08-20 07:15, with no pedals in it.',
    );
  });

  test('says when a file was made by an older version', () async {
    final described = describeBackup(
      backupOf(vaultOf(pedals: 12), schemaVersion: currentSchemaVersion - 1),
    );

    // It will restore, but the parts of the app that came after it come back
    // empty, and finding that out after the vault is replaced is too late.
    expect(
      described,
      'Taken 2026-08-20 07:15, with 12 pedals in it. '
      'It was made by an older version of ToneVault, so parts of the app added '
      'since then come back empty.',
    );
  });

  test('reports what a finished restore put in place', () async {
    expect(describeRestored(vaultOf(pedals: 12)), 'Restored 12 pedals.');
  });

  test('names a backup file for the day it was taken', () async {
    expect(
      backupFileName(DateTime(2026, 8, 20, 7, 15)),
      'tonevault-backup-2026-08-20.json',
    );
  });
}
