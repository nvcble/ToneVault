import '../../../core/database/daos/signal_chain_dao.dart';
import '../../../core/enums/signal_connection_type.dart';
import 'chain_routing.dart';

/// Where one block sits among a rig's paths: how far off the main line it is, and
/// which path it starts, if it starts one.
typedef BranchPlacement = ({int depth, String? label});

/// Which path each block of [chain] is on, for a list of cards to set out.
///
/// A list can only be read top to bottom, so a rig with three paths out of one
/// block would otherwise read as one long chain that happens to be wired oddly.
/// Setting each path in by its own step, and naming the block that starts it,
/// is what makes the three read as three.
///
/// [chain] has to arrive in signal order - which is what `SignalGraph` hands
/// back - because a block's place is worked out from the block feeding it, and
/// that one is read first.
///
/// Blocks on the main line are left out rather than given a depth of nought: most
/// rigs are one path from end to end, and nothing about them needs setting in.
Map<int, BranchPlacement> branchPlacements({
  required List<ChainBlock> chain,
  required ChainRouting routing,
}) {
  if (!routing.isWired) return const {};

  final placements = <int, BranchPlacement>{};
  int depthOf(int blockId) => placements[blockId]?.depth ?? 0;

  for (final entry in chain) {
    final blockId = entry.block.id;
    final arriving = routing.into(blockId);

    // Paths coming back together: back out to the shallowest of them, so a merge
    // reads as the end of the branching rather than as another branch of it.
    if (arriving.length > 1) {
      final depth = arriving
          .map((cable) => depthOf(cable.sourceBlockId))
          .reduce((a, b) => a < b ? a : b);
      if (depth > 0) placements[blockId] = (depth: depth, label: null);
      continue;
    }
    if (arriving.length != 1) continue;

    final cable = arriving.single;
    final depth = depthOf(cable.sourceBlockId);

    if (cable.connectionType == SignalConnectionType.parallel) {
      // Numbered by which cable out of the split it is, so the labels match the
      // order the user ran them in.
      final paths = routing.from(cable.sourceBlockId);
      final path = paths.indexWhere((run) => run.id == cable.id) + 1;
      placements[blockId] = (depth: depth + 1, label: 'Path $path');
    } else if (depth > 0) {
      // Carrying on down the same path, which needs no second label.
      placements[blockId] = (depth: depth, label: null);
    }
  }

  return placements;
}
