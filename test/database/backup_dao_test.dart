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
    patches: const [],
    scenes: const [],
    scenePedals: const [],
    sceneValues: const [],
    changeLogs: const [],
    replacements: const [],
    pedalboards: const [],
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
    expect(rows.pedals, hasLength(4)); // two on the floor, a unit and its pedal
    expect(rows.controls, hasLength(2));
    expect(rows.configurations, hasLength(1));
    expect(rows.configurationValues, hasLength(1));
    expect(rows.patches, hasLength(1));
    expect(rows.scenes, hasLength(1));
    expect(rows.scenePedals, hasLength(1));
    expect(rows.sceneValues, hasLength(1));
    expect(rows.changeLogs, hasLength(1));
    expect(rows.replacements, hasLength(1));
    expect(rows.pedalboards, hasLength(1));
    // One holding a pedal, one empty, and the output the rig ends at.
    expect(rows.signalBlocks, hasLength(3));
    expect(rows.signalConnections, hasLength(1));
    expect(rows.signalEndpoints, hasLength(1));
    expect(rows.snapshots, hasLength(1));
    expect(rows.snapshotEntries, hasLength(1));
    expect(rows.snapshotValues, hasLength(1));
    expect(rows.academyCourses, hasLength(1));
    expect(rows.academyModules, hasLength(1));
    expect(rows.academyLessons, hasLength(1));
    expect(rows.academyExercises, hasLength(1));
    expect(rows.academyProgress, hasLength(1));
    expect(rows.academyExerciseProgress, hasLength(1));
    expect(rows.academyPracticeSessions, hasLength(1));
    expect(rows.academyBookmarks, hasLength(1));
  });

  test('an empty vault reads as empty lists', () async {
    final rows = await database.backupDao.readEverything();

    expect(rows.pedals, isEmpty);
    expect(rows.signalEndpoints, isEmpty);
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
    expect(rows.signalBlocks, backed.signalBlocks);
    expect(rows.signalConnections, backed.signalConnections);
    expect(rows.signalEndpoints, backed.signalEndpoints);
  });

  test('the practice a player has done comes back with the lessons', () async {
    await fillVault(database);
    final backed = await database.backupDao.readEverything();

    await database.backupDao.writeEverything(backed);

    // Progress references a lesson by id, so it only means anything if the lesson
    // it points at comes back under the same id. Both are checked together for
    // that reason: either alone would pass on a file that credits the wrong one.
    final rows = await database.backupDao.readEverything();
    expect(rows.academyLessons, backed.academyLessons);
    expect(rows.academyExercises, backed.academyExercises);
    expect(rows.academyProgress, backed.academyProgress);
    expect(rows.academyProgress.single.practiceSeconds, 900);
    // The ticks and the sittings with them. A restore that brought the total back and
    // dropped these would put the player back on a lesson with nothing ticked and no
    // evening recorded, which is not where they left off.
    expect(rows.academyExerciseProgress, backed.academyExerciseProgress);
    expect(rows.academyPracticeSessions, backed.academyPracticeSessions);
    expect(rows.academyPracticeSessions.single.seconds, 900);
    expect(rows.academyBookmarks, backed.academyBookmarks);
  });

  test('a rig recorded on a date survives being backed up', () async {
    await fillVault(database);
    final backed = await database.backupDao.readEverything();

    await database.backupDao.writeEverything(backed);

    // The only route these rows have left. No screen reads them and no
    // repository writes them, so if the backup drops them on the way through,
    // nothing in the app would ever say so - which is what this test is for.
    // All three together, because a reading with no entry to hang off is not a
    // reading of anything.
    final rows = await database.backupDao.readEverything();
    expect(rows.snapshots, backed.snapshots);
    expect(rows.snapshotEntries, backed.snapshotEntries);
    expect(rows.snapshotValues, backed.snapshotValues);
    expect(rows.snapshots.single.name, 'Easter 2026');
    expect(rows.snapshotValues.single.value, 0.7);
  });

  test('a vault holding a patch can be written back at all', () async {
    // `patches` and `scene_pedals` reference `pedals` with ON DELETE RESTRICT,
    // and a restore empties every table before writing. Deferring the foreign
    // key checks to the commit is the only reason those deletes are allowed, so
    // a unit with a patch on it is the case that would break every restore.
    await fillVault(database);
    final backed = await database.backupDao.readEverything();

    await database.backupDao.writeEverything(backed);

    final rows = await database.backupDao.readEverything();
    expect(rows.patches, backed.patches);
    expect(rows.scenes, backed.scenes);
    expect(rows.scenePedals, backed.scenePedals);
    expect(rows.sceneValues, backed.sceneValues);
  });

  test('replaces whatever was in the vault before', () async {
    await fillVault(database);
    final backed = await database.backupDao.readEverything();

    await database.backupDao.writeEverything(vaultOf(pedals: backed.pedals));

    // A restore is not a merge: what the file does not carry is gone, down to
    // the rig and the chain that was on it.
    final rows = await database.backupDao.readEverything();
    expect(rows.pedals, backed.pedals);
    expect(rows.configurations, isEmpty);
    expect(rows.patches, isEmpty);
    expect(rows.scenes, isEmpty);
    expect(rows.changeLogs, isEmpty);
    expect(rows.pedalboards, isEmpty);
    expect(rows.signalBlocks, isEmpty);
    // Including the snapshots, which reference a board with RESTRICT: they have
    // to go before it does, or the restore is refused rather than the rig
    // replaced.
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
      expect(rows.signalEndpoints, backed.signalEndpoints);
    },
  );
}
