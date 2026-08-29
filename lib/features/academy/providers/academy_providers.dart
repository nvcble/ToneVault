import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/academy_bookmark_dao.dart';
import '../../../core/database/daos/academy_course_dao.dart';
import '../../../core/database/daos/academy_progress_dao.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/enums/bookmark_target.dart';
import '../../../core/enums/learning_path.dart';
import '../../../core/enums/skill_level.dart';
import '../../theory/data/theory_search.dart';
import '../../theory/providers/theory_providers.dart';
import '../data/bookmark_repository.dart';
import '../data/curriculum_importer.dart';
import '../data/curriculum_repository.dart';
import '../data/curriculum_seeder.dart';
import '../data/progress_repository.dart';

final Provider<AcademyCourseDao> academyCourseDaoProvider =
    Provider<AcademyCourseDao>(
      (ref) => AcademyCourseDao(ref.watch(appDatabaseProvider)),
    );

final Provider<AcademyProgressDao> academyProgressDaoProvider =
    Provider<AcademyProgressDao>(
      (ref) => AcademyProgressDao(ref.watch(appDatabaseProvider)),
    );

final Provider<AcademyBookmarkDao> academyBookmarkDaoProvider =
    Provider<AcademyBookmarkDao>(
      (ref) => AcademyBookmarkDao(ref.watch(appDatabaseProvider)),
    );

final Provider<CurriculumRepository> curriculumRepositoryProvider =
    Provider<CurriculumRepository>(
      (ref) => CurriculumRepository(ref.watch(academyCourseDaoProvider)),
    );

final Provider<ProgressRepository> progressRepositoryProvider =
    Provider<ProgressRepository>(
      (ref) => ProgressRepository(ref.watch(academyProgressDaoProvider)),
    );

final Provider<BookmarkRepository> bookmarkRepositoryProvider =
    Provider<BookmarkRepository>(
      (ref) => BookmarkRepository(ref.watch(academyBookmarkDaoProvider)),
    );

final Provider<CurriculumImporter> curriculumImporterProvider =
    Provider<CurriculumImporter>(
      (ref) => CurriculumImporter(ref.watch(academyCourseDaoProvider)),
    );

final Provider<CurriculumSeeder> curriculumSeederProvider =
    Provider<CurriculumSeeder>(
      (ref) => CurriculumSeeder(ref.watch(curriculumImporterProvider)),
    );

/// The seeding itself, as something that is watched.
///
/// A provider rather than a call in `main`, so it is awaited where the Academy is
/// shown instead of holding up the splash screen for a feature the user may not be
/// opening. Riverpod runs it once per launch and hands every listener the same
/// result, which is what makes "check at every launch" one check and not one per
/// screen.
final FutureProvider<int> curriculumSeedProvider = FutureProvider<int>(
  (ref) => ref.watch(curriculumSeederProvider).seed(),
);

/// One level of one path, which is what a level screen lists.
///
/// A record rather than two families, because a level only means anything
/// alongside the path it belongs to: Beginner Rhythm and Beginner Lead are
/// different courses.
typedef PathLevel = ({LearningPath path, SkillLevel level});

/// The courses at one level, in curriculum order. Drift pushes a new list when the
/// table changes, so the screen never refreshes by hand - which is what makes the
/// empty list a real state rather than a wait: seeding fills it in and the screen
/// follows.
final StreamProviderFamily<List<AcademyCourse>, PathLevel> courseListProvider =
    StreamProvider.family<List<AcademyCourse>, PathLevel>(
      (ref, at) => ref
          .watch(curriculumRepositoryProvider)
          .watchCourses(at.path, at.level),
    );

final StreamProviderFamily<AcademyCourse?, int> courseProvider =
    StreamProvider.family<AcademyCourse?, int>(
      (ref, courseId) =>
          ref.watch(curriculumRepositoryProvider).watchCourse(courseId),
    );

