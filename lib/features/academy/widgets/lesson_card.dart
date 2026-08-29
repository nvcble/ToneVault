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
import 'lesson_next_skill.dart';
import 'lesson_note_list.dart';
import 'lesson_objective.dart';
import 'lesson_practice.dart';
import 'lesson_theory.dart';

/// One lesson, closed to its title and opened to its whole text.
///
/// Opening it is what records that it was started, so a player never has to tell
/// the app what it can already see. Finishing it is a deliberate tap, because only
/// they know whether they have.
class LessonCard extends ConsumerWidget {
  const LessonCard({
    required this.lesson,
    required this.progress,
    this.startOpen = false,
    super.key,
  });

  final AcademyLesson lesson;

  /// Null where the lesson has never been opened, which is what not-started is.
  final AcademyProgressRow? progress;

  /// Open before the player has touched it, which is how "carry on where you left
  /// off" lands on the lesson itself rather than on the course it is in.
  ///
  /// It does not record that the lesson was opened. Nothing here was started by
  /// this: the only way to arrive open is to be the lesson already in progress.
  final bool startOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = progress?.state ?? ProgressState.notStarted;
    final done = state == ProgressState.completed;

    return ExpansionTile(
      leading: Icon(
        done ? Icons.check_circle : Icons.radio_button_unchecked,
        color: done ? theme.colorScheme.primary : theme.disabledColor,
      ),
      title: Text(lesson.title),
      subtitle: Text(_subtitle(state)),
      initiallyExpanded: startOpen,
      childrenPadding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      onExpansionChanged: (open) => open ? _open(context, ref) : null,
      children: [
        // The order a professional lesson is read in: what it is for, the teaching,
        // the shapes, the practice, then what goes wrong and what to do about it.
        // The practice record comes last of all, because it is about the player
        // rather than about the lesson.
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
                onPressed: () => _clear(context, ref),
                icon: const Icon(Icons.restart_alt),
                label: const Text('Clear my progress'),
              )
            else
              FilledButton.icon(
                onPressed: () => _complete(context, ref),
                icon: const Icon(Icons.check),
                label: const Text('I have finished this'),
              ),
          ],
        ),
      ],
    );
  }

  /// What the lesson asks of the player, how long it takes, and how far they got.
  ///
  /// Not-started is left unsaid: it is the state of every row on a course that has
  /// just been opened, and saying so on all of them says nothing.
  String _subtitle(ProgressState state) {
    final minutes = lesson.estimatedMinutes;
    return [
      lesson.kind.label,
      if (minutes != null) '$minutes min',
      if (state != ProgressState.notStarted) state.label,
    ].join(' - ');
  }

  Future<void> _open(BuildContext context, WidgetRef ref) =>
      _record(context, ref, (repository) => repository.markOpened(lesson.id));

  Future<void> _complete(BuildContext context, WidgetRef ref) =>
      _record(context, ref, (it) => it.markCompleted(lesson.id));

  Future<void> _clear(BuildContext context, WidgetRef ref) =>
      _record(context, ref, (it) => it.clearProgress(lesson.id));

  /// The three writes this card makes, each reported the same way.
  ///
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
