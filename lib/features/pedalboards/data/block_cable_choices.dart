import '../../../core/database/app_database.dart';
import '../../../core/database/daos/signal_chain_dao.dart';
import 'chain_routing.dart';
import 'routing_rules.dart';
import 'signal_graph.dart';

/// One cable already run out of a block, with the block at the far end of it.
typedef CableFeed = ({SignalConnection cable, ChainBlock target});

/// One cable arriving at a block, with the block it comes from.
typedef CableArrival = ({SignalConnection cable, ChainBlock source});

/// What already joins up at a block, and what else could.
typedef MergeChoices = ({
  List<CableArrival> arrivals,
  List<CableCandidate> candidates,
});

/// A block a cable could be run to, and why it could not where it cannot.
typedef CableCandidate = ({ChainBlock block, String? refusal});

/// What a block feeds today, and what it could feed next.
typedef CableChoices = ({
  List<CableFeed> feeds,
  List<CableCandidate> candidates,
});

/// Which of the rig's blocks [sourceBlockId] already feeds, and which are left.
///
/// A block it already feeds is listed once, under [feeds], rather than twice with
/// the second one greyed. Everything else on the rig is a candidate, carrying
/// whatever `RoutingRules` would refuse it for - a cable that would send signal
/// back into itself is offered greyed with the reason, which is more use than
/// leaving the user to guess why a block is missing.
///
/// The repository refuses all of this again on the way in; this is only what the
/// sheet offers, so the user is not led into a refusal.
CableChoices cableChoices({
  required List<ChainBlock> chain,
  required ChainRouting routing,
  required int sourceBlockId,
}) {
  final byId = {for (final entry in chain) entry.block.id: entry};
  final graph = _graphOf(chain, routing);

  final feeds = <CableFeed>[];
  for (final cable in routing.from(sourceBlockId)) {
    if (byId[cable.targetBlockId] case final target?) {
      feeds.add((cable: cable, target: target));
    }
  }

  final source = byId[sourceBlockId]?.block;
  final fed = {for (final feed in feeds) feed.target.block.id};
  final candidates = <CableCandidate>[
    for (final entry in chain)
      if (entry.block.id != sourceBlockId && !fed.contains(entry.block.id))
        (
          block: entry,
          refusal: source == null
              ? null
              : RoutingRules.refusalFor(
                  source: source,
                  target: entry.block,
                  graph: graph,
                ),
        ),
  ];

  return (feeds: feeds, candidates: candidates);
}

/// Which of the rig's blocks already arrive at [mergeBlockId], and which could.
///
/// The same question as [cableChoices] asked from the other end, and the only
/// place a cable is described backwards. A merge is what the user thinks of as
/// "these paths join here", so being made to go back to each path in turn and
/// point it at the merge would be describing the rig the long way round.
MergeChoices mergeChoices({
  required List<ChainBlock> chain,
  required ChainRouting routing,
  required int mergeBlockId,
}) {
  final byId = {for (final entry in chain) entry.block.id: entry};
  final graph = _graphOf(chain, routing);

  final arrivals = <CableArrival>[];
  for (final cable in routing.into(mergeBlockId)) {
    if (byId[cable.sourceBlockId] case final source?) {
      arrivals.add((cable: cable, source: source));
    }
  }

  final target = byId[mergeBlockId]?.block;
  final joined = {for (final arrival in arrivals) arrival.source.block.id};
  final candidates = <CableCandidate>[
    for (final entry in chain)
      if (entry.block.id != mergeBlockId && !joined.contains(entry.block.id))
        (
          block: entry,
          refusal: target == null
              ? null
              : RoutingRules.refusalFor(
                  source: entry.block,
                  target: target,
                  graph: graph,
                ),
        ),
  ];

  return (arrivals: arrivals, candidates: candidates);
}

SignalGraph _graphOf(List<ChainBlock> chain, ChainRouting routing) {
  return SignalGraph(
    blockIdsByPosition: [for (final entry in chain) entry.block.id],
    connections: routing.cables,
  );
}
