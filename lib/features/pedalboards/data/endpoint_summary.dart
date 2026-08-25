import '../../../core/database/app_database.dart';
import '../../../core/database/daos/signal_chain_dao.dart';
import 'chain_block_name.dart';
import 'chain_endpoints.dart';

/// What each edge of a rig reaches, one line per block, by block id.
///
/// Worked out here rather than in the card so the wording is testable without a
/// widget, and so a card is handed a sentence rather than a table to interpret.
/// Blocks with nothing said about them are simply absent, which a card reads as
/// one line fewer rather than as an empty one.
Map<int, String> endpointSummaries({
  required List<ChainBlock> chain,
  required ChainEndpoints endpoints,
}) {
  if (endpoints.isEmpty) return const {};

  final names = {for (final entry in chain) entry.block.id: entry.displayName};

  return {
    for (final entry in chain)
      entry.block.id: ?_lineFor(entry, endpoints.of(entry.block.id), names),
  };
}

/// The line for one edge: which way it faces, what is at the other end of it, and
/// where the trip out of the rig picks up again.
String? _lineFor(
  ChainBlock entry,
  SignalEndpoint? edge,
  Map<int, String> names,
) {
  if (edge == null) return null;
  final paired = edge.pairedBlockId;
  final pairedName = paired == null ? null : names[paired];

  final parts = [
    if (edge.destination case final destination?) 'To ${destination.label}',
    if (edge.source case final source?) 'From ${source.label}',
    ?edge.gear,
    // Named from this block's point of view, because a send and its return say
    // opposite halves of the same trip.
    if (pairedName != null)
      entry.block.blockType.carriesDestination
          ? 'back in at $pairedName'
          : 'sent out at $pairedName',
  ];

  return parts.isEmpty ? null : parts.join(' · ');
}