final StreamProviderFamily<List<AcademyModule>, int> moduleListProvider =
    StreamProvider.family<List<AcademyModule>, int>(
      (ref, courseId) =>
          ref.watch(curriculumRepositoryProvider).watchModules(courseId),
    );

final StreamProviderFamily<List<AcademyLesson>, int> lessonListProvider =
    StreamProvider.family<List<AcademyLesson>, int>(
      (ref, moduleId) =>
          ref.watch(curriculumRepositoryProvider).watchLessons(moduleId),
    );

final StreamProviderFamily<AcademyLesson?, int> lessonProvider =
    StreamProvider.family<AcademyLesson?, int>(
      (ref, lessonId) =>
          ref.watch(curriculumRepositoryProvider).watchLesson(lessonId),
    );

final StreamProviderFamily<List<AcademyExercise>, int> exerciseListProvider =
    StreamProvider.family<List<AcademyExercise>, int>(
      (ref, lessonId) =>
          ref.watch(curriculumRepositoryProvider).watchExercises(lessonId),
    );

/// One lesson's progress. Null is not-started, which is a row that was never
/// written rather than a state stored on one.
final StreamProviderFamily<AcademyProgressRow?, int> lessonProgressProvider =
    StreamProvider.family<AcademyProgressRow?, int>(
      (ref, lessonId) =>
          ref.watch(progressRepositoryProvider).watchProgress(lessonId),
    );

/// A course's progress, keyed by lesson id.
///
/// A map rather than the rows themselves: the screen walks a module's lessons in
/// order and looks each one up, and a lesson with no entry has not been started.
final StreamProviderFamily<Map<int, AcademyProgressRow>, int>
courseProgressProvider =
    StreamProvider.family<Map<int, AcademyProgressRow>, int>(
      (ref, courseId) => ref
          .watch(progressRepositoryProvider)
          .watchCourseProgress(courseId)
          .map((rows) => {for (final row in rows) row.lessonId: row}),
    );

final StreamProvider<List<AcademyBookmark>> bookmarkListProvider =
    StreamProvider<List<AcademyBookmark>>(
      (ref) => ref.watch(bookmarkRepositoryProvider).watchBookmarks(),
    );

/// One thing a bookmark could point at, which is what a bookmark button watches.
typedef BookmarkAt = ({BookmarkTarget target, String targetKey});

/// Whether this thing is bookmarked. Null is "not bookmarked", which is a row that was
/// never written rather than a flag stored on one.
final StreamProviderFamily<AcademyBookmark?, BookmarkAt> bookmarkProvider =
    StreamProvider.family<AcademyBookmark?, BookmarkAt>(
      (ref, at) => ref
          .watch(bookmarkRepositoryProvider)
          .watchBookmark(at.target, at.targetKey),
    );

/// What the player has typed into the Academy's search field.
final StateProvider<String> lessonSearchQueryProvider = StateProvider<String>(
  (ref) => '',
);

/// The lessons that match it, looked up again on every change of the query.
///
/// A future rather than a stream: a search is a question asked once, and re-running it
/// when an unrelated lesson is marked as read would move the results under the finger
/// about to tap one.
final FutureProvider<List<LessonPlace>> lessonSearchProvider =
    FutureProvider<List<LessonPlace>>(
      (ref) => ref
          .watch(curriculumRepositoryProvider)
          .searchLessons(ref.watch(lessonSearchQueryProvider)),
    );

/// What the theory engine can offer for the same words, read in the browser's key.
///
/// The one search field answers with both, because a player who types `minor pentatonic`
/// wants the scale on the neck as much as the lesson about it, and would not think to
/// look for those in two places. Nothing is read from the database for this half: it is
/// worked out from the query, so it is a plain provider and it is there on the keystroke.
final Provider<List<TheoryFound>> theorySearchProvider =
    Provider<List<TheoryFound>>(
      (ref) => searchTheory(
        ref.watch(lessonSearchQueryProvider),
        key: ref.watch(theoryKeyProvider),
      ),
    );
