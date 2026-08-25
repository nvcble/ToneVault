import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

/// The note under a block that sends signal down more than one path.
///
/// A chain in series needs nothing here: the arrows already say what follows
/// what. This is only drawn where a block splits, because that is the one thing
/// a list of cards cannot show by its order alone.
class RoutingIndicator extends StatelessWidget {
  const RoutingIndicator({required this.paths, super.key});

  /// How many cables leave the block. Below two there is nothing to say.
  final int paths;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (paths < 2) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.md,
        bottom: AppSpacing.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.call_split,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Feeds $paths paths',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
