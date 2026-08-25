import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/daos/signal_chain_dao.dart';
import '../../../core/enums/signal_block_type.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/chain_branches.dart';
import '../data/chain_frame.dart';
import '../data/chain_routing.dart';
import 'routing_indicator.dart';
import 'signal_block_card.dart';
import 'signal_chain_ends.dart';
import 'signal_chain_link.dart';

/// A rig's blocks in the order signal reaches them, laid out end to end.
///
/// The order is the user's own arrangement rather than anything derived, so it is
/// dragged rather than sorted. Writing is left to the callbacks; this widget only
/// decides what the chain looks like while a write is in flight, which is what
/// lets a drag be tested without a database.
///
/// Vertical on a phone and horizontal on a tablet: the same list either way, so
/// the two layouts cannot drift apart.
class SignalChainCanvas extends StatefulWidget {
  const SignalChainCanvas({
    required this.chain,
    required this.onReorder,
    required this.onOpenBlock,
    this.routing = ChainRouting.none,
    this.edges = const {},
    this.onAddEnd,
    super.key,
  });

  final List<ChainBlock> chain;

  /// The cables, if any have been run. A rig with none is a straight line, which
  /// is what the order alone already says.
  final ChainRouting routing;

  /// What the edges of the rig reach, by block id, already worded by
  /// `endpointSummaries`. Blocks that have not been asked are simply absent.
  final Map<int, String> edges;

  /// Called with the block ids in their new signal order.
  final Future<void> Function(List<int> blockIdsInOrder) onReorder;

  final ValueChanged<ChainBlock> onOpenBlock;

  /// Called with the type a drawn end offers to become, when one is tapped. A
  /// guessed end can only be described once it is a block of its own.
  final ValueChanged<SignalBlockType>? onAddEnd;

  /// Above this width the chain is drawn as a row, which is how a pedalboard is
  /// actually seen. Below it there is no room for more than one card abreast.
  static const double horizontalFrom = 700;

  @override
  State<SignalChainCanvas> createState() => _SignalChainCanvasState();
}

class _SignalChainCanvasState extends State<SignalChainCanvas> {
  late List<ChainBlock> _chain = widget.chain;
  bool _isReordering = false;

  @override
  void didUpdateWidget(covariant SignalChainCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A drag shows the new order immediately and writes it afterwards. Until that
    // write lands the database still reports the old order, and adopting it here
    // would bounce every card back under the user's finger.
    if (!_isReordering) {
      _chain = widget.chain;
    }
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    final moved = [..._chain];
    // onReorderItem reports the index the card ends up at, so no adjustment for
    // the one that was just lifted out is needed here.
    moved.insert(newIndex, moved.removeAt(oldIndex));

    setState(() {
      _chain = moved;
      _isReordering = true;
    });

    try {
      await widget.onReorder([for (final entry in moved) entry.block.id]);
    } catch (error) {
      if (mounted) {
        // Put the chain back the way the database still has it.
        setState(() => _chain = widget.chain);
        showFailureSnackBar(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _isReordering = false);
      }
    }
  }

  /// What tapping a drawn end does, or nothing while a drag is being written and
  /// the chain on screen is ahead of the database.
  VoidCallback? _addingEnd(SignalBlockType blockType) {
    final add = widget.onAddEnd;
    if (add == null || _isReordering) return null;
    return () => add(blockType);
  }

  /// How a card looks while it is under the user's finger: lifted off the board
  /// and slightly larger, so it is clear which one is moving and which one it is
  /// moving past.
  Widget _lifted(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, decorated) {
        final lift = Curves.easeOut.transform(animation.value);

        return Transform.scale(
          scale: 1 + 0.04 * lift,
          child: Material(
            color: Colors.transparent,
            elevation: 8 * lift,
            child: decorated,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isRow = constraints.maxWidth >= SignalChainCanvas.horizontalFrom;
        final frame = chainFrame(_chain);
        final placements = branchPlacements(
          chain: _chain,
          routing: widget.routing,
        );

        return ReorderableListView.builder(
          scrollDirection: isRow ? Axis.horizontal : Axis.vertical,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          itemCount: _chain.length,
          onReorderItem: _reorder,
          // Every card has a handle of its own, so the list does not add one.
          buildDefaultDragHandles: false,
          // Neither end is a block the user put here, so both are drawn as the
          // ends of the list rather than stored as rows in it - and only for as
          // long as the rig has not said better for itself.
          header: frame.drawsStart
              ? SignalChainEnd(
                  isStart: true,
                  onTap: _addingEnd(SignalBlockType.input),
                )
              : null,
          footer: frame.drawsEnd
              ? SignalChainEnd(
                  isStart: false,
                  onTap: _addingEnd(SignalBlockType.output),
                )
              : null,
          proxyDecorator: _lifted,
          itemBuilder: (context, index) {
            final entry = _chain[index];
            final axis = isRow ? Axis.horizontal : Axis.vertical;

            final blockId = entry.block.id;
            final placement = placements[blockId];

            return Flex(
              key: ValueKey<int>(blockId),
              direction: axis,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (index > 0)
                  SignalChainLink(
                    axis: axis,
                    isParallel: placement?.label != null,
                    label: placement?.label,
                  ),
                SizedBox(
                  width: isRow ? 260 : null,
                  child: Padding(
                    // Every path is set in a step further than the one it came
                    // off, so three paths read as three rather than as one long
                    // chain wired oddly.
                    padding: EdgeInsets.only(
                      left: isRow ? 0 : AppSpacing.lg * (placement?.depth ?? 0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SignalBlockCard(
                          block: entry.block,
                          pedal: entry.pedal,
                          position: index,
                          edge: widget.edges[blockId],
                          onTap: _isReordering
                              ? null
                              : () => widget.onOpenBlock(entry),
                          dragHandle: SignalBlockDragHandle(index: index),
                        ),
                        RoutingIndicator(
                          paths: widget.routing.pathsFrom(blockId),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
