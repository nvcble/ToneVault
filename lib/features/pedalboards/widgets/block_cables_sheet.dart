import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/daos/signal_chain_dao.dart';
import '../../../core/enums/signal_block_type.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/block_cable_choices.dart';
import '../data/chain_block_name.dart';
import '../data/chain_routing.dart';
import '../data/signal_routing_repository.dart';
import '../providers/pedalboard_providers.dart';
import 'sheet_note.dart';

/// What one block feeds, and what else on the rig it could feed.
///
/// Running a second cable out of a block is what makes a rig parallel, so this
/// stays open after each one: a split is two cables, and closing after the first
/// would make the common case the awkward one.
///
/// A cable the graph would refuse is still listed, greyed, with the reason. A
/// block that has quietly gone missing from the list is worse than one that says
/// why it cannot be reached.
///
/// A merge is asked the question from both ends. What joins up at it is the whole
/// reason it is on the rig, and going back to each path in turn to point it here
/// would be describing the rig the long way round.
class BlockCablesSheet extends ConsumerStatefulWidget {
  const BlockCablesSheet({
    required this.pedalboardId,
    required this.sourceBlockId,
    super.key,
  });

  final int pedalboardId;

  /// The block the sheet is about, which for a merge is also where the cables it
  /// offers arrive.
  final int sourceBlockId;

  @override
  ConsumerState<BlockCablesSheet> createState() => _BlockCablesSheetState();
}

class _BlockCablesSheetState extends ConsumerState<BlockCablesSheet> {
  bool _isSaving = false;

  /// The repository is reached for only when something is written, so drawing the
  /// sheet asks nothing of the database.
  Future<void> _run(
    Future<void> Function(SignalRoutingRepository routing) write,
  ) async {
    setState(() => _isSaving = true);

    try {
      await write(ref.read(signalRoutingRepositoryProvider));
    } catch (error) {
      if (mounted) showFailureSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chain =
        ref.watch(signalChainProvider(widget.pedalboardId)).valueOrNull ??
        const <ChainBlock>[];
    final routing =
        ref.watch(signalRoutingProvider(widget.pedalboardId)).valueOrNull ??
        ChainRouting.none;

    final isMerge = chain.any(
      (entry) =>
          entry.block.id == widget.sourceBlockId &&
          entry.block.blockType == SignalBlockType.merge,
    );

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              isMerge ? 'What joins up here?' : 'Where does this go next?',
              style: theme.textTheme.titleMedium,
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                if (isMerge)
                  ..._arrivals(
                    mergeChoices(
                      chain: chain,
                      routing: routing,
                      mergeBlockId: widget.sourceBlockId,
                    ),
                  ),
                ..._feeds(
                  cableChoices(
                    chain: chain,
                    routing: routing,
                    sourceBlockId: widget.sourceBlockId,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The paths that come back together at a merge, and what else could join them.
  List<Widget> _arrivals(MergeChoices choices) {
    return [
      if (choices.arrivals.isEmpty)
        const SheetNote(
          'Nothing joins up here yet. Pick the paths that come back together, '
          'and the rig reads as one again from here on.',
        ),
      for (final arrival in choices.arrivals)
        ListTile(
          leading: const Icon(Icons.call_merge),
          title: Text(
            arrival.source.displayName,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.link_off),
            tooltip: 'Remove this cable',
            onPressed: _isSaving
                ? null
                : () => _run((routing) => routing.disconnect(arrival.cable.id)),
          ),
        ),
      if (choices.candidates.isNotEmpty) ...[
        const SheetNote('Join a path from'),
        for (final candidate in choices.candidates)
          ListTile(
            leading: const Icon(Icons.add_link),
            title: Text(
              candidate.block.displayName,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: candidate.refusal == null
                ? null
                : Text(candidate.refusal!),
            enabled: candidate.refusal == null && !_isSaving,
            onTap: () => _run(
              (routing) => routing.connect(
                sourceBlockId: candidate.block.block.id,
                targetBlockId: widget.sourceBlockId,
              ),
            ),
          ),
      ],
      const Divider(),
    ];
  }

  /// What the block feeds, and what else on the rig it could feed.
  List<Widget> _feeds(CableChoices choices) {
    return [
      // Nothing wired is the ordinary case, and it is not an empty state: the
      // rig runs in the order it is laid out until a cable says otherwise.
      if (choices.feeds.isEmpty)
        const SheetNote(
          'No cables from this block, so signal carries on to whatever is '
          'next in line. Run one to send it somewhere else as well.',
        ),
      for (final feed in choices.feeds)
        ListTile(
          leading: const Icon(Icons.east),
          title: Text(feed.target.displayName, overflow: TextOverflow.ellipsis),
          trailing: IconButton(
            icon: const Icon(Icons.link_off),
            tooltip: 'Remove this cable',
            onPressed: _isSaving
                ? null
                : () => _run((routing) => routing.disconnect(feed.cable.id)),
          ),
        ),
      if (choices.candidates.isNotEmpty) ...[
        const Divider(),
        const SheetNote('Add a cable to'),
        for (final candidate in choices.candidates)
          ListTile(
            leading: const Icon(Icons.add_link),
            title: Text(
              candidate.block.displayName,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: candidate.refusal == null
                ? null
                : Text(candidate.refusal!),
            enabled: candidate.refusal == null && !_isSaving,
            onTap: () => _run(
              (routing) => routing.connect(
                sourceBlockId: widget.sourceBlockId,
                targetBlockId: candidate.block.block.id,
              ),
            ),
          ),
      ],
    ];
  }
}
