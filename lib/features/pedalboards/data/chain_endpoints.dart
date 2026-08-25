import '../../../core/database/app_database.dart';

/// What one rig's edges reach, asked block by block.
///
/// The rows as stored, with the questions a screen has of them: what does this
/// block reach, what is it paired with, does this rig say where it ends at all.
/// Kept out of the widgets so a card can be handed an answer rather than a table.
///
/// A rig that has never been asked is [none], which is every rig upgraded from
/// before endpoints existed. Scanned rather than indexed on purpose: a rig has a
/// handful of edges and never more, and a list can be const where a map cannot.
class ChainEndpoints {
  const ChainEndpoints(this.endpoints);

  /// A rig that has not said where it starts or finishes.
  static const ChainEndpoints none = ChainEndpoints([]);

  final List<SignalEndpoint> endpoints;

  bool get isEmpty => endpoints.isEmpty;

  /// What [blockId] reaches, or null where the user has not said.
  SignalEndpoint? of(int blockId) {
    for (final endpoint in endpoints) {
      if (endpoint.blockId == blockId) return endpoint;
    }
    return null;
  }

  /// The block at the other end of [blockId]'s trip out of the rig - a return for
  /// a send, a send for a return - or null while it is only half a pair.
  int? pairedWith(int blockId) => of(blockId)?.pairedBlockId;

  /// Whether [blockId] is already half of a pair, and so is not free to join
  /// another one.
  bool isPaired(int blockId) => pairedWith(blockId) != null;

  /// Which block should be read straight after which, for `SignalGraph`.
  ///
  /// Only the half signal leaves at, so the pair reads send-then-return rather
  /// than each one pointing at the other. [blocks] is asked for because the rows
  /// here do not say what type a block is, and only a send or an output is the
  /// going-out half of a pair.
  Map<int, int> orderingAfter(Iterable<SignalBlock> blocks) => {
    for (final block in blocks)
      if (block.blockType.carriesDestination) block.id: ?pairedWith(block.id),
  };

  /// Every block that has been paired, either half. What a picker has to leave
  /// out when it offers a send something to pair with.
  Set<int> get pairedBlockIds => {
    for (final endpoint in endpoints)
      if (endpoint.pairedBlockId != null) ...[
        endpoint.blockId,
        endpoint.pairedBlockId!,
      ],
  };
}
