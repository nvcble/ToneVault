import 'package:drift/drift.dart';

import 'patches_table.dart';

/// One sound within a patch, such as "Verse" or "Solo".
///
/// A scene is where the positions are: which of the unit's pedals it uses is in
/// `scene_pedals`, and where their knobs sit is in `scene_values`.
///
/// Cascading, unlike a patch: a scene has no meaning apart from the patch it is
/// a sound of, so deleting the patch takes its scenes with it.
@TableIndex(name: 'idx_scenes_patch', columns: {#patchId})
class Scenes extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get patchId =>
      integer().references(Patches, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text().withLength(min: 1, max: 80)();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  /// Unique within one patch rather than one unit, so two patches can each have
  /// a "Verse".
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {patchId, name},
  ];
}
