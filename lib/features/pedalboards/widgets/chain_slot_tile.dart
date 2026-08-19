import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/enums/pedal_status.dart';

/// One pedal in a rig's chain, numbered by where signal reaches it.
class ChainSlotTile extends StatelessWidget {
  const ChainSlotTile({
    required this.pedal,
    required this.position,
    this.onTap,
    this.onRemove,
    this.dragHandle,
    super.key,
  });

  final Pedal pedal;

  /// Zero-based, as stored; shown counting from one, as it would be read out.
  final int position;

  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  /// Supplied by the list, which is the only thing that knows about dragging.
  final Widget? dragHandle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = _subtitle();

    return ListTile(
      leading: CircleAvatar(
        radius: 14,
        child: Text('${position + 1}', style: theme.textTheme.labelMedium),
      ),
      title: Text(pedal.name, overflow: TextOverflow.ellipsis),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            tooltip: 'Take off the rig',
            onPressed: onRemove,
          ),
          ?dragHandle,
        ],
      ),
      onTap: onTap,
    );
  }

  /// Whose pedal it is, and anything about it worth knowing before a gig. An
  /// active pedal says nothing, since that is every pedal's normal state.
  String? _subtitle() {
    final parts = [
      ?pedal.brand,
      if (pedal.status != PedalStatus.active) pedal.status.label,
    ];

    return parts.isEmpty ? null : parts.join(' · ');
  }
}

/// The drag affordance for a chain row.
///
/// The row itself opens the pedal, so dragging gets a handle of its own rather
/// than a long press that would fight the tap.
class ChainDragHandle extends StatelessWidget {
  const ChainDragHandle({required this.index, super.key});

  final int index;

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: index,
      child: const Padding(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: Icon(Icons.drag_handle),
      ),
    );
  }
}
