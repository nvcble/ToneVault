import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/enums/bookmark_target.dart';
import '../../../core/enums/progress_state.dart';
import '../../../core/values/lesson_notes.dart';
import '../../../core/values/theory_keys.dart';
import '../../../shared/widgets/action_row.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/progress_repository.dart';
import '../providers/academy_providers.dart';
import 'bookmark_button.dart';
import 'lesson_body.dart';
import 'lesson_exercises.dart';
import 'lesson_hero.dart';
import 'lesson_next_skill.dart';
import 'lesson_note_list.dart';
import 'lesson_objective.dart';
import 'lesson_practice.dart';
import 'lesson_theory.dart';
import 'lesson_video_button.dart';

/// One lesson, whole: everything a player reads, plays and ticks off.
///
/// The order a professional lesson is taught in - a picture of it and a video of
/// somebody playing it, what it is for, the teaching, the shapes, the practice, then
/// what goes wrong and what to do about it. The practice record comes last of all,
/// because it is about the player rather than about the lesson.
///
/// A widget rather than the screen itself, so what a lesson is stays one thing while
/// where it appears can change.
class LessonView extends ConsumerWidget {
  const LessonView({required this.lesson, this.progress, super.key});

  final AcademyLesson lesson;

  /// Null where the lesson has never been opened, which is what not-started is.
  final AcademyProgressRow? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = progress?.state == ProgressState.completed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LessonHero(
          lesson: lesson,
          onWatch: () => watchLesson(context, lesson),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Above the reading rather than under it: somebody who learns by watching
        // should not have to scroll a page of text to find that out.
        LessonVideoButton(lesson: lesson),
        const SizedBox(height: AppSpacing.md),
        LessonObjective(objective: lesson.objective),
        LessonBody(lesson: lesson),
        LessonTheory(theoryKeys: decodeTheoryKeys(lesson.theoryKeys)),
        LessonExercises(lessonId: lesson.id),
        LessonNoteList(
          title: 'Common mistakes',
          icon: Icons.error_outline,
          notes: decodeLessonNotes(lesson.commonMistakes),
        ),
        LessonNoteList(
          title: 'Practice tips',
          icon: Icons.lightbulb_outline,
          notes: decodeLessonNotes(lesson.practiceTips),
        ),
        LessonNextSkill(nextSkill: lesson.nextSkill),
        LessonPractice(
          lessonId: lesson.id,
          practiceSeconds: progress?.practiceSeconds ?? 0,
        ),
        const SizedBox(height: AppSpacing.sm),
        // An [ActionRow] rather than a plain [Row]: the app theme stretches a
        // FilledButton across its column, and a row cannot lay out an infinite
        // minimum width.
        ActionRow(
          // Kept by slug, which survives the course being imported again, and named
          // by its title, which is what the player will be looking for.
          leading: BookmarkButton(
            target: BookmarkTarget.lesson,
            targetKey: lesson.slug,
            label: lesson.title,
          ),
          children: [
            if (done)
              TextButton.icon(
                onPressed: () => _record(
                  context,
                  ref,
                  (it) => it.clearProgress(lesson.id),
                ),
                icon: const Icon(Icons.restart_alt),
                label: const Text('Clear my progress'),
              )
            else
              FilledButton.icon(
                onPressed: () => _record(
                  context,
                  ref,
                  (it) => it.markCompleted(lesson.id),
                ),
                icon: const Icon(Icons.check),
                label: const Text('I have finished this'),
              ),
          ],
        ),
      ],
    );
  }

  /// A failure here is worth a snack bar and nothing else: the lesson is still
  /// readable, and losing the tick is no reason to take its text away.
  Future<void> _record(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function(ProgressRepository repository) write,
  ) async {
    try {
      await write(ref.read(progressRepositoryProvider));
    } catch (error) {
      if (context.mounted) {
        showFailureSnackBar(context, error);
      }
    }
  }
}
