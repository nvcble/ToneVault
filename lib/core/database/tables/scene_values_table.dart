import 'package:drift/drift.dart';

import 'pedal_controls_table.dart';
import 'scenes_table.dart';

/// One control's position within one scene.
///
/// The same shape as `configuration_values`, and for the same reason: [value] is
/// stored in the owning control's own `[minValue, maxValue]` domain, never as a
/// formatted string. Which pedal the control is on is read through the control.
class SceneValues extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get sceneId =>
      integer().references(Scenes, #id, onDelete: KeyAction.cascade)();

  IntColumn get controlId =>
      integer().references(PedalControls, #id, onDelete: KeyAction.cascade)();

  RealColumn get value => real()();

  /// A scene holds at most one position per control.
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {sceneId, controlId},
  ];
}
