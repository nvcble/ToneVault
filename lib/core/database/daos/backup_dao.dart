import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/academy_bookmarks_table.dart';
import '../tables/academy_courses_table.dart';
import '../tables/academy_exercise_progress_table.dart';
import '../tables/academy_exercises_table.dart';
import '../tables/academy_lessons_table.dart';
import '../tables/academy_modules_table.dart';
import '../tables/academy_practice_sessions_table.dart';
import '../tables/academy_progress_table.dart';
import '../tables/change_logs_table.dart';
import '../tables/configuration_values_table.dart';
import '../tables/configurations_table.dart';
import '../tables/patches_table.dart';
import '../tables/pedal_controls_table.dart';
import '../tables/pedal_replacements_table.dart';
import '../tables/pedalboards_table.dart';
import '../tables/pedals_table.dart';
import '../tables/rig_snapshot_entries_table.dart';
import '../tables/rig_snapshot_values_table.dart';
import '../tables/rig_snapshots_table.dart';
import '../tables/scene_pedals_table.dart';
import '../tables/scene_values_table.dart';
import '../tables/scenes_table.dart';
import '../tables/signal_blocks_table.dart';
import '../tables/signal_connections_table.dart';
import '../tables/signal_endpoints_table.dart';

part 'backup_dao.g.dart';

/// Every row in the vault, table by table.
///
/// The fields are declared parent before child, which is the order foreign keys
/// allow them to be written in.
///
/// The Academy's courses, modules, lessons and exercises are in here as well as
/// the progress against them, even though the curriculum ships with the app and is
/// the same on every install of it. It makes the file bigger than it strictly has
/// to be. The alternative is worse: progress points at a lesson by id, and a phone
/// that seeded its curriculum in a different order would give the same id to a
/// different lesson, so a restore of progress alone would credit the player for
/// lessons they never opened. Carrying the lessons too means the ids in the file
/// and the ids they refer to arrive together and still agree.
///
/// The rig tables are still in here for the opposite reason: nothing in the app
/// reads them any more, so this is the only way left to get those rows off the
/// phone or back onto one. Leaving them out would make the next backup the moment
/// the user's boards and snapshots quietly stopped being kept.
typedef VaultRows = ({
  List<Pedal> pedals,
  List<PedalControl> controls,
  List<Configuration> configurations,
  List<ConfigurationValue> configurationValues,
  List<Patch> patches,
  List<Scene> scenes,
  List<ScenePedal> scenePedals,
  List<SceneValue> sceneValues,
  List<ChangeLog> changeLogs,
  List<PedalReplacement> replacements,
  List<Pedalboard> pedalboards,
  List<SignalBlock> signalBlocks,
  List<SignalConnection> signalConnections,
  List<SignalEndpoint> signalEndpoints,
  List<RigSnapshot> snapshots,
  List<RigSnapshotEntry> snapshotEntries,
  List<RigSnapshotValue> snapshotValues,
  List<AcademyCourse> academyCourses,
  List<AcademyModule> academyModules,
  List<AcademyLesson> academyLessons,
  List<AcademyExercise> academyExercises,
  List<AcademyProgressRow> academyProgress,
  List<AcademyExerciseProgressRow> academyExerciseProgress,
  List<AcademyPracticeSessionRow> academyPracticeSessions,
  List<AcademyBookmark> academyBookmarks,
});

/// Reads and replaces the whole vault, for backup and restore.
///
/// This is the one place that touches every table at once. Turning rows into a
/// file and back belongs to the backup feature; this class only moves them in
/// and out of the database, with ids intact so a restored vault reads exactly
/// like the one that was backed up.
@DriftAccessor(
  tables: [
    Pedals,
    PedalControls,
    Configurations,
    ConfigurationValues,
    Patches,
    Scenes,
    ScenePedals,
    SceneValues,
    ChangeLogs,
    PedalReplacements,
    Pedalboards,
    SignalBlocks,
    SignalConnections,
    SignalEndpoints,
    RigSnapshots,
    RigSnapshotEntries,
    RigSnapshotValues,
    AcademyCourses,
    AcademyModules,
    AcademyLessons,
    AcademyExercises,
    AcademyProgress,
    AcademyExerciseProgress,
    AcademyPracticeSessions,
    AcademyBookmarks,
  ],
)
class BackupDao extends DatabaseAccessor<AppDatabase> with _$BackupDaoMixin {
  BackupDao(super.attachedDatabase);

