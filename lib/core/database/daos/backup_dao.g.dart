// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_dao.dart';

// ignore_for_file: type=lint
mixin _$BackupDaoMixin on DatabaseAccessor<AppDatabase> {
  $PedalsTable get pedals => attachedDatabase.pedals;
  $PedalControlsTable get pedalControls => attachedDatabase.pedalControls;
  $ConfigurationsTable get configurations => attachedDatabase.configurations;
  $ConfigurationValuesTable get configurationValues =>
      attachedDatabase.configurationValues;
  $PatchesTable get patches => attachedDatabase.patches;
  $ScenesTable get scenes => attachedDatabase.scenes;
  $ScenePedalsTable get scenePedals => attachedDatabase.scenePedals;
  $SceneValuesTable get sceneValues => attachedDatabase.sceneValues;
  $ChangeLogsTable get changeLogs => attachedDatabase.changeLogs;
  $PedalReplacementsTable get pedalReplacements =>
      attachedDatabase.pedalReplacements;
  $PedalboardsTable get pedalboards => attachedDatabase.pedalboards;
  $SignalBlocksTable get signalBlocks => attachedDatabase.signalBlocks;
  $SignalConnectionsTable get signalConnections =>
      attachedDatabase.signalConnections;
  $SignalEndpointsTable get signalEndpoints => attachedDatabase.signalEndpoints;
  $RigSnapshotsTable get rigSnapshots => attachedDatabase.rigSnapshots;
  $RigSnapshotEntriesTable get rigSnapshotEntries =>
      attachedDatabase.rigSnapshotEntries;
  $RigSnapshotValuesTable get rigSnapshotValues =>
      attachedDatabase.rigSnapshotValues;
  $AcademyCoursesTable get academyCourses => attachedDatabase.academyCourses;
  $AcademyModulesTable get academyModules => attachedDatabase.academyModules;
  $AcademyLessonsTable get academyLessons => attachedDatabase.academyLessons;
  $AcademyExercisesTable get academyExercises =>
      attachedDatabase.academyExercises;
  $AcademyProgressTable get academyProgress => attachedDatabase.academyProgress;
  $AcademyExerciseProgressTable get academyExerciseProgress =>
      attachedDatabase.academyExerciseProgress;
  $AcademyPracticeSessionsTable get academyPracticeSessions =>
      attachedDatabase.academyPracticeSessions;
  $AcademyBookmarksTable get academyBookmarks =>
      attachedDatabase.academyBookmarks;
  $MidiParameterOverridesTable get midiParameterOverrides =>
      attachedDatabase.midiParameterOverrides;
  $MidiPatchSelectionSettingsTable get midiPatchSelectionSettings =>
      attachedDatabase.midiPatchSelectionSettings;
  $MidiDeviceLinksTable get midiDeviceLinks => attachedDatabase.midiDeviceLinks;
  $MidiPatchProgramNumbersTable get midiPatchProgramNumbers =>
      attachedDatabase.midiPatchProgramNumbers;
  $MidiSceneNumbersTable get midiSceneNumbers =>
      attachedDatabase.midiSceneNumbers;
  $MidiPatchFavoritesTable get midiPatchFavorites =>
      attachedDatabase.midiPatchFavorites;
  $MidiPatchRecentsTable get midiPatchRecents =>
      attachedDatabase.midiPatchRecents;
  BackupDaoManager get managers => BackupDaoManager(this);
}

