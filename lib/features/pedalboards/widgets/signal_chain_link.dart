import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

/// The cable into a block, showing which way signal runs.
///
/// Drawn on the block it feeds rather than between the items of the list, so it
/// travels with the card while that card is dragged instead of leaving an arrow
/// pointing at a gap.
///
/// One arrow per block. A block fed by a split gets a branching arrow instead of
/// a straight one, which is what says the card above it is not what feeds it, and
/// [label] names the path where there is more than one to tell apart.
class SignalChainLink extends StatelessWidget {
  const SignalChainLink({
    required this.axis,
    this.isParallel = false,
    this.label,
    super.key,
  });

  final Axis axis;

  /// Whether signal reaches the block below on a parallel cable.
  final bool isParallel;

  /// Which path this is, on the block that starts one. Null anywhere the arrow
  /// alone already says enough.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRow = axis == Axis.horizontal;
    final color = theme.colorScheme.outline;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isRow ? AppSpacing.xs : 0,
        vertical: isRow ? 0 : AppSpacing.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isParallel
                ? Icons.subdirectory_arrow_right
                : (isRow ? Icons.chevron_right : Icons.expand_more),
            size: 18,
            color: color,
          ),
          if (label case final label?) ...[
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ],
      ),
    );
  }
}
