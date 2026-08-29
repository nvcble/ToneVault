import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

/// One of the short lists a lesson carries under its text: what players get wrong at
/// it, or what to do while practising it.
///
/// The two are the same shape and are drawn by the same widget, so they cannot drift
/// apart on screen. What differs is the heading and the icon, which is what tells a
/// player at a glance whether they are reading a warning or a suggestion.
///
/// Empty is nothing rather than a heading with a gap under it. Not every lesson has
/// mistakes worth naming, and a piece of reading has neither.
class LessonNoteList extends StatelessWidget {
  const LessonNoteList({
    required this.title,
    required this.icon,
    required this.notes,
    super.key,
  });

  final String title;
  final IconData icon;
  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: theme.textTheme.titleSmall),
            ],
          ),
          for (final note in notes)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                top: AppSpacing.xs,
              ),
              child: Text('• $note', style: theme.textTheme.bodyMedium),
            ),
        ],
      ),
    );
  }
}
