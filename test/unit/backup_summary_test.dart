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

  RigSnapshot snapshot(int id) =>
      RigSnapshot(id: id, pedalboardId: 1, name: 'Day $id', capturedAt: moment);

  VaultRows vaultOf({int pedals = 0, int rigs = 0, int snapshots = 0}) => (
    pedals: [for (var id = 1; id <= pedals; id++) pedal(id)],
    controls: const [],
    configurations: const [],
    configurationValues: const [],
    changeLogs: const [],
    replacements: const [],
    pedalboards: [for (var id = 1; id <= rigs; id++) rig(id)],
    slots: const [],
    snapshots: [for (var id = 1; id <= snapshots; id++) snapshot(id)],
    snapshotEntries: const [],
    snapshotValues: const [],
  );

  VaultBackup backupOf(VaultRows rows) => (
    formatVersion: backupFormatVersion,
    schemaVersion: currentSchemaVersion,
    // A local time, since the user reads it on their own clock.
    exportedAt: DateTime(2026, 8, 20, 7, 15),
    rows: rows,
  );

  test('counts what a person would count', () async {
    final tally = tallyVault(vaultOf(pedals: 12, rigs: 3, snapshots: 5));

    expect(tally, (pedals: 12, rigs: 3, snapshots: 5));
  });

  test('describes a backup by its date and what is in it', () async {
    final described = describeBackup(
      backupOf(vaultOf(pedals: 12, rigs: 3, snapshots: 5)),
    );

    expect(
      described,
      'Taken 2026-08-20 07:15, with 12 pedals, 3 rigs and 5 snapshots in it.',
    );
  });

  test('counts of one read as one', () async {
    final described = describeBackup(
      backupOf(vaultOf(pedals: 1, rigs: 1, snapshots: 1)),
    );

    expect(
      described,
      'Taken 2026-08-20 07:15, with 1 pedal, 1 rig and 1 snapshot in it.',
    );
  });

  test('a backup of an empty vault says so in words', () async {
    // "0 pedals" reads like a fault; an empty backup is a real thing to have.
    expect(
      describeBackup(backupOf(vaultOf())),
      'Taken 2026-08-20 07:15, with no pedals, no rigs and no snapshots in it.',
    );
  });

  test('reports what a finished restore put in place', () async {
    expect(
      describeRestored(vaultOf(pedals: 12, rigs: 1)),
      'Restored 12 pedals, 1 rig and no snapshots.',
    );
  });

  test('names a backup file for the day it was taken', () async {
    expect(
      backupFileName(DateTime(2026, 8, 20, 7, 15)),
      'tonevault-backup-2026-08-20.json',
    );
  });
}
