import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../providers/progress_providers.dart';
import 'tally_bar.dart';

/// One course in a level, as the row that leads into it.
///
/// The whole summary is shown rather than a clipped line of it. A course is a
/// commitment of weeks and the summary is what the player decides on, so this is
/// the one list in the app where the subtitle is worth the height it takes.
///
/// The progress is under the summary rather than beside the title. Which course to
/// open is decided on what it teaches; how far through it they are is what they
/// check afterwards, once they have found the one they meant.
class CourseTile extends ConsumerWidget {
  const CourseTile({required this.course, required this.onTap, super.key});

  final AcademyCourse course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tally = ref.watch(courseTallyProvider(course.id));

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(course.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  course.summary,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                TallyBar(tally: tally.valueOrNull),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
