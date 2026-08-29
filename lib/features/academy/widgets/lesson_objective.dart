import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

/// What the player will be able to do at the end of the lesson, above its text.
///
/// Set apart from the body rather than written as its first line, because it is read
/// differently: it is the reason to read the rest, and a player deciding whether to
/// spend twenty minutes here wants it in one glance.
///
/// Nothing at all where the lesson does not say. A lesson written before the app
/// asked for an objective is still a lesson, and an empty box above it would be the
/// app pointing at its own gap.
class LessonObjective extends StatelessWidget {
  const LessonObjective({required this.objective, super.key});

  final String? objective;

  @override
  Widget build(BuildContext context) {
    final text = objective;
    if (text == null || text.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.flag_outlined, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What this is for',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(text, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
