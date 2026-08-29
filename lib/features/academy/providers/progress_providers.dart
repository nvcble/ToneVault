import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/academy_course_dao.dart' show LessonPlace;
import '../../../core/enums/learning_path.dart';
import '../data/lesson_tally.dart';
import 'academy_providers.dart';

/// How far through the curriculum the player is, at every size it gets asked at.
///
/// Kept apart from `academy_providers.dart`, which is the curriculum itself. These
/// are about the one player and their progress through it, and the two are read in
/// different places: a level screen wants the courses, a path screen wants only the
/// numbers.
///
/// One query per path underneath all of it. A path screen showing four levels, and
/// a level screen showing six courses, are the same stream read at different
/// groupings rather than ten streams over one table.

/// Every course of one path, in teaching order.
///
/// Needed alongside the tallies because the tallies are keyed by course id and say
/// nothing about which level a course belongs to. The courses are what put them
/// into levels.
final StreamProviderFamily<List<AcademyCourse>, LearningPath>
pathCourseListProvider =
    StreamProvider.family<List<AcademyCourse>, LearningPath>(
      (ref, path) =>
          ref.watch(curriculumRepositoryProvider).watchPathCourses(path),
    );

final StreamProviderFamily<Map<int, LessonTally>, LearningPath>
pathTallyProvider = StreamProvider.family<Map<int, LessonTally>, LearningPath>(
  (ref, path) => ref.watch(progressRepositoryProvider).watchPathTallies(path),
);

/// One course's own count, for the screen that shows that course.
final StreamProviderFamily<LessonTally, int> courseTallyProvider =
    StreamProvider.family<LessonTally, int>(
      (ref, courseId) =>
          ref.watch(progressRepositoryProvider).watchCourseTally(courseId),
    );

/// One level's courses added together, or null while either half is still loading.
///
/// Null rather than [emptyTally], so a bar is not drawn at nought and then jumped
/// to two thirds a frame later. Nothing shown is honest about not knowing yet;
/// nought per cent is a claim.
final ProviderFamily<LessonTally?, PathLevel> levelTallyProvider =
    Provider.family<LessonTally?, PathLevel>((ref, at) {
      final courses = ref.watch(pathCourseListProvider(at.path)).valueOrNull;
      final tallies = ref.watch(pathTallyProvider(at.path)).valueOrNull;
      if (courses == null || tallies == null) {
        return null;
      }

      return sumTallies(
        courses
            .where((course) => course.level == at.level)
            .map((course) => tallies[course.id] ?? emptyTally),
      );
    });

/// A whole path added together, which is what its card on the way in shows.
final ProviderFamily<LessonTally?, LearningPath> pathTotalProvider =
    Provider.family<LessonTally?, LearningPath>((ref, path) {
      final tallies = ref.watch(pathTallyProvider(path)).valueOrNull;
      return tallies == null ? null : sumTallies(tallies.values);
    });

/// Which of a lesson's exercises the player has ticked off, by exercise id.
///
/// A set rather than the rows: an exercise card asks one question of it, and the date
/// the tick was written is not something any screen shows.
final StreamProviderFamily<Set<int>, int> exercisesDoneProvider =
    StreamProvider.family<Set<int>, int>(
      (ref, lessonId) =>
          ref.watch(progressRepositoryProvider).watchExercisesDone(lessonId),
    );

/// The sittings of practice recorded against one lesson, most recent first.
///
/// Watched only where a lesson is open. A course screen shows forty lessons and none
/// of them needs its own list of evenings.
final StreamProviderFamily<List<AcademyPracticeSessionRow>, int>
practiceSessionProvider =
    StreamProvider.family<List<AcademyPracticeSessionRow>, int>(
      (ref, lessonId) =>
          ref.watch(progressRepositoryProvider).watchPracticeSessions(lessonId),
    );

/// The lesson to carry on with, across both paths.
///
/// Not per path. A player is working on one thing at a time, and asking them which
/// path they want to carry on with is the question the section exists to save them.
final StreamProvider<LessonPlace?> unfinishedLessonProvider =
    StreamProvider<LessonPlace?>(
      (ref) => ref.watch(progressRepositoryProvider).watchUnfinished(),
    );
