import 'package:drift/drift.dart';

// The generated part file names these enums in companion and manager APIs, and
// a part file can only see imports declared by its parent library.
import '../enums/change_type.dart';
import '../enums/control_type.dart';
import '../enums/multi_effects_mode.dart';
import '../enums/pedal_category.dart';
import '../enums/pedal_status.dart';
import '../enums/pedal_type.dart';
import '../enums/signal_block_type.dart';
import '../enums/signal_connection_type.dart';
import '../enums/signal_destination.dart';
import '../enums/signal_source.dart';
import 'daos/backup_dao.dart';
import 'daos/change_log_dao.dart';
import 'daos/configuration_dao.dart';
import 'daos/patch_dao.dart';
import 'daos/pedal_control_dao.dart';
import 'daos/pedal_dao.dart';
import 'daos/pedal_replacement_dao.dart';
import 'daos/pedalboard_dao.dart';
import 'daos/rig_snapshot_dao.dart';
import 'daos/scene_dao.dart';
import 'daos/signal_chain_dao.dart';
import 'daos/signal_endpoint_dao.dart';
import 'migrations.dart';
import 'tables/change_logs_table.dart';
import 'tables/configuration_values_table.dart';
import 'tables/configurations_table.dart';
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
  ],
  daos: [
    PedalDao,
    PedalControlDao,
    ConfigurationDao,
    PatchDao,
    SceneDao,
    ChangeLogDao,
    PedalReplacementDao,
    PedalboardDao,
    SignalChainDao,
    SignalEndpointDao,
    RigSnapshotDao,
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
