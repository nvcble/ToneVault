import 'package:drift/drift.dart';

import '../../enums/signal_destination.dart';
import '../../enums/signal_source.dart';
import 'signal_blocks_table.dart';

/// What one edge of a rig reaches: where signal comes in from, or goes out to.
///
/// One row at most per block, and only for the blocks that are edges - an input,
/// an output, a send or a return. Everything in the middle of a chain is described
/// by the pedal in it, so a table of mostly-empty columns on `signal_blocks` would
/// have been four nullable columns no rule could stop a reverb from filling.
///
/// [destination] and [source] are never both set: a block is one end of a cable
/// out of the rig or the other, not both. Which one applies is decided by the
/// block's own type, and `SignalEndpointValidator` is what holds the pair apart.
///
/// [pairedBlockId] is what makes a send and a return two halves of one journey out
/// of the board and back - the amplifier's own effects loop, a rack unit, another
/// player's pedal. It is written on both halves so either can be read on its own,
/// and it is nullable because half a pair is a perfectly ordinary thing to have
/// while a rig is still being planned.
///
/// [gear] is the user's own words for what is at the other end, because 'Amp
/// input' does not say which amp. Nothing is derived from it.
class SignalEndpoints extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Cascade: what a block reaches is only a fact about that block, so with the
  /// block gone there is nothing left for the row to describe.
  @ReferenceName('endpoints')
  IntColumn get blockId =>
      integer().references(SignalBlocks, #id, onDelete: KeyAction.cascade)();

  TextColumn get destination => textEnum<SignalDestination>().nullable()();

  TextColumn get source => textEnum<SignalSource>().nullable()();

  /// Set null rather than cascade: losing the return does not make the send stop
  /// existing, it makes it a send with nothing coming back yet.
  @ReferenceName('pairings')
  IntColumn get pairedBlockId => integer().nullable().references(
    SignalBlocks,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// What is actually at the other end, in the user's own words: 'Marshall JVM,
  /// channel 2', 'the desk on stage left'.
  TextColumn get gear => text().withLength(min: 1, max: 120).nullable()();

  TextColumn get notes => text().nullable()();

  /// One row per block: a block reaches one place, and a second row saying it
  /// reaches somewhere else would be a second block.
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {blockId},
  ];
}
