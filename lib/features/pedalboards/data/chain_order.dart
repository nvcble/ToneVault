import '../../../core/database/daos/signal_chain_dao.dart';
import 'chain_endpoints.dart';
import 'signal_graph.dart';

/// One rig's blocks in the order signal reaches them.
///
/// The rows arrive in position order and `SignalGraph` has the last word, which
/// for a rig with no cables in it is the same thing. A send paired with a return
/// is handed over as an ordering hint, so a rig out through an amplifier's effects
/// loop reads in the order it is patched without a cable being invented for the
/// part of the trip that happens off the board.
///
/// One function rather than one per caller, because the chain drawn on screen and
/// the chain a snapshot records have to be the same reading. A snapshot built from
/// position order would file a wired rig in an order the user never saw.
List<ChainBlock> chainInSignalOrder(ChainRows rows) {
  final graph = SignalGraph(
    blockIdsByPosition: [for (final row in rows.blocks) row.block.id],
    connections: rows.cables,
    follows: ChainEndpoints(
      rows.endpoints,
    ).orderingAfter([for (final row in rows.blocks) row.block]),
  );

  final byId = {for (final row in rows.blocks) row.block.id: row};
  return [for (final id in graph.order) byId[id]!];
}
