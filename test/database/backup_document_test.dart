import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/backup_dao.dart';
import 'package:tone_vault/core/database/migrations.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/backup/data/backup_document.dart';
import 'package:tone_vault/features/backup/data/backup_upgrades.dart';
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

  /// The same vault as the file an app at [oldestReadableSchemaVersion] wrote:
  /// the tables added since then were not there to be written.
  String asOldestSchema() => edited((document) {
    document['schemaVersion'] = oldestReadableSchemaVersion;
    final tables = document['tables'] as Map<String, dynamic>;
    for (final table in const [
      'patches',
      'scenes',
      'scenePedals',
      'sceneValues',
      'academyCourses',
      'academyModules',
      'academyLessons',
      'academyExercises',
      'academyProgress',
      'academyExerciseProgress',
      'academyPracticeSessions',
      'academyBookmarks',
    ]) {
      tables.remove(table);
    }
  });

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
    expect(backup.rows.signalBlocks, saved.signalBlocks);
    expect(backup.rows.signalConnections, saved.signalConnections);
    expect(backup.rows.signalEndpoints, saved.signalEndpoints);
    expect(backup.rows.patches, saved.patches);
    expect(backup.rows.scenes, saved.scenes);
    expect(backup.rows.scenePedals, saved.scenePedals);
    expect(backup.rows.sceneValues, saved.sceneValues);
    expect(backup.rows.academyCourses, saved.academyCourses);
    expect(backup.rows.academyModules, saved.academyModules);
    expect(backup.rows.academyLessons, saved.academyLessons);
    expect(backup.rows.academyExercises, saved.academyExercises);
    expect(backup.rows.academyProgress, saved.academyProgress);
    expect(backup.rows.academyExerciseProgress, saved.academyExerciseProgress);
    expect(backup.rows.academyPracticeSessions, saved.academyPracticeSessions);
    expect(backup.rows.academyBookmarks, saved.academyBookmarks);
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
    final rigs = tablesOf(file)['pedalboards'] as List<dynamic>;

    // Readable, and unambiguous: a date with no zone on it is a date nobody can
    // pin down on the other side.
    expect(
      (rigs.single as Map<String, dynamic>)['createdAt'],
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

    // Still every table, so a vault emptied on purpose restores as empty rather
    // than being refused as damaged.
    expect(decodeVaultBackup(empty).rows.pedals, isEmpty);
    expect(decodeVaultBackup(empty).rows.signalEndpoints, isEmpty);
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

  test('reads the oldest file any released version wrote', () async {
    final backup = decodeVaultBackup(asOldestSchema());

    // The gear it does hold comes back whole, and the tables that schema never
    // had arrive empty rather than being guessed at.
    expect(backup.schemaVersion, oldestReadableSchemaVersion);
    expect(backup.rows.pedals, saved.pedals);
    expect(backup.rows.signalBlocks, saved.signalBlocks);
    expect(backup.rows.patches, isEmpty);
    expect(backup.rows.scenes, isEmpty);
    expect(backup.rows.scenePedals, isEmpty);
    expect(backup.rows.sceneValues, isEmpty);
    expect(backup.rows.academyCourses, isEmpty);
    expect(backup.rows.academyProgress, isEmpty);
  });

  test('a file from before the Academy restores the gear in it', () async {
    // What a phone at v14 wrote: every pedal and every board, and no curriculum,
    // because there was none to write.
    final beforeAcademy = edited((document) {
      document['schemaVersion'] = 14;
      final tables = document['tables'] as Map<String, dynamic>;
      for (final table in const [
        'academyCourses',
        'academyModules',
        'academyLessons',
        'academyExercises',
        'academyProgress',
        'academyExerciseProgress',
        'academyPracticeSessions',
        'academyBookmarks',
      ]) {
        tables.remove(table);
      }
    });

    final backup = decodeVaultBackup(beforeAcademy);

    expect(backup.rows.pedals, saved.pedals);
    expect(backup.rows.patches, saved.patches);
    // Empty, not absent: a restore writes what the file says, and a player who
    // had no Academy has done none of it. The seeder puts the curriculum back on
    // the next launch.
    expect(backup.rows.academyCourses, isEmpty);
    expect(backup.rows.academyLessons, isEmpty);
    expect(backup.rows.academyProgress, isEmpty);
    expect(backup.rows.academyExerciseProgress, isEmpty);
    expect(backup.rows.academyPracticeSessions, isEmpty);
    expect(backup.rows.academyBookmarks, isEmpty);
  });

  test('a file carrying snapshots restores the rest of it', () async {
    // What a phone at v13 wrote: the rig it holds is still the rig, and the days
    // frozen on it have nowhere to go now.
    final withSnapshots = edited((document) {
      document['schemaVersion'] = 13;
      (document['tables'] as Map<String, dynamic>)['snapshots'] = [
        {
          'id': 1,
          'pedalboardId': saved.pedalboards.single.id,
          'name': 'Easter 2026',
          'capturedAt': '2026-04-05T09:00:00.000Z',
        },
      ];
    });

    final backup = decodeVaultBackup(withSnapshots);

    expect(backup.rows.pedals, saved.pedals);
    expect(backup.rows.pedalboards, saved.pedalboards);
    expect(backup.rows.signalBlocks, saved.signalBlocks);
  });

  test('refuses a backup older than any version ever wrote', () async {
    final ancient = edited(
      (document) => document['schemaVersion'] = oldestReadableSchemaVersion - 1,
    );

    // Nothing shipped that could have written it, so there is nothing to
    // convert from and guessing would be inventing.
    expect(
      () => decodeVaultBackup(ancient),
      failsWith(
        'That backup was made by a version of ToneVault too old to restore '
        'from.',
      ),
    );
  });

  test('a current file with a patch table missing is still damaged', () async {
    final missing = edited(
      (document) =>
          (document['tables'] as Map<String, dynamic>).remove('patches'),
    );

    // Filling a table in is for a file that predates it. A file that says it is
    // current and has one missing has lost it, and reading it as empty would
    // quietly wipe the patches it could not find.
    expect(
      () => decodeVaultBackup(missing),
      failsWith(
        'That backup file is damaged, so nothing was restored from it.',
      ),
    );
  });

  test('refuses a file with a table missing', () async {
    final missing = edited(
      (document) =>
          (document['tables'] as Map<String, dynamic>).remove('signalBlocks'),
    );

    // Read as empty, it would quietly wipe the chain it could not find.
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
