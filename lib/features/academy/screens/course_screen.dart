import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/enums/learning_path.dart';
import '../../../core/enums/skill_level.dart';
import '../../../shared/widgets/async_list_section.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/lesson_tally.dart';
import '../providers/academy_providers.dart';
import '../providers/progress_providers.dart';
import '../widgets/course_export_action.dart';
import '../widgets/module_section.dart';
import '../widgets/tally_bar.dart';

/// One course, as its modules and the lessons in them.
///
/// A list of what there is to learn, and nothing more: each lesson is one row, and
/// reading one happens on its own page. A course is six modules of six lessons, and
/// opening them in place put a page of text and a fretboard between one row and the
/// next - which made the screen a thing to scroll through rather than to choose from.
///
/// The course's progress is above the modules rather than inside the list, so it
/// stays put while the lessons scroll under it. It is the answer to "how much of
/// this is left", and a player asks that while looking at what is left.
class CourseScreen extends ConsumerWidget {
  const CourseScreen({
    required this.courseId,
    required this.path,
    required this.level,
    super.key,
  });

  final int courseId;

  /// Where the course sits, taken from the route rather than from its row: it is what
  /// the link to one of its lessons is built from, and a lesson row arriving before
  /// the course row would otherwise leave a tappable lesson with nowhere to go.
  final LearningPath path;
  final SkillLevel level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(courseProvider(courseId));
    final modules = ref.watch(moduleListProvider(courseId));
    final tally = ref.watch(courseTallyProvider(courseId)).valueOrNull;

    return Scaffold(
      // The title waits for the row rather than showing the id. A course reached
      // from a link that no longer resolves keeps the generic word and its body
      // says the rest.
      appBar: AppBar(
        title: Text(course.valueOrNull?.title ?? 'Course'),
        // Only once the course is known to be there. A link that no longer resolves
        // has nothing to send on.
        actions: [
          if (course.valueOrNull != null)
            CourseExportAction(courseId: courseId),
        ],
      ),
      body: Column(
        children: [
          // Nothing at all where there is nothing counted, padding included: an
          // empty course would otherwise open with a gap where a bar should be.
          if (tally != null && !tally.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: TallyBar(tally: tally),
            ),
          Expanded(
            child: AsyncListSection<AcademyModule>(
              items: modules,
              errorTitle: 'Could not load this course',
              empty: const EmptyState(
                icon: Icons.menu_book_outlined,
                title: 'Nothing in this course',
                message:
                    'This course has no modules in it. It may have been '
                    'replaced by an import.',
              ),
              itemBuilder: (context, module) => ModuleSection(
                module: module,
                courseId: courseId,
                path: path,
                level: level,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
