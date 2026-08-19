import 'package:drift/drift.dart';

import 'pedalboards_table.dart';
import 'pedals_table.dart';

/// One pedal's place in a rig's signal chain.
///
/// [position] is the order signal passes through, counting from the guitar, and
/// is renumbered 0, 1, 2 and so on whenever the chain changes rather than left
/// with gaps.
///
/// What each pedal is set to is not here: a rig says which pedals are in the
/// chain and in what order, while the settings live on the pedal as its own
/// configurations.
@TableIndex(
  name: 'idx_pedalboard_slots_board_position',
  columns: {#pedalboardId, #position},
)
class PedalboardSlots extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Deleting a rig deletes its slots: a slot only says where a pedal sat on
  /// that rig, so with the rig gone there is nothing left for it to mean. The
  /// pedals themselves are untouched.
  IntColumn get pedalboardId =>
      integer().references(Pedalboards, #id, onDelete: KeyAction.cascade)();

  /// Restrict, like every other reference to a pedal: one that is on a rig has
  /// to be taken off it before it can be deleted.
  IntColumn get pedalId =>
      integer().references(Pedals, #id, onDelete: KeyAction.restrict)();

  IntColumn get position => integer()();

  /// There is only one of each physical pedal, so it cannot appear twice in the
  /// same chain.
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {pedalboardId, pedalId},
  ];
}
