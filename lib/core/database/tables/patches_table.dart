import 'package:drift/drift.dart';

import 'pedals_table.dart';

/// A named patch of one multi-effects unit, such as "Worship Clean".
///
/// A patch is what the unit is switched to as a whole. The sounds within it are
/// its scenes, and the pedals a scene uses belong to the unit rather than to the
/// patch, so the same Tube Screamer is entered once and reached from every scene
/// that needs it.
///
/// Deliberately not `configurations`: a configuration belongs to one pedal and
/// holds positions directly, while a patch holds scenes and no positions at all.
/// Named explicitly because dropping the trailing "s" of `Patches` would leave
/// drift generating a row class called `Patche`.
@DataClassName('Patch')
@TableIndex(name: 'idx_patches_pedal', columns: {#pedalId})
class Patches extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The unit this patch is on. Restricted rather than cascading, for the same
  /// reason a pedal with configurations cannot be deleted: retiring gear is what
  /// keeps its history.
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
