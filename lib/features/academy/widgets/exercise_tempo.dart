import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../metronome/providers/metronome_providers.dart';

/// The tempo an exercise is played at, and the metronome set to it.
///
/// Both tempos stay written out beside the button: an exercise is practised from the
/// one the player can already manage towards the one they cannot yet, so the target is
/// half of what the exercise is asking for and hiding it inside the metronome would
/// lose it. The button only saves the setting up, and it counts from the start tempo,
/// which is where a player begins.
class ExerciseTempo extends ConsumerWidget {
  const ExerciseTempo({required this.exercise, super.key});

  final AcademyExercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            _tempo(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        TextButton.icon(
          style: TextButton.styleFrom(
            // Tall enough to hit, and no wider than its label: it shares the row with
            // the tempo it is setting.
            minimumSize: const Size(0, AppSpacing.minTouchTarget),
          ),
          onPressed: () => _count(context, ref),
          icon: const Icon(Icons.av_timer),
          label: Text('Count ${exercise.startBpm}'),
        ),
      ],
    );
  }

  /// Sets the metronome before opening it, so it is already on this exercise's tempo
  /// when it appears rather than arriving at ninety and jumping.
  ///
  /// Opened in the lesson's name, so the time it counts is credited to the lesson
  /// this exercise belongs to rather than to nothing.
  void _count(BuildContext context, WidgetRef ref) {
    ref
        .read(metronomeSettingsProvider.notifier)
        .preset(bpm: exercise.startBpm, signature: exercise.timeSignature);
    context.push(Routes.metronomeForLesson(exercise.lessonId));
  }

  /// Both tempos and the signature in one line. An exercise whose start and target are
  /// the same is played at one tempo, and saying it twice would read as a mistake.
  String _tempo() {
    final tempo = exercise.startBpm == exercise.targetBpm
        ? '${exercise.startBpm} BPM'
        : '${exercise.startBpm} to ${exercise.targetBpm} BPM';
    return '$tempo  ·  ${exercise.timeSignature.label}';
  }
}
