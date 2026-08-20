import 'package:drift/drift.dart';

// The generated part file names these enums in companion and manager APIs, and
// a part file can only see imports declared by its parent library.
import '../enums/change_type.dart';
import '../enums/control_type.dart';
import '../enums/multi_effects_mode.dart';
import '../enums/pedal_category.dart';
import '../enums/pedal_status.dart';
import '../enums/pedal_type.dart';
import 'daos/backup_dao.dart';
import 'daos/change_log_dao.dart';
import 'daos/configuration_dao.dart';
import 'daos/pedal_control_dao.dart';
import 'daos/pedal_dao.dart';
import 'daos/pedal_replacement_dao.dart';
import 'daos/pedalboard_dao.dart';
import 'daos/rig_snapshot_dao.dart';
import 'migrations.dart';
import 'tables/change_logs_table.dart';
import 'tables/configuration_values_table.dart';
import 'tables/configurations_table.dart';
import 'tables/pedal_controls_table.dart';
import 'tables/pedal_replacements_table.dart';
import 'tables/pedalboard_slots_table.dart';
import 'tables/pedalboards_table.dart';
import 'tables/pedals_table.dart';
import 'tables/rig_snapshot_entries_table.dart';
import 'tables/rig_snapshot_values_table.dart';
import 'tables/rig_snapshots_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Pedals,
    PedalControls,
    Configurations,
    ConfigurationValues,
    ChangeLogs,
    PedalReplacements,
    Pedalboards,
    PedalboardSlots,
    RigSnapshots,
    RigSnapshotEntries,
    RigSnapshotValues,
  ],
  daos: [
    PedalDao,
    PedalControlDao,
    ConfigurationDao,
    ChangeLogDao,
    PedalReplacementDao,
    PedalboardDao,
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
