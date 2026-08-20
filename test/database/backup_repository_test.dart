import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/backup_dao.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/backup/data/backup_repository.dart';
import 'package:tone_vault/shared/formatting/app_date_format.dart';
import '../support/repositories.dart';
import '../support/vault_fixture.dart';

/// Backing the vault up and putting it back: what lands in the file, what a
/// restore does to what is already there, and what is refused.
void main() {
  late AppDatabase database;
  late BackupRepository repository;
  late VaultRows saved;
  late String file;

  final exportedAt = DateTime.utc(2026, 8, 20, 7, 15);

  /// A refusal the user can read, rather than a raw driver exception.
  Matcher failsWith(Object message) => throwsA(
    isA<AppFailure>().having((failure) => failure.message, 'message', message),
  );

  /// The exported file with one thing changed by hand.
  String edited(void Function(Map<String, dynamic> tables) change) {
    final document = json.decode(file) as Map<String, dynamic>;
    change(document['tables'] as Map<String, dynamic>);
    return json.encode(document);
  }

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = backupRepository(database, clock: () => exportedAt);
    await fillVault(database);
    saved = await database.backupDao.readEverything();
    file = (await repository.exportVault()).contents;
  });

  tearDown(() => database.close());

  test('exports the vault, stamped with when it was made', () async {
    final export = await repository.exportVault();
    final backup = repository.readBackup(export.contents);

    // The name and the stamp inside come from one reading of the clock.
    expect(
      export.fileName,
      'tonevault-backup-${formatDate(exportedAt.toLocal())}.json',
    );
    expect(backup.exportedAt, exportedAt);
    expect(backup.rows.pedals, saved.pedals);
    expect(backup.rows.snapshotValues, saved.snapshotValues);
  });

  test('restoring puts the vault back the way the file has it', () async {
    // A fortnight of gear-buying and tidying up after the backup was taken.
    await database
        .into(database.pedals)
        .insert(
          PedalsCompanion.insert(
            name: 'Flashback',
            type: PedalType.digital,
            category: PedalCategory.delay,
            createdAt: exportedAt,
            updatedAt: exportedAt,
          ),
        );
    await database
        .update(database.pedalboards)
        .write(const PedalboardsCompanion(name: Value('Fly Rig')));

    await repository.restoreVault(repository.readBackup(file));

    final rows = await database.backupDao.readEverything();
    expect(rows.pedals, saved.pedals);
    expect(rows.pedalboards, saved.pedalboards);
    expect(rows.snapshots, saved.snapshots);
    expect(rows.snapshotValues, saved.snapshotValues);
  });

  test('restoring a backup of an empty vault empties the vault', () async {
    final beforeAnyGear = edited((tables) {
      for (final table in tables.keys) {
        tables[table] = <dynamic>[];
      }
    });

    await repository.restoreVault(repository.readBackup(beforeAnyGear));

    // A restore is the vault becoming that day's copy of itself, even when that
    // day had nothing in it.
    final rows = await database.backupDao.readEverything();
    expect(rows.pedals, isEmpty);
    expect(rows.pedalboards, isEmpty);
    expect(rows.snapshots, isEmpty);
  });

  test('a refusal from the file reaches the user as it is written', () async {
    // The document layer already phrases these; the repository must not bury
    // them under a message about the database.
    expect(
      () => repository.readBackup('a holiday photo'),
      failsWith('That file is not a ToneVault backup.'),
    );
  });

  test('a backup whose rows do not hang together changes nothing', () async {
    // Every table present, so the file reads: the pedals are simply gone from
    // under the controls, configurations and snapshots that name them.
    final orphaned = edited((tables) => tables['pedals'] = <dynamic>[]);
    final backup = repository.readBackup(orphaned);

    await expectLater(
      repository.restoreVault(backup),
      failsWith('Could not restore that backup, so your gear is as it was.'),
    );

    final rows = await database.backupDao.readEverything();
    expect(rows.pedals, saved.pedals);
    expect(rows.controls, saved.controls);
    expect(rows.snapshotValues, saved.snapshotValues);
  });
}
