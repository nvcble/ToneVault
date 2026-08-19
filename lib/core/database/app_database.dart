import 'package:drift/drift.dart';

// The generated part file names these enums in companion and manager APIs, and
// a part file can only see imports declared by its parent library.
import '../enums/change_type.dart';
import '../enums/control_type.dart';
import '../enums/pedal_category.dart';
import '../enums/pedal_status.dart';
import '../enums/pedal_type.dart';
import 'migrations.dart';
import 'tables/change_logs_table.dart';
import 'tables/configuration_values_table.dart';
import 'tables/configurations_table.dart';
import 'tables/pedal_controls_table.dart';
import 'tables/pedal_replacements_table.dart';
import 'tables/pedalboards_table.dart';
import 'tables/pedals_table.dart';

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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => buildMigrationStrategy(this);
}
