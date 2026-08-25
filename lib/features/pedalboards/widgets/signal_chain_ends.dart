import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

/// Where a chain starts and where it stops, while the rig has not said.
///
/// Drawn rather than stored: every rig begins at an instrument and ends at
/// something that makes a noise, so a row saying so would be a row the user has
/// to keep and could delete by mistake. It is only a guess, though, and `chainFrame`
/// drops whichever end the rig has answered for itself with a block.
///
/// The far end is not called the amp. Plenty of rigs finish at a desk, an
/// interface or a pair of headphones, and naming one of them would be the app
/// deciding what the user plays through.
///
/// [onTap] offers to make this end a block of its own, which is the only way to
/// say anything more about it than the guess.
class SignalChainEnd extends StatelessWidget {
  const SignalChainEnd({required this.isStart, this.onTap, super.key});

  final bool isStart;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.outline;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isStart ? Icons.music_note : Icons.speaker,
              size: 18,
              color: color,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              isStart ? 'Guitar' : 'Wherever this goes',
              style: theme.textTheme.labelMedium?.copyWith(color: color),
            ),
            if (onTap != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Icon(Icons.add, size: 16, color: color),
            ],
          ],
        ),
      ),
    );
  }
}