class BackupDaoManager {
  final _$BackupDaoMixin _db;
  BackupDaoManager(this._db);
  $$PedalsTableTableManager get pedals =>
      $$PedalsTableTableManager(_db.attachedDatabase, _db.pedals);
  $$PedalControlsTableTableManager get pedalControls =>
      $$PedalControlsTableTableManager(_db.attachedDatabase, _db.pedalControls);
  $$ConfigurationsTableTableManager get configurations =>
      $$ConfigurationsTableTableManager(
        _db.attachedDatabase,
        _db.configurations,
      );
  $$ConfigurationValuesTableTableManager get configurationValues =>
      $$ConfigurationValuesTableTableManager(
        _db.attachedDatabase,
        _db.configurationValues,
      );
  $$PatchesTableTableManager get patches =>
      $$PatchesTableTableManager(_db.attachedDatabase, _db.patches);
  $$ScenesTableTableManager get scenes =>
      $$ScenesTableTableManager(_db.attachedDatabase, _db.scenes);
  $$ScenePedalsTableTableManager get scenePedals =>
      $$ScenePedalsTableTableManager(_db.attachedDatabase, _db.scenePedals);
  $$SceneValuesTableTableManager get sceneValues =>
      $$SceneValuesTableTableManager(_db.attachedDatabase, _db.sceneValues);
  $$ChangeLogsTableTableManager get changeLogs =>
      $$ChangeLogsTableTableManager(_db.attachedDatabase, _db.changeLogs);
  $$PedalReplacementsTableTableManager get pedalReplacements =>
      $$PedalReplacementsTableTableManager(
        _db.attachedDatabase,
        _db.pedalReplacements,
      );
  $$PedalboardsTableTableManager get pedalboards =>
      $$PedalboardsTableTableManager(_db.attachedDatabase, _db.pedalboards);
  $$SignalBlocksTableTableManager get signalBlocks =>
      $$SignalBlocksTableTableManager(_db.attachedDatabase, _db.signalBlocks);
  $$SignalConnectionsTableTableManager get signalConnections =>
      $$SignalConnectionsTableTableManager(
        _db.attachedDatabase,
        _db.signalConnections,
      );
  $$SignalEndpointsTableTableManager get signalEndpoints =>
      $$SignalEndpointsTableTableManager(
        _db.attachedDatabase,
        _db.signalEndpoints,
      );
  $$RigSnapshotsTableTableManager get rigSnapshots =>
      $$RigSnapshotsTableTableManager(_db.attachedDatabase, _db.rigSnapshots);
  $$RigSnapshotEntriesTableTableManager get rigSnapshotEntries =>
      $$RigSnapshotEntriesTableTableManager(
        _db.attachedDatabase,
        _db.rigSnapshotEntries,
      );
  $$RigSnapshotValuesTableTableManager get rigSnapshotValues =>
      $$RigSnapshotValuesTableTableManager(
        _db.attachedDatabase,
        _db.rigSnapshotValues,
      );
  $$AcademyCoursesTableTableManager get academyCourses =>
      $$AcademyCoursesTableTableManager(
        _db.attachedDatabase,
        _db.academyCourses,
      );
  $$AcademyModulesTableTableManager get academyModules =>
      $$AcademyModulesTableTableManager(
        _db.attachedDatabase,
        _db.academyModules,
      );
  $$AcademyLessonsTableTableManager get academyLessons =>
      $$AcademyLessonsTableTableManager(
        _db.attachedDatabase,
        _db.academyLessons,
      );
  $$AcademyExercisesTableTableManager get academyExercises =>
      $$AcademyExercisesTableTableManager(
        _db.attachedDatabase,
        _db.academyExercises,
      );
  $$AcademyProgressTableTableManager get academyProgress =>
      $$AcademyProgressTableTableManager(
        _db.attachedDatabase,
        _db.academyProgress,
      );
  $$AcademyExerciseProgressTableTableManager get academyExerciseProgress =>
      $$AcademyExerciseProgressTableTableManager(
        _db.attachedDatabase,
        _db.academyExerciseProgress,
      );
  $$AcademyPracticeSessionsTableTableManager get academyPracticeSessions =>
      $$AcademyPracticeSessionsTableTableManager(
        _db.attachedDatabase,
        _db.academyPracticeSessions,
      );
  $$AcademyBookmarksTableTableManager get academyBookmarks =>
      $$AcademyBookmarksTableTableManager(
        _db.attachedDatabase,
        _db.academyBookmarks,
      );
  $$MidiParameterOverridesTableTableManager get midiParameterOverrides =>
      $$MidiParameterOverridesTableTableManager(
        _db.attachedDatabase,
        _db.midiParameterOverrides,
      );
  $$MidiPatchSelectionSettingsTableTableManager
  get midiPatchSelectionSettings =>
      $$MidiPatchSelectionSettingsTableTableManager(
        _db.attachedDatabase,
        _db.midiPatchSelectionSettings,
      );
  $$MidiDeviceLinksTableTableManager get midiDeviceLinks =>
      $$MidiDeviceLinksTableTableManager(
        _db.attachedDatabase,
        _db.midiDeviceLinks,
      );
  $$MidiPatchProgramNumbersTableTableManager get midiPatchProgramNumbers =>
      $$MidiPatchProgramNumbersTableTableManager(
        _db.attachedDatabase,
        _db.midiPatchProgramNumbers,
      );
  $$MidiSceneNumbersTableTableManager get midiSceneNumbers =>
      $$MidiSceneNumbersTableTableManager(
        _db.attachedDatabase,
        _db.midiSceneNumbers,
      );
  $$MidiPatchFavoritesTableTableManager get midiPatchFavorites =>
      $$MidiPatchFavoritesTableTableManager(
        _db.attachedDatabase,
        _db.midiPatchFavorites,
      );
  $$MidiPatchRecentsTableTableManager get midiPatchRecents =>
      $$MidiPatchRecentsTableTableManager(
        _db.attachedDatabase,
        _db.midiPatchRecents,
      );
}
