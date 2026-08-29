import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../providers/academy_providers.dart';
import '../providers/progress_providers.dart';
import 'exercise_card.dart';

/// The exercises of one lesson: what to play, at what tempo, and which of them the
/// player has got through.
///
/// Loaded when the lesson is opened rather than with the course, because a course has
/// forty of these and a player reads one lesson at a time. The ticks are read here and
/// handed down rather than watched per card, so a lesson with six exercises is one
/// stream over the table and not six.
class LessonExercises extends ConsumerWidget {
  const LessonExercises({required this.lessonId, super.key});

  final int lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises =
        ref.watch(exerciseListProvider(lessonId)).valueOrNull ??
        const <AcademyExercise>[];

    if (exercises.isEmpty) {
      return const SizedBox.shrink();
    }

    // An empty set until the ticks arrive, which is a frame of unticked boxes rather
    // than a frame of nothing. The exercises are what the player came for.
    final done =
        ref.watch(exercisesDoneProvider(lessonId)).valueOrNull ?? const <int>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.sm),
        for (final exercise in exercises)
          ExerciseCard(exercise: exercise, done: done.contains(exercise.id)),
      ],
    );
  }
}
