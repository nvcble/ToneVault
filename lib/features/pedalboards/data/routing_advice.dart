import '../../../core/database/app_database.dart';
import '../../../core/database/daos/signal_chain_dao.dart';
import '../../../core/enums/signal_block_type.dart';
import 'chain_block_name.dart';
import 'chain_endpoints.dart';
import 'chain_routing.dart';
import 'signal_graph.dart';

/// One thing worth mentioning about how a rig is wired, and the block it is about.
typedef RoutingNote = ({int blockId, String message});

/// What is odd about a rig's wiring, said plainly and refused nowhere.
///
/// None of this is invalid. A split with one path out is a rig halfway through
/// being built, and a send with nothing paired is a loop the user has not finished
/// describing - both are ordinary states to save and come back to. So these are
/// notes rather than refusals, and a screen shows them without stopping anything.
///
/// Deliberately quiet about a rig with no cables at all: that one runs straight
/// through in position order, where every block is fed by the one before it and
/// there is nothing to point out.
List<RoutingNote> routingAdvice({
  required List<ChainBlock> chain,
  required ChainRouting routing,
  ChainEndpoints endpoints = ChainEndpoints.none,
}) {
  final graph = SignalGraph(
    blockIdsByPosition: [for (final entry in chain) entry.block.id],
    connections: routing.cables,
  );

  return [
    for (final entry in chain)
      ..._notesFor(
        entry: entry,
        chain: chain,
        routing: routing,
        graph: graph,
        endpoints: endpoints,
      ),
  ];
}

Iterable<RoutingNote> _notesFor({
  required ChainBlock entry,
  required List<ChainBlock> chain,
  required ChainRouting routing,
  required SignalGraph graph,
  required ChainEndpoints endpoints,
}) {
  final block = entry.block;
  final name = entry.displayName;
  final type = block.blockType;
  final out = routing.pathsFrom(block.id);
  final into = routing.into(block.id).length;

  final notes = <RoutingNote>[
    if (type == SignalBlockType.send && !endpoints.isPaired(block.id))
      (
        blockId: block.id,
        message:
            '$name has no return paired with it, so nothing says where signal '
            'comes back in.',
      ),
  ];
  // Everything below reads the cables, and a rig with none runs straight through.
  if (!routing.isWired) return notes;

  return notes..addAll([
    if (out == 0 && !type.carriesDestination && !_isLast(block, chain))
      (blockId: block.id, message: '$name does not feed anything yet.'),
    if (into == 0 && !type.carriesSource && !_isFirst(block, chain))
      (blockId: block.id, message: 'Nothing feeds $name yet.'),
    if (type == SignalBlockType.split && out < 2)
      (
        blockId: block.id,
        message: '$name is a split, but only one path leaves it.',
      ),
    if (type == SignalBlockType.merge && into < 2)
      (
        blockId: block.id,
        message: '$name is a merge, but only one path arrives at it.',
      ),
    if (out > 1 && !_comesBackTogether(block.id, routing, graph))
      (
        blockId: block.id,
        message:
            'The $out paths out of $name never come back together, so they '
            'reach the end of the rig separately.',
      ),
  ]);
}

/// The block signal starts at, which nothing is expected to feed, and the one it
/// stops at, which is not expected to feed anything.
///
/// Taken from where the block sits in the chain rather than from the cables,
/// because an end fed by nothing is exactly the case being tested for. A rig does
/// not have to hold an input and an output block to be finished: plenty stop at
/// whatever the last pedal is.
bool _isFirst(SignalBlock block, List<ChainBlock> chain) =>
    chain.isNotEmpty && chain.first.block.id == block.id;

bool _isLast(SignalBlock block, List<ChainBlock> chain) =>
    chain.isNotEmpty && chain.last.block.id == block.id;

/// Whether the paths out of [blockId] arrive at a block with more than one cable
/// into it - a merge, whether or not the user called it one.
bool _comesBackTogether(int blockId, ChainRouting routing, SignalGraph graph) {
  final pending = [...graph.nextOf(blockId)];
  final seen = pending.toSet();

  while (pending.isNotEmpty) {
    final current = pending.removeLast();
    if (routing.into(current).length > 1) return true;
    for (final next in graph.nextOf(current)) {
      if (seen.add(next)) pending.add(next);
    }
  }
  return false;
}
