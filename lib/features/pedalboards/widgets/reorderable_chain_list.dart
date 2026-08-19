import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/daos/pedalboard_dao.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import 'chain_slot_tile.dart';

/// A rig's pedals in the order signal reaches them.
///
/// The order is the user's own arrangement rather than anything derived, so it is
/// dragged rather than sorted. Writing is left to the callbacks; this widget only
/// decides what the chain looks like while a write is in flight.
class ReorderableChainList extends StatefulWidget {
  const ReorderableChainList({
    required this.chain,
    required this.onReorder,
    required this.onRemove,
    this.onOpenPedal,
    super.key,
  });

  final List<ChainSlot> chain;

  /// Called with the slot ids in their new signal order.
  final Future<void> Function(List<int> slotIdsInOrder) onReorder;

  final Future<void> Function(int slotId) onRemove;

  final ValueChanged<int>? onOpenPedal;

  @override
  State<ReorderableChainList> createState() => _ReorderableChainListState();
}

class _ReorderableChainListState extends State<ReorderableChainList> {
  late List<ChainSlot> _chain = widget.chain;
  bool _isReordering = false;

  @override
  void didUpdateWidget(covariant ReorderableChainList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A drag shows the new order immediately and writes it afterwards. Until that
    // write lands the database still reports the old order, and adopting it here
    // would bounce every row back under the user's finger.
    if (!_isReordering) {
      _chain = widget.chain;
    }
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    final moved = [..._chain];
    // onReorderItem reports the index the row ends up at, so no adjustment for
    // the row that was just lifted out is needed here.
    moved.insert(newIndex, moved.removeAt(oldIndex));

    setState(() {
      _chain = moved;
      _isReordering = true;
    });

    try {
      await widget.onReorder([for (final entry in moved) entry.slot.id]);
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

  /// Taking a pedal off is not shown ahead of the write: the watching query drops
  /// the row within a frame, and guessing here would leave a chain missing a
  /// pedal it still has if the write failed.
  Future<void> _remove(int slotId) async {
    try {
      await widget.onRemove(slotId);
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      itemCount: _chain.length,
      onReorderItem: _reorder,
      // Every row has a handle of its own, so the list does not add one.
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        final entry = _chain[index];
        final onOpenPedal = widget.onOpenPedal;

        return ChainSlotTile(
          key: ValueKey<int>(entry.slot.id),
          pedal: entry.pedal,
          position: index,
          onTap: _isReordering || onOpenPedal == null
              ? null
              : () => onOpenPedal(entry.pedal.id),
          onRemove: _isReordering ? null : () => _remove(entry.slot.id),
          dragHandle: ChainDragHandle(index: index),
        );
      },
    );
  }
}
