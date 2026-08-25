import '../../../core/database/daos/signal_chain_dao.dart';
import '../../../core/enums/signal_destination.dart';
import '../../../core/enums/signal_source.dart';
import 'chain_endpoints.dart';

/// A handful of destinations under a heading that says what kind of thing they
/// are.
typedef DestinationGroup = ({
  String heading,
  List<SignalDestination> destinations,
});

/// A block a send could come back through, and whether it is already spoken for.
typedef PairCandidate = ({ChainBlock block, bool isTaken});

/// Where signal can leave a rig, grouped the way a guitarist would think of it.
///
/// The two amplifier sockets are deliberately side by side under one heading: they
/// are the pair most easily muddled, and seeing them together is what makes the
/// difference between the front of an amp and the far side of its loop obvious.
///
/// Flat enum order would put the desk between them, so the grouping is written
/// out here rather than derived. The test holds it to covering every value once,
/// which is what stops a destination added later going unofferable.
const List<DestinationGroup> destinationGroups = [
  (
    heading: 'An amplifier',
    destinations: [
      SignalDestination.physicalAmpInput,
      SignalDestination.physicalAmpFxReturn,
    ],
  ),
  (
    heading: 'A desk or a computer',
    destinations: [
      SignalDestination.foh,
      SignalDestination.audioInterface,
      SignalDestination.di,
    ],
  ),
  (
    heading: 'Something to listen through',
    destinations: [SignalDestination.monitor, SignalDestination.headphones],
  ),
  (
    heading: 'Anything else',
    destinations: [SignalDestination.externalDevice, SignalDestination.custom],
  ),
];

/// Where signal can arrive from, in one list: there are few enough that headings
/// would be more to read rather than less.
const List<SignalSource> sourceChoices = SignalSource.values;

/// What [sendBlockId] could come back through.
///
/// Every return and input on the rig, because a rig can have several loops and the
/// app has no way of knowing which return belongs to which send. One already in
/// another pair is offered anyway, marked, so a user who is rearranging their
/// loops can see where the return they want has gone rather than find it missing.
List<PairCandidate> pairCandidates({
  required List<ChainBlock> chain,
  required ChainEndpoints endpoints,
  required int sendBlockId,
}) {
  final taken = endpoints.pairedBlockIds;
  final alreadyPaired = endpoints.pairedWith(sendBlockId);

  return [
    for (final entry in chain)
      if (entry.block.blockType.carriesSource && entry.block.id != sendBlockId)
        (
          block: entry,
          isTaken:
              taken.contains(entry.block.id) && entry.block.id != alreadyPaired,
        ),
  ];
}
