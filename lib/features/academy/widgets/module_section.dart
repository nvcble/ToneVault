import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/section_label.dart';
import '../providers/academy_providers.dart';
import 'lesson_card.dart';

/// One module of a course: its name, what it is for, and its lessons.
///
/// The lessons are watched here rather than passed in, so a module is one widget
/// that knows how to fill itself. A course with six modules is then six small
/// queries instead of one join the screen has to unpick.
class ModuleSection extends ConsumerWidget {
  const ModuleSection({
    required this.module,
    required this.courseId,
    this.openLessonId,
    super.key,
  });

  final AcademyModule module;
  final int courseId;

  /// The one lesson of the course to open on arrival, passed straight through: a
  /// module does not know whether the lesson is one of its own, so every module
  /// checks and at most one of them matches.
  final int? openLessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lessons = ref.watch(lessonListProvider(module.id));
    final progress = ref.watch(courseProgressProvider(courseId));
    final summary = module.summary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(module.title),
        if (summary != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Text(
              summary,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        // A module whose lessons have not arrived says nothing rather than
        // showing a spinner: the heading is already on screen, and a row of
        // progress indicators down a course reads as a fault.
        for (final lesson in lessons.valueOrNull ?? const <AcademyLesson>[])
          LessonCard(
            lesson: lesson,
            progress: progress.valueOrNull?[lesson.id],
            startOpen: lesson.id == openLessonId,
          ),
      ],
    );
  }
}
