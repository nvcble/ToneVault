import 'package:drift/drift.dart';

// The generated part file names these enums in companion and manager APIs, and
// a part file can only see imports declared by its parent library.
import '../enums/bookmark_target.dart';
import '../enums/change_type.dart';
import '../enums/control_type.dart';
import '../enums/learning_path.dart';
import '../enums/lesson_kind.dart';
import '../enums/multi_effects_mode.dart';
import '../enums/music_genre.dart';
import '../enums/pedal_category.dart';
import '../enums/pedal_status.dart';
import '../enums/pedal_type.dart';
import '../enums/progress_state.dart';
import '../enums/signal_block_type.dart';
import '../enums/signal_connection_type.dart';
import '../enums/signal_destination.dart';
import '../enums/signal_source.dart';
import '../enums/skill_level.dart';
import '../enums/time_signature.dart';
import 'daos/academy_bookmark_dao.dart';
import 'daos/academy_course_dao.dart';
import 'daos/academy_progress_dao.dart';
import 'daos/backup_dao.dart';
import 'daos/change_log_dao.dart';
import 'daos/configuration_dao.dart';
import 'daos/hotone_ampero_mini_patch_dao.dart';
import 'daos/midi_device_link_dao.dart';
import 'daos/midi_parameter_override_dao.dart';
import 'daos/midi_patch_favorite_dao.dart';
import 'daos/midi_patch_program_number_dao.dart';
import 'daos/midi_patch_recent_dao.dart';
import 'daos/midi_patch_selection_settings_dao.dart';
import 'daos/midi_preset_capture_dao.dart';
import 'daos/midi_scene_number_dao.dart';
import 'daos/patch_dao.dart';
import 'daos/pedal_control_dao.dart';
import 'daos/pedal_dao.dart';
import 'daos/pedal_replacement_dao.dart';
import 'daos/scene_dao.dart';
import 'migrations.dart';
import 'tables/academy_bookmarks_table.dart';
import 'tables/academy_courses_table.dart';
import 'tables/academy_exercise_progress_table.dart';
import 'tables/academy_exercises_table.dart';
import 'tables/academy_lessons_table.dart';
import 'tables/academy_modules_table.dart';
import 'tables/academy_practice_sessions_table.dart';
import 'tables/academy_progress_table.dart';
import 'tables/change_logs_table.dart';
import 'tables/configuration_values_table.dart';
import 'tables/configurations_table.dart';
import 'tables/hotone_ampero_mini_patches_table.dart';
import 'tables/midi_device_links_table.dart';
import 'tables/midi_parameter_overrides_table.dart';
import 'tables/midi_patch_favorites_table.dart';
import 'tables/midi_patch_program_numbers_table.dart';
import 'tables/midi_patch_recents_table.dart';
import 'tables/midi_patch_selection_settings_table.dart';
import 'tables/midi_preset_captures_table.dart';
import 'tables/midi_scene_numbers_table.dart';
import 'tables/patches_table.dart';
import 'tables/pedal_controls_table.dart';
import 'tables/pedal_replacements_table.dart';
import 'tables/pedalboards_table.dart';
import 'tables/pedals_table.dart';
import 'tables/rig_snapshot_entries_table.dart';
import 'tables/rig_snapshot_values_table.dart';
import 'tables/rig_snapshots_table.dart';
import 'tables/scene_pedals_table.dart';
import 'tables/scene_values_table.dart';
import 'tables/scenes_table.dart';
import 'tables/signal_blocks_table.dart';
import 'tables/signal_connections_table.dart';
import 'tables/signal_endpoints_table.dart';

part 'app_database.g.dart';

/// Every table the app has ever shipped, and the accessors that still read them.
///
/// The seven rig tables - `pedalboards`, `signal_blocks`, `signal_connections`,
/// `signal_endpoints`, `rig_snapshots`, `rig_snapshot_entries` and
/// `rig_snapshot_values` - are declared with no DAO of their own on purpose. The
/// rigs feature they were built for is gone, but the rows are the user's own
/// record of how their board was wired and where every knob stood on a night they
/// played, and dropping a table is not something to do on the same day the screens
/// for it are taken away. [BackupDao] still carries all seven, so a backup taken
/// today holds them and one taken before still restores.
///
/// Whether they are dropped for good is a decision for a later schema version, and
/// one that should not be made until there is somewhere for the rows to go first;
/// see `migrations.dart`.
@DriftDatabase(
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
    MidiParameterOverrides,
    MidiPatchSelectionSettings,
    MidiDeviceLinks,
    MidiPatchProgramNumbers,
    MidiSceneNumbers,
    MidiPatchFavorites,
    MidiPatchRecents,
    MidiPresetCaptures,
    HotoneAmperoMiniPatches,
  ],
  daos: [
    PedalDao,
    PedalControlDao,
    ConfigurationDao,
    PatchDao,
    SceneDao,
    ChangeLogDao,
    PedalReplacementDao,
    AcademyCourseDao,
    AcademyProgressDao,
    AcademyBookmarkDao,
    MidiParameterOverrideDao,
    MidiPatchSelectionSettingsDao,
    MidiDeviceLinkDao,
    MidiPatchProgramNumberDao,
    MidiSceneNumberDao,
    MidiPatchFavoriteDao,
    MidiPatchRecentDao,
    MidiPresetCaptureDao,
    HotoneAmperoMiniPatchDao,
    BackupDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => buildMigrationStrategy(this);
}
