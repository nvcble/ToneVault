import 'package:drift/drift.dart';

import '../../enums/learning_path.dart';
import '../../enums/progress_state.dart';
import '../app_database.dart';
import '../tables/academy_courses_table.dart';
import '../tables/academy_exercise_progress_table.dart';
import '../tables/academy_exercises_table.dart';
import '../tables/academy_lessons_table.dart';
import '../tables/academy_modules_table.dart';
import '../tables/academy_practice_sessions_table.dart';
import '../tables/academy_progress_table.dart';
import 'academy_course_dao.dart' show LessonPlace;
import 'academy_practice_writes.dart';

part 'academy_progress_dao.g.dart';

/// Typed queries over what the player has done.
///
/// `academy_courses`, `academy_modules` and `academy_lessons` are here to join
/// through: progress is stored per lesson, and every screen that shows it asks
/// about a course or a level rather than about one lesson at a time.
///
/// The lesson's own row is read here; the exercises they ticked and the sittings they
/// put in are mixed in from `academy_practice_writes.dart`.
@DriftAccessor(
  tables: [
    AcademyProgress,
    AcademyExerciseProgress,
    AcademyPracticeSessions,
    AcademyExercises,
    AcademyLessons,
    AcademyModules,
    AcademyCourses,
  ],
)
class AcademyProgressDao extends DatabaseAccessor<AppDatabase>
    with _$AcademyProgressDaoMixin, AcademyPracticeWrites {
  AcademyProgressDao(super.attachedDatabase);

  Stream<AcademyProgressRow?> watchProgress(int lessonId) {
    return (select(
      academyProgress,
    )..where((row) => row.lessonId.equals(lessonId))).watchSingleOrNull();
  }

  Future<AcademyProgressRow?> findProgress(int lessonId) {
    return (select(
      academyProgress,
    )..where((row) => row.lessonId.equals(lessonId))).getSingleOrNull();
  }

  /// The progress rows for every lesson of one course, so a course can say how far
  /// through it the player is in one query rather than one per lesson.
  Stream<List<AcademyProgressRow>> watchCourseProgress(int courseId) {
    final lessonIds = selectOnly(academyLessons)
      ..addColumns([academyLessons.id])
      ..join([
        innerJoin(
          academyModules,
          academyModules.id.equalsExp(academyLessons.moduleId),
        ),
      ])
      ..where(academyModules.courseId.equals(courseId));

    return (select(
      academyProgress,
    )..where((row) => row.lessonId.isInQuery(lessonIds))).watch();
  }

  /// How many lessons each course of one path holds, and how many of them are
  /// finished, keyed by course id.
  ///
  /// One query for the whole path rather than one per course. A path screen shows
  /// four levels at once and a level screen a handful of courses, and a stream each
  /// would be a dozen watchers on one screen all asking the same table.
  ///
  /// The shape that comes back is what the Academy calls a `LessonTally`. It is
  /// left unnamed here because naming it would mean the database layer importing a
  /// feature; records match by shape, so the caller can name it without that.
  Stream<Map<int, ({int lessons, int done})>> watchPathTallies(
    LearningPath path,
  ) {
    return _tallies(academyCourses.path.equalsValue(path)).watch().map((rows) {
      return {
        for (final row in rows)
          row.read(academyCourses.id)!: (
            lessons: row.read(_lessonCount) ?? 0,
            done: row.read(_doneCount) ?? 0,
          ),
      };
    });
  }

  /// The same count for one course, which is what a course screen shows.
  ///
  /// A course with no lessons in it produces no group at all, so an empty result is
  /// a real answer rather than a missing one.
  Stream<({int lessons, int done})> watchCourseTally(int courseId) {
    return _tallies(academyCourses.id.equals(courseId)).watch().map((rows) {
      final row = rows.firstOrNull;
      return (
        lessons: row?.read(_lessonCount) ?? 0,
        done: row?.read(_doneCount) ?? 0,
      );
    });
  }

  /// Every lesson of the courses [where] picks out, counted and counted again for
  /// the ones that are done.
  ///
  /// The completed test is in the join rather than in a `FILTER` on the count, so
  /// the progress rows that come through are the finished ones and counting them is
  /// counting those. `FILTER` needs sqlite 3.30, and a query that works on every
  /// phone is worth more than the shorter spelling.
  JoinedSelectStatement<HasResultSet, dynamic> _tallies(
    Expression<bool> where,
  ) {
    return selectOnly(academyCourses)
      ..addColumns([academyCourses.id, _lessonCount, _doneCount])
      ..join([
        innerJoin(
          academyModules,
          academyModules.courseId.equalsExp(academyCourses.id),
        ),
        innerJoin(
          academyLessons,
          academyLessons.moduleId.equalsExp(academyModules.id),
        ),
        leftOuterJoin(
          academyProgress,
          academyProgress.lessonId.equalsExp(academyLessons.id) &
              academyProgress.state.equalsValue(ProgressState.completed),
        ),
      ])
      ..where(where)
      ..groupBy([academyCourses.id]);
  }

  /// Held as fields rather than built where they are used. A row is read back by
  /// the expression it was asked for, so the two counts have to be the same two
  /// objects in `addColumns` and in `read` - a getter would hand out a fresh pair
  /// each time and the read would not find its column.
  late final Expression<int> _lessonCount = academyLessons.id.count();

  late final Expression<int> _doneCount = academyProgress.lessonId.count();

  /// The lesson the player last had open and has not finished, with the course it
  /// sits in so it can be linked to.
  ///
  /// One row, ordered by when it was last opened. This is the Academy's "carry on
  /// where you left off", and what makes it useful is that it is the *unfinished*
  /// one: a player who ticked their last lesson has nothing to carry on with, and
  /// being sent back to it would be the app arguing with them.
  Stream<LessonPlace?> watchUnfinished() {
    final query =
        select(academyProgress).join([
            innerJoin(
              academyLessons,
              academyLessons.id.equalsExp(academyProgress.lessonId),
            ),
            innerJoin(
              academyModules,
              academyModules.id.equalsExp(academyLessons.moduleId),
            ),
            innerJoin(
              academyCourses,
              academyCourses.id.equalsExp(academyModules.courseId),
            ),
          ])
          ..where(academyProgress.state.equalsValue(ProgressState.inProgress))
          ..orderBy([OrderingTerm.desc(academyProgress.lastOpenedAt)])
          ..limit(1);

    return query.watch().map((rows) {
      final row = rows.firstOrNull;
      if (row == null) {
        return null;
      }
      return (
        course: row.readTable(academyCourses),
        lesson: row.readTable(academyLessons),
      );
    });
  }

  /// Writes the row for [lessonId], replacing whatever was there.
  ///
  /// Upsert rather than insert-or-update in two steps: a lesson opened twice at
  /// once - a tap and a restored screen, say - would otherwise race to insert the
  /// same row and one of them would fail on the unique key.
  ///
  /// The conflict is aimed at `lessonId` rather than left to default to the
  /// primary key, because the caller does not know the id: it passes the lesson
  /// and lets the row be found by it.
  /// Overrides the declaration [AcademyPracticeWrites] makes of it, which is how
  /// `recordPractice` writes the running total and the sitting in one transaction
  /// from a file that does not have this table.
  @override
  Future<void> saveProgress(AcademyProgressCompanion progress) {
    return into(academyProgress).insert(
      progress,
      onConflict: DoUpdate((_) => progress, target: [academyProgress.lessonId]),
    );
  }

  /// Returns whether a row matched. What the player does to say they have not
  /// really done a lesson after all.
  ///
  /// The sittings and the exercise ticks go with it, in the same transaction. They do
  /// not cascade from this row - they hang off the lesson and off its exercises - so
  /// deleting this one alone would leave a not-started lesson with three exercises
  /// still ticked and an hour of practice behind it.
  Future<bool> clearProgress(int lessonId) {
    return transaction(() async {
      await clearPractice(lessonId);
      final deletedRows = await (delete(
        academyProgress,
      )..where((row) => row.lessonId.equals(lessonId))).go();
      return deletedRows > 0;
    });
  }
}
