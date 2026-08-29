import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../data/lesson_tally.dart';

/// How far through something the player is: a bar, and the count in words under it.
///
/// Both, rather than one or the other. The bar is what a player takes in without
/// reading, and the count is what tells them whether the remaining third is two
/// lessons or twenty.
///
/// A tally with nothing in it draws nothing at all. A level whose courses have not
/// been loaded, or one that ships empty, has no progress to be at the start of, and
/// an empty bar there would read as "you have done none of this" rather than "there
/// is none of this".
class TallyBar extends StatelessWidget {
  const TallyBar({required this.tally, super.key});

  /// Null while the count is still being read, which draws nothing.
  final LessonTally? tally;

  @override
  Widget build(BuildContext context) {
    final tally = this.tally;
    if (tally == null || tally.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          // Rounded, because a bar with square ends inside a rounded card is the
          // one thing on the screen that looks unfinished.
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          child: LinearProgressIndicator(
            value: tally.fraction,
            minHeight: AppSpacing.xs,
            // The complete state is worth its own colour: a player scanning a level
            // for what is left should not have to read the numbers.
            color: tally.isComplete
                ? theme.colorScheme.tertiary
                : theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          tally.label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
