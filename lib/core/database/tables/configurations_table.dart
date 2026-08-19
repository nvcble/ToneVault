import 'package:drift/drift.dart';

import 'pedals_table.dart';

/// A named preset for one pedal, such as "Worship Lead" or "Clean Boost".
///
/// The values themselves live in `configuration_values`, one row per control.
@TableIndex(name: 'idx_configurations_pedal', columns: {#pedalId})
class Configurations extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get pedalId =>
      integer().references(Pedals, #id, onDelete: KeyAction.restrict)();

  TextColumn get name => text().withLength(min: 1, max: 80)();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {pedalId, name},
  ];
}
