import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/backup_dao.dart';
import '../support/vault_fixture.dart';

/// Reading the whole vault out and writing a whole vault back in: every table
/// carried, ids kept, and nothing half replaced.
void main() {
  late AppDatabase database;

  /// A vault holding only the tables named, so a restore can be checked against
  /// something other than what is already in the database.
  VaultRows vaultOf({
    List<Pedal> pedals = const [],
    List<PedalControl> controls = const [],
  }) => (
    pedals: pedals,
    controls: controls,
    configurations: const [],
    configurationValues: const [],
    changeLogs: const [],
    replacements: const [],
    pedalboards: const [],
    slots: const [],
    snapshots: const [],
    snapshotEntries: const [],
    snapshotValues: const [],
  );

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('reads a row out of every table', () async {
    await fillVault(database);

    final rows = await database.backupDao.readEverything();

    // A backup that quietly skipped a table would still look like a backup, so
    // every list is checked rather than a sample of them.
    expect(rows.pedals, hasLength(2));
    expect(rows.controls, hasLength(1));
    expect(rows.configurations, hasLength(1));
    expect(rows.configurationValues, hasLength(1));
    expect(rows.changeLogs, hasLength(1));
    expect(rows.replacements, hasLength(1));
    expect(rows.pedalboards, hasLength(1));
    expect(rows.slots, hasLength(1));
    expect(rows.snapshots, hasLength(1));
    expect(rows.snapshotEntries, hasLength(1));
    expect(rows.snapshotValues, hasLength(1));
  });

  test('an empty vault reads as empty lists', () async {
    final rows = await database.backupDao.readEverything();

    expect(rows.pedals, isEmpty);
    expect(rows.snapshotValues, isEmpty);
  });

  test('writes a vault back with its ids intact', () async {
    await fillVault(database);
    final backed = await database.backupDao.readEverything();

    await database.backupDao.writeEverything(backed);

    // Ids have to survive, or every reference in the file would land on the
    // wrong pedal after a restore.
    final rows = await database.backupDao.readEverything();
    expect(rows.pedals, backed.pedals);
    expect(rows.controls, backed.controls);
    expect(rows.configurationValues, backed.configurationValues);
    expect(rows.slots, backed.slots);
    expect(rows.snapshotEntries, backed.snapshotEntries);
    expect(rows.snapshotValues, backed.snapshotValues);
  });

  test('replaces whatever was in the vault before', () async {
    await fillVault(database);
    final backed = await database.backupDao.readEverything();

    await database.backupDao.writeEverything(vaultOf(pedals: backed.pedals));

    // A restore is not a merge: what the file does not carry is gone, down to
    // the rig and the snapshot that was taken of it.
    final rows = await database.backupDao.readEverything();
    expect(rows.pedals, backed.pedals);
    expect(rows.configurations, isEmpty);
    expect(rows.changeLogs, isEmpty);
    expect(rows.pedalboards, isEmpty);
    expect(rows.snapshots, isEmpty);
  });

  test(
    'a row pointing at a missing parent leaves the vault untouched',
    () async {
      await fillVault(database);
      final backed = await database.backupDao.readEverything();

      // A control with no pedal to hang off it: the sort of thing a hand-edited
      // backup file arrives with.
      await expectLater(
        database.backupDao.writeEverything(vaultOf(controls: backed.controls)),
        throwsA(anything),
      );

      // The delete and the writes are one transaction, so the vault still holds
      // everything it held before the bad file was opened.
      final rows = await database.backupDao.readEverything();
      expect(rows.pedals, backed.pedals);
      expect(rows.controls, backed.controls);
      expect(rows.snapshotValues, backed.snapshotValues);
    },
  );
}
