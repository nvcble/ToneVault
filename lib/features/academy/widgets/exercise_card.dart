import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/academy_providers.dart';
import 'exercise_tempo.dart';

/// One exercise: what to play, at what tempo, and whether the player has got through
/// it.
///
/// The tick is theirs to give. Nothing infers it from the metronome having run - a
/// player can count sixteen bars at a tempo they still cannot play the exercise at,
/// and an app that ticked it for them would be telling them they had finished
/// something they know they have not.
class ExerciseCard extends ConsumerWidget {
  const ExerciseCard({required this.exercise, required this.done, super.key});

  final AcademyExercise exercise;

  final bool done;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // The whole row is not the target: the card holds a second button,
                // and a card that ticked itself wherever it was touched would tick
                // itself on the way to the metronome.
                IconButton(
                  onPressed: () => _toggle(context, ref),
                  icon: Icon(
                    done
                        ? Icons.check_box
                        : Icons.check_box_outline_blank_outlined,
                    color: done
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  tooltip: done
                      ? 'I have not got through this yet'
                      : 'I have got through this',
                ),
                Expanded(
                  child: Text(
                    exercise.title,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(exercise.instructions, style: theme.textTheme.bodySmall),
            ExerciseTempo(exercise: exercise),
          ],
        ),
      ),
    );
  }

  /// A failure here is worth a snack bar and nothing else. The exercise is still
  /// there to play, and losing the tick is no reason to take it away.
  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(progressRepositoryProvider)
          .setExerciseDone(exercise.id, done: !done);
    } catch (error) {
      if (context.mounted) {
        showFailureSnackBar(context, error);
      }
    }
  }
}