  /// The whole vault, read in one transaction so a write part-way through cannot
  /// produce a backup that is half one thing and half another.
  Future<VaultRows> readEverything() {
    return transaction(
      () async => (
        pedals: await select(pedals).get(),
        controls: await select(pedalControls).get(),
        configurations: await select(configurations).get(),
        configurationValues: await select(configurationValues).get(),
        patches: await select(patches).get(),
        scenes: await select(scenes).get(),
        scenePedals: await select(scenePedals).get(),
        sceneValues: await select(sceneValues).get(),
        changeLogs: await select(changeLogs).get(),
        replacements: await select(pedalReplacements).get(),
        pedalboards: await select(pedalboards).get(),
        signalBlocks: await select(signalBlocks).get(),
        signalConnections: await select(signalConnections).get(),
        signalEndpoints: await select(signalEndpoints).get(),
        snapshots: await select(rigSnapshots).get(),
        snapshotEntries: await select(rigSnapshotEntries).get(),
        snapshotValues: await select(rigSnapshotValues).get(),
        academyCourses: await select(academyCourses).get(),
        academyModules: await select(academyModules).get(),
        academyLessons: await select(academyLessons).get(),
        academyExercises: await select(academyExercises).get(),
        academyProgress: await select(academyProgress).get(),
        academyExerciseProgress: await select(academyExerciseProgress).get(),
        academyPracticeSessions: await select(academyPracticeSessions).get(),
        academyBookmarks: await select(academyBookmarks).get(),
      ),
    );
  }

  /// Empties the vault and writes [rows] in its place, all or nothing.
  ///
  /// One transaction, so a file that turns out to reference a pedal that is not
  /// in it leaves the vault exactly as it was rather than half replaced.
  Future<void> writeEverything(VaultRows rows) {
    return transaction(() async {
      // Holds every foreign key check until the transaction commits, rather than
      // testing each row as it lands. `pedals` references itself now - a stomp
      // points at the unit it sits in - and one list of rows cannot be ordered
      // parent before child within a single table. Checking at the commit is the
      // guarantee that matters anyway: a file whose references do not all resolve
      // is refused as a whole, and the vault is left exactly as it was.
      //
      // SQLite resets this at the end of the transaction, so it applies to this
      // restore alone.
      await customStatement('PRAGMA defer_foreign_keys = ON;');
      await _deleteEverything();

      // Parent before child, so every reference has something to point at by
      // the time it is written.
      await batch((batch) {
        batch.insertAll(pedals, rows.pedals);
        batch.insertAll(pedalControls, rows.controls);
        batch.insertAll(configurations, rows.configurations);
        batch.insertAll(configurationValues, rows.configurationValues);
        batch.insertAll(patches, rows.patches);
        batch.insertAll(scenes, rows.scenes);
        batch.insertAll(scenePedals, rows.scenePedals);
        batch.insertAll(sceneValues, rows.sceneValues);
        batch.insertAll(changeLogs, rows.changeLogs);
        batch.insertAll(pedalReplacements, rows.replacements);
        batch.insertAll(pedalboards, rows.pedalboards);
        batch.insertAll(signalBlocks, rows.signalBlocks);
        batch.insertAll(signalConnections, rows.signalConnections);
        batch.insertAll(signalEndpoints, rows.signalEndpoints);
        batch.insertAll(rigSnapshots, rows.snapshots);
        batch.insertAll(rigSnapshotEntries, rows.snapshotEntries);
        batch.insertAll(rigSnapshotValues, rows.snapshotValues);
        batch.insertAll(academyCourses, rows.academyCourses);
        batch.insertAll(academyModules, rows.academyModules);
        batch.insertAll(academyLessons, rows.academyLessons);
        batch.insertAll(academyExercises, rows.academyExercises);
        batch.insertAll(academyProgress, rows.academyProgress);
        batch.insertAll(academyExerciseProgress, rows.academyExerciseProgress);
        batch.insertAll(academyPracticeSessions, rows.academyPracticeSessions);
        batch.insertAll(academyBookmarks, rows.academyBookmarks);
      });
    });
  }

  /// Child before parent, the reverse of the write order, so no delete is
  /// refused by a row still pointing at what it is deleting.
  Future<void> _deleteEverything() async {
    await delete(academyBookmarks).go();
    await delete(academyPracticeSessions).go();
    await delete(academyExerciseProgress).go();
    await delete(academyProgress).go();
    await delete(academyExercises).go();
    await delete(academyLessons).go();
    await delete(academyModules).go();
    await delete(academyCourses).go();
    await delete(rigSnapshotValues).go();
    await delete(rigSnapshotEntries).go();
    await delete(rigSnapshots).go();
    await delete(signalEndpoints).go();
    await delete(signalConnections).go();
    await delete(signalBlocks).go();
    await delete(pedalboards).go();
    await delete(pedalReplacements).go();
    await delete(changeLogs).go();
    await delete(sceneValues).go();
    await delete(scenePedals).go();
    await delete(scenes).go();
    await delete(patches).go();
    await delete(configurationValues).go();
    await delete(configurations).go();
    await delete(pedalControls).go();
    await delete(pedals).go();
  }
}
