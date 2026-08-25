import '../../../core/database/app_database.dart';

/// How one rig is wired, asked block by block.
///
/// The cables as stored, with the questions a screen actually has of them: what
/// does this block feed, is it fed by a split, is this rig wired at all. Kept out
/// of the widgets so a card can be handed an answer rather than a table.
///
/// A rig with no cables runs straight through in position order, which is what
/// [none] stands for and what most rigs are.
class ChainRouting {
  const ChainRouting(this.cables);

  /// A rig that has never been wired by hand.
  static const ChainRouting none = ChainRouting([]);

  final List<SignalConnection> cables;

  bool get isWired => cables.isNotEmpty;

  /// The cables out of [blockId], in the order they were run.
  List<SignalConnection> from(int blockId) => [
    for (final cable in cables)
      if (cable.sourceBlockId == blockId) cable,
  ];

  /// The cables into [blockId].
  List<SignalConnection> into(int blockId) => [
    for (final cable in cables)
      if (cable.targetBlockId == blockId) cable,
  ];

  /// How many paths leave [blockId]. More than one is a split, whatever the
  /// block calls itself.
  int pathsFrom(int blockId) => from(blockId).length;
}
