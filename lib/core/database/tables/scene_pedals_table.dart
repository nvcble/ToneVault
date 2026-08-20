import 'package:drift/drift.dart';

import 'pedals_table.dart';
import 'scenes_table.dart';

/// Which of the unit's pedals one scene uses.
///
/// The pedal itself belongs to the unit, entered once with `host_pedal_id` set,
/// so this says only that the scene reaches for it - never a second copy of it.
///
/// No position column: a scene is a set of sounds switched on together, not an
/// order signal chain. Rows are read in the pedals' own name order.
class ScenePedals extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get sceneId =>
      integer().references(Scenes, #id, onDelete: KeyAction.cascade)();

  /// Restricted, as everywhere a pedal is pointed at: a pedal a scene uses is
  /// retired rather than deleted.
  IntColumn get pedalId =>
      integer().references(Pedals, #id, onDelete: KeyAction.restrict)();

  /// A scene reaches for a given pedal once.
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {sceneId, pedalId},
  ];
}
