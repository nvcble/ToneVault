import 'package:drift/drift.dart';

import '../../enums/signal_block_type.dart';
import 'pedalboards_table.dart';
import 'pedals_table.dart';

/// One stage of a rig's signal chain.
///
/// [position] is the order signal passes through, counting from the guitar, and
/// is renumbered 0, 1, 2 and so on whenever the chain changes rather than left
/// with gaps. Where a rig has stored connections it is those that say what feeds
/// what, and position only breaks ties.
///
/// A block is a place in the chain first and a pedal second, which is why
/// [pedalId] is nullable: a rig is planned before it is owned, so "an overdrive
/// goes here" has to be sayable with nothing to put in it yet.
///
/// What each pedal is set to is not here: a rig says which pedals are in the
/// chain and in what order, while the settings live on the pedal as its own
/// configurations.
@TableIndex(
  name: 'idx_signal_blocks_board_position',
  columns: {#pedalboardId, #position},
)
class SignalBlocks extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Deleting a rig deletes its blocks: a block only says what sat where on that
  /// rig, so with the rig gone there is nothing left for it to mean. The pedals
  /// themselves are untouched.
  IntColumn get pedalboardId =>
      integer().references(Pedalboards, #id, onDelete: KeyAction.cascade)();

  /// Restrict, like every other reference to a pedal: one that is on a rig has
  /// to be taken off it before it can be deleted.
  IntColumn get pedalId => integer().nullable().references(
    Pedals,
    #id,
    onDelete: KeyAction.restrict,
  )();

  TextColumn get blockType => textEnum<SignalBlockType>()();

  /// What this block is called on the board, where the pedal's own name is not
  /// what the user thinks of it as ('Always on', 'Solo boost').
  TextColumn get label => text().withLength(min: 1, max: 80).nullable()();

  IntColumn get position => integer()();

  /// Whether the block passes signal or is bypassed. A bypassed block keeps its
  /// place in the chain, because bypassing is a sound the user is trying, not a
  /// decision to take the pedal off the board.
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();

  TextColumn get notes => text().nullable()();

  /// There is only one of each physical pedal, so it cannot appear twice in the
  /// same chain. Empty blocks are exempt: SQLite counts NULLs as distinct, which
  /// is what lets a rig be planned out with several places still to fill.
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {pedalboardId, pedalId},
  ];
}
