import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/backup_dao.dart';
import 'package:tone_vault/core/database/migrations.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/backup/data/backup_document.dart';
import '../support/vault_fixture.dart';

/// The backup file itself: what it says, what comes back out of it, and what it
/// refuses to be read as.
void main() {
  late AppDatabase database;
  late VaultRows saved;
  late String file;

  final exportedAt = DateTime.utc(2026, 8, 20, 7, 15);

  /// A refusal the user can read, rather than a raw decoding exception.
  Matcher failsWith(Object message) => throwsA(
    isA<AppFailure>().having((failure) => failure.message, 'message', message),
  );

  /// The same file with one thing changed, for the kinds of file that turn up on
  /// a phone: hand-edited, truncated, or written by another version.
  String edited(void Function(Map<String, dynamic> document) change) {
    final document = json.decode(file) as Map<String, dynamic>;
    change(document);
    return json.encode(document);
  }

  Map<String, dynamic> tablesOf(String source) =>
      (json.decode(source) as Map<String, dynamic>)['tables']
          as Map<String, dynamic>;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await fillVault(database);
    saved = await database.backupDao.readEverything();
    file = encodeVaultBackup(saved, exportedAt: exportedAt);
  });

  tearDown(() => database.close());

  test('every table comes back the way it went in', () async {
    final backup = decodeVaultBackup(file);

    // Table by table, because the names on both sides of the file are written
    // by hand and a pair swapped between them would still round trip.
    expect(backup.rows.pedals, saved.pedals);
    expect(backup.rows.controls, saved.controls);
    expect(backup.rows.configurations, saved.configurations);
    expect(backup.rows.configurationValues, saved.configurationValues);
    expect(backup.rows.changeLogs, saved.changeLogs);
    expect(backup.rows.replacements, saved.replacements);
    expect(backup.rows.pedalboards, saved.pedalboards);
    expect(backup.rows.slots, saved.slots);
    expect(backup.rows.snapshots, saved.snapshots);
    expect(backup.rows.snapshotEntries, saved.snapshotEntries);
    expect(backup.rows.snapshotValues, saved.snapshotValues);
  });

  test('a date written in the device zone keeps its instant', () async {
    // What the app itself writes: DateTime.now(), in whatever zone the phone is
    // on. It comes back out as UTC, which is the same moment named plainly, and
    // reads on the user's own clock again through formatDateTime.
    final local = DateTime(2026, 4, 5, 9, 30);
    await database
        .into(database.pedalboards)
        .insert(
          PedalboardsCompanion.insert(
            name: 'Fly Rig',
            createdAt: local,
            updatedAt: local,
          ),
        );

    final rows = await database.backupDao.readEverything();
    final backup = decodeVaultBackup(
      encodeVaultBackup(rows, exportedAt: exportedAt),
    );

    final rig = backup.rows.pedalboards.firstWhere(
      (one) => one.name == 'Fly Rig',
    );
    expect(rig.createdAt.isAtSameMomentAs(local), isTrue);
  });

  test('says which app and which schema wrote it', () async {
    final backup = decodeVaultBackup(file);

    expect(backup.formatVersion, backupFormatVersion);
    expect(backup.schemaVersion, currentSchemaVersion);
    expect(backup.exportedAt, exportedAt);
  });

  test('writes dates as UTC, with the zone on them', () async {
    final snapshot = tablesOf(file)['snapshots'] as List<dynamic>;

    // Readable, and unambiguous: a date with no zone on it is a date nobody can
    // pin down on the other side.
    expect(
      (snapshot.single as Map<String, dynamic>)['capturedAt'],
      '2026-08-19T12:00:00.000Z',
    );
  });

  test('keeps a stored reading a number, not a rendered knob', () async {
    final values = tablesOf(file)['configurationValues'] as List<dynamic>;

    expect((values.single as Map<String, dynamic>)['value'], 0.7);
  });

  test('an empty vault is a readable file', () async {
    final fresh = AppDatabase(NativeDatabase.memory());
    addTearDown(fresh.close);

    final empty = encodeVaultBackup(
      await fresh.backupDao.readEverything(),
      exportedAt: exportedAt,
    );

    // Still all eleven tables, so a vault emptied on purpose restores as empty
    // rather than being refused as damaged.
    expect(decodeVaultBackup(empty).rows.pedals, isEmpty);
    expect(decodeVaultBackup(empty).rows.snapshotValues, isEmpty);
  });

  test('refuses a file that is not JSON at all', () async {
    expect(
      () => decodeVaultBackup('not a backup, a holiday photo'),
      failsWith('That file is not a ToneVault backup.'),
    );
  });

  test('refuses JSON that is not a backup', () async {
    expect(
      () => decodeVaultBackup('{"pedals": []}'),
      failsWith('That file is not a ToneVault backup.'),
    );
    expect(
      () => decodeVaultBackup('[1, 2, 3]'),
      failsWith('That file is not a ToneVault backup.'),
    );
  });

  test('refuses a backup a newer version of the app wrote', () async {
    final newerFormat = edited((document) => document['formatVersion'] = 2);
    final newerSchema = edited(
      (document) => document['schemaVersion'] = currentSchemaVersion + 1,
    );

    const refusal =
        'That backup was made by a newer version of ToneVault. Update the app, '
        'then try again.';
    expect(() => decodeVaultBackup(newerFormat), failsWith(refusal));
    expect(() => decodeVaultBackup(newerSchema), failsWith(refusal));
  });

  test('refuses a backup from a schema this app has moved past', () async {
    final older = edited(
      (document) => document['schemaVersion'] = currentSchemaVersion - 1,
    );

    // Better a plain no than a restore that invents settings for the columns
    // that version never had.
    expect(
      () => decodeVaultBackup(older),
      failsWith(
        'That backup was made by an older version of ToneVault and cannot be '
        'restored into this one.',
      ),
    );
  });

  test('refuses a file with a table missing', () async {
    final missing = edited(
      (document) =>
          (document['tables'] as Map<String, dynamic>).remove('slots'),
    );

    // Read as empty, it would quietly wipe the rig it could not find.
    expect(
      () => decodeVaultBackup(missing),
      failsWith(
        'That backup file is damaged, so nothing was restored from it.',
      ),
    );
  });

  test('refuses a row with a column missing', () async {
    final missing = edited((document) {
      final pedals =
          (document['tables'] as Map<String, dynamic>)['pedals']
              as List<dynamic>;
      (pedals.first as Map<String, dynamic>).remove('name');
    });

    expect(
      () => decodeVaultBackup(missing),
      failsWith(
        'That backup file is damaged, so nothing was restored from it.',
      ),
    );
  });
}
