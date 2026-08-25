import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/enums/pedal_status.dart';
import '../data/chain_block_name.dart';
import 'signal_block_style.dart';

/// One block of a rig's chain, numbered by where signal reaches it.
///
/// The block leads and the pedal follows: the type is what the user laid out and
/// the pedal is what they later put in it, so an empty block reads as a place
/// waiting to be filled rather than as a row with something missing.
///
/// Bypassed is drawn faded rather than hidden, because a bypassed block is still
/// on the board and still takes its turn in the chain.
class SignalBlockCard extends StatelessWidget {
  const SignalBlockCard({
    required this.block,
    required this.pedal,
    required this.position,
    this.edge,
    this.onTap,
    this.dragHandle,
    super.key,
  });

  final SignalBlock block;

  /// What is in the block, or null while it is still only a plan.
  final Pedal? pedal;

  /// Zero-based, as stored; shown counting from one, as it would be read out.
  final int position;

  /// Where the rig leaves off at this block, in one line, or null for the blocks
  /// in the middle of a chain - which is most of them.
  final String? edge;

  final VoidCallback? onTap;

  /// Supplied by the canvas, which is the only thing that knows about dragging.
  final Widget? dragHandle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = SignalBlockStyle.of(block.blockType);
    final isPlanned = pedal == null;

    return Opacity(
      opacity: block.isEnabled ? 1 : 0.5,
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        // A block with nothing in it is drawn as an outline: a space the user has
        // set aside, rather than a card pretending to hold gear.
        elevation: isPlanned ? 0 : null,
        color: isPlanned ? Colors.transparent : null,
        shape: isPlanned
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              )
            : null,
        child: ListTile(
          leading: _Badge(
            position: position,
            style: style,
            isPlanned: isPlanned,
          ),
          title: Text(_title(), overflow: TextOverflow.ellipsis),
          subtitle: _buildSubtitle(theme),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!block.isEnabled)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: Icon(
                    Icons.flash_off_outlined,
                    size: 18,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ?dragHandle,
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  /// What the user called this block, falling back to what it is for.
  String _title() => (block: block, pedal: pedal).displayName;

  /// Under the title: what the block is, and then where the rig leaves off if it
  /// is one of the ends. Two lines rather than one long one, and the edge is
  /// tinted, because where a rig goes is what the user came to this card to read.
  Widget? _buildSubtitle(ThemeData theme) {
    final subtitle = _subtitle();
    if (subtitle == null && edge == null) return null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subtitle != null)
          Text(
            subtitle,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        if (edge case final edge?)
          Text(
            edge,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
      ],
    );
  }

  /// The line under the title, which says whatever the title did not: what the
  /// block is for, what is in it, and anything about that pedal worth knowing
  /// before a gig. Null where the title already said all of it.
  String? _subtitle() {
    final title = _title();
    final inside = pedal;
    final parts = [
      if (title != block.blockType.label) block.blockType.label,
      if (inside == null)
        'Empty'
      else ...[
        if (title != inside.name) inside.name,
        ?inside.brand,
        if (inside.status != PedalStatus.active) inside.status.label,
      ],
    ];

    return parts.isEmpty ? null : parts.join(' · ');
  }
}

/// The block's place in the chain, in the colour of what it does.
class _Badge extends StatelessWidget {
  const _Badge({
    required this.position,
    required this.style,
    required this.isPlanned,
  });

  final int position;
  final SignalBlockStyle style;

  /// Kept in the colour of what the block does either way, only fainter: the
  /// chain is read by colour, and a planned block is still a delay.
  final bool isPlanned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: style.color.withValues(
            alpha: isPlanned ? 0.08 : 0.18,
          ),
          child: Icon(style.icon, size: 20, color: style.color),
        ),
        // On the corner of the icon rather than beside it, so the row leads with
        // what the block does and still says where in the chain it sits.
        CircleAvatar(
          radius: 8,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: Text(
            '${position + 1}',
            style: theme.textTheme.labelSmall,
            textScaler: TextScaler.noScaling,
          ),
        ),
      ],
    );
  }
}

/// The drag affordance for a block.
///
/// The card itself opens the block, so dragging gets a handle of its own rather
/// than a long press that would fight the tap.
class SignalBlockDragHandle extends StatelessWidget {
  const SignalBlockDragHandle({required this.index, super.key});

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
