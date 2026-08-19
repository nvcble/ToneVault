import 'package:drift/drift.dart';

import 'configurations_table.dart';
import 'pedal_controls_table.dart';

/// One control's position within one configuration.
///
/// [value] is stored in the owning control's own `[minValue, maxValue]` domain,
/// never as a formatted string. Formatting for display is the UI's job.
class ConfigurationValues extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get configurationId =>
      integer().references(Configurations, #id, onDelete: KeyAction.cascade)();

  IntColumn get controlId =>
      integer().references(PedalControls, #id, onDelete: KeyAction.cascade)();

  RealColumn get value => real()();

  /// A configuration holds at most one position per control.
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {configurationId, controlId},
  ];
}
