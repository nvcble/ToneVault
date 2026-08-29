import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/enums/learning_path.dart';
import '../../../core/enums/skill_level.dart';
import '../../../shared/widgets/async_list_section.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/academy_providers.dart';
import '../widgets/course_tile.dart';

/// One level of one path, as the courses in it.
///
/// The empty state is not a placeholder for a screen still to be written: a phone
/// whose curriculum has not been seeded, or one where the user removed a course
/// they imported, genuinely has nothing here, and it has to say so.
///
/// The seed is watched as well as the courses, so a first launch shows a spinner
/// rather than "no courses here" for the moment it takes to load them. An empty
/// list only means empty once there is nothing left to arrive.
class LevelScreen extends ConsumerWidget {
  const LevelScreen({required this.path, required this.level, super.key});

  final LearningPath path;
  final SkillLevel level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seed = ref.watch(curriculumSeedProvider);
    final courses = ref.watch(courseListProvider((path: path, level: level)));

    // Until the seed has finished, its state is the one worth showing: a spinner
    // while it loads, and its own words if the shipped curriculum would not read.
    final AsyncValue<List<AcademyCourse>> items = seed.hasValue
        ? courses
        : seed.whenData((_) => const <AcademyCourse>[]);

    return Scaffold(
      // Both names, because "Intermediate" on its own does not say which path
      // the user came down to reach it.
      appBar: AppBar(title: Text('${level.label} $_pathWord')),
      body: AsyncListSection(
        items: items,
        errorTitle: 'Could not load the courses',
        empty: const EmptyState(
          icon: Icons.menu_book_outlined,
          title: 'No courses here yet',
          message: 'Courses for this level will appear once they are loaded.',
        ),
        itemBuilder: (context, course) => CourseTile(
          course: course,
          onTap: () =>
              context.push(Routes.academyCourse(path, level, course.id)),
        ),
      ),
    );
  }

  /// "Beginner Rhythm", not "Beginner Rhythm Guitar": the guitar is a given.
  String get _pathWord => switch (path) {
    LearningPath.rhythm => 'Rhythm',
    LearningPath.lead => 'Lead',
  };
}
