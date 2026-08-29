import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/section_label.dart';
import '../providers/progress_providers.dart';

/// The lesson the player left unfinished, and one tap back into it.
///
/// The whole section draws nothing at all where there is nothing to carry on with -
/// a player on their first launch, and one who has finished everything they started,
/// both see the paths and nothing above them. An empty "Continue learning" heading
/// would be the app asking them to remember something it could not.
///
/// It sits above the paths rather than under them, because it is the answer to the
/// question the paths are only a way of asking. Somebody who is part way through a
/// lesson is not choosing a path.
class ContinueLearning extends ConsumerWidget {
  const ContinueLearning({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final place = ref.watch(unfinishedLessonProvider).valueOrNull;
    if (place == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final course = place.course;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Carry on'),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Card(
            clipBehavior: Clip.antiAlias,
            // Filled rather than outlined, so the one thing on the screen that is
            // already underway does not look like a third path to choose from.
            color: theme.colorScheme.surfaceContainerHighest,
            child: InkWell(
              onTap: () => context.push(
                Routes.academyCourse(
                  course.path,
                  course.level,
                  course.id,
                  // Named, so the lesson is open when the course appears. Landing on
                  // the course and hunting for the lesson again is the work this
                  // section exists to save.
                  lessonId: place.lesson.id,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.lesson.title,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          // The course and the level, because a lesson title on its
                          // own does not say where in the curriculum it came from.
                          Text(
                            '${course.title} - ${course.level.label}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
