import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../data/ear_session.dart';

/// What it was, once the question has been answered.
///
/// Shown for a wrong answer and a right one alike. A drill that says nothing when the
/// player guesses correctly teaches them that guessing works; the spelling of the chord
/// is what turns a lucky tap into something learned.
class EarAnswerCard extends StatelessWidget {
  const EarAnswerCard({required this.session, required this.onNext, super.key});

  final EarSession session;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final right = session.wasRight;

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  right ? Icons.check_circle_outline : Icons.cancel_outlined,
                  color: right ? Colors.green : theme.colorScheme.error,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  right ? 'That is it' : 'Not this time',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              session.question.explanation,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onNext, child: const Text('Next question')),
          ],
        ),
      ),
    );
  }
}
