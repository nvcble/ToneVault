import '../../../core/database/daos/signal_chain_dao.dart';

/// Which of the drawn ends a chain still needs around it.
typedef ChainFrame = ({bool drawsStart, bool drawsEnd});

/// Whether the guitar and the far end still have to be drawn around [chain].
///
/// Both are drawn rather than stored, because every rig begins at an instrument
/// and finishes at something that makes a noise, and a row saying so would be a
/// row the user has to keep and could delete by mistake. A rig that has said it
/// for itself - an input block fed from an amplifier's send, an output block into
/// a desk - has said it better than a guess could, so the frame steps aside at
/// that end and leaves the other one alone.
///
/// Only the two ends of the chain are read. A send in the middle of a rig through
/// an amplifier's loop says where that trip goes rather than where the rig
/// finishes, so it changes nothing here.
ChainFrame chainFrame(List<ChainBlock> chain) {
  if (chain.isEmpty) return (drawsStart: true, drawsEnd: true);

  return (
    drawsStart: !chain.first.block.blockType.carriesSource,
    drawsEnd: !chain.last.block.blockType.carriesDestination,
  );
}
