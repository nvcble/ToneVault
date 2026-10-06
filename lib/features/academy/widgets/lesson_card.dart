import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/enums/progress_state.dart';
import 'lesson_hero.dart';

/// One lesson as a row in its module: what it is, how long it takes, and how far the
/// player got.
///
/// A row and not the lesson itself. It used to open in place, which put a page of
/// text, a fretboard and six exercises between one lesson and the next and made a
/// module of eight lessons a screen nobody could find their place in again. Tapping it
/// now opens the lesson on a page of its own, so a course reads as a list of what
/// there is to learn.
class LessonCard extends StatelessWidget {
  const LessonCard({
    required this.lesson,
    required this.progress,
    required this.onTap,
    super.key,
  });

  final AcademyLesson lesson;

  /// Null where the lesson has never been opened, which is what not-started is.
  final AcademyProgressRow? progress;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = progress?.state ?? ProgressState.notStarted;
    final done = state == ProgressState.completed;

    return ListTile(
      leading: Icon(
        done ? Icons.check_circle : Icons.radio_button_unchecked,
        color: done ? theme.colorScheme.primary : theme.disabledColor,
      ),
      title: Text(lesson.title),
      subtitle: Text(_subtitle(state)),
      // The kind's own glyph, so a list of eight rows is eight different things at a
      // glance rather than eight titles in the same typeface.
      trailing: Icon(
        lessonKindIcon(lesson.kind),
        size: 20,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
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
}
