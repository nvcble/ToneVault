import 'package:drift/drift.dart';

import '../../enums/learning_path.dart';
import '../../enums/skill_level.dart';
import '../app_database.dart';
import '../tables/academy_courses_table.dart';
import '../tables/academy_exercises_table.dart';
import '../tables/academy_lessons_table.dart';
import '../tables/academy_modules_table.dart';

import 'academy_course_writes.dart';

part 'academy_course_dao.g.dart';

/// A lesson with the course it sits in: what a search result and a bookmark need, since
/// the route to a lesson names the course rather than the lesson.
typedef LessonPlace = ({AcademyCourse course, AcademyLesson lesson});

/// Typed queries over the curriculum: courses, their modules, and the lessons and
/// exercises inside them.
///
/// One accessor for all four because they are read together and never apart - a
/// course is only ever shown as its modules, and a module as its lessons - and
/// writing them separately would mean four DAOs whose only job is to hand rows to
/// each other.
///
/// Reads rows here; the writes are mixed in from `academy_course_writes.dart`.
/// Timestamps, validation, the matching of an incoming course to one already
/// stored, and error translation belong to the repository.
@DriftAccessor(
  tables: [AcademyCourses, AcademyModules, AcademyLessons, AcademyExercises],
)
class AcademyCourseDao extends DatabaseAccessor<AppDatabase>
    with _$AcademyCourseDaoMixin, AcademyCourseWrites {
  AcademyCourseDao(super.attachedDatabase);

  /// The courses at one level of one path, in the order the curriculum puts them.
  ///
  /// The slug breaks a tie. Positions come from the order courses are written in
  /// the file they arrived in, and two files know nothing about each other - so a
  /// course the user imported can land on the same position as one the app ships.
  /// Ordering by something after that is what stops the list rearranging itself
  /// between one read and the next.
  Stream<List<AcademyCourse>> watchCourses(
    LearningPath path,
    SkillLevel level,
  ) {
    return (select(academyCourses)
          ..where(
            (row) => row.path.equalsValue(path) & row.level.equalsValue(level),
          )
          ..orderBy([
            (row) => OrderingTerm.asc(row.position),
            (row) => OrderingTerm.asc(row.slug),
          ]))
        .watch();
  }

  /// Every course of one path, across all four levels. What a path screen counts
  /// its progress against.
  ///
  /// Not ordered by level here, deliberately. The level is stored as its own name,
  /// and SQL would sort those alphabetically - Advanced first and Beginner second,
  /// which is the one order a learning path must not come back in. Putting the
  /// levels in teaching order is `CurriculumRepository`'s job, where the enum that
  /// defines that order can be read.
  Stream<List<AcademyCourse>> watchPathCourses(LearningPath path) {
    return (select(academyCourses)
          ..where((row) => row.path.equalsValue(path))
          ..orderBy([
            (row) => OrderingTerm.asc(row.position),
            (row) => OrderingTerm.asc(row.slug),
          ]))
        .watch();
  }

  Stream<AcademyCourse?> watchCourse(int courseId) {
    return (select(
      academyCourses,
    )..where((row) => row.id.equals(courseId))).watchSingleOrNull();
  }

  Future<AcademyCourse?> findCourseBySlug(String slug) {
    return (select(
      academyCourses,
    )..where((row) => row.slug.equals(slug))).getSingleOrNull();
  }

  Stream<List<AcademyModule>> watchModules(int courseId) {
    return (select(academyModules)
          ..where((row) => row.courseId.equals(courseId))
          ..orderBy([(row) => OrderingTerm.asc(row.position)]))
        .watch();
  }

  Future<AcademyModule?> findModuleBySlug(int courseId, String slug) {
    return (select(academyModules)..where(
          (row) => row.courseId.equals(courseId) & row.slug.equals(slug),
        ))
        .getSingleOrNull();
  }

  Stream<List<AcademyLesson>> watchLessons(int moduleId) {
    return (select(academyLessons)
          ..where((row) => row.moduleId.equals(moduleId))
          ..orderBy([(row) => OrderingTerm.asc(row.position)]))
        .watch();
  }

  Stream<AcademyLesson?> watchLesson(int lessonId) {
    return (select(
      academyLessons,
    )..where((row) => row.id.equals(lessonId))).watchSingleOrNull();
  }

  Future<AcademyLesson?> findLessonBySlug(int moduleId, String slug) {
    return (select(academyLessons)..where(
          (row) => row.moduleId.equals(moduleId) & row.slug.equals(slug),
        ))
        .getSingleOrNull();
  }

  /// The lessons whose title, text or course name contains [text].
  ///
  /// The course comes back with each of them because a lesson on its own cannot be
  /// linked to: the route to it names the path, the level and the course it sits in.
  ///
  /// `LIKE` rather than a full-text index. The curriculum is a few hundred lessons on
  /// a phone, and an FTS table would be a second copy of the text to keep in step with
  /// the first every time an import rewrites a lesson.
  Future<List<LessonPlace>> searchLessons(String text, {int limit = 40}) async {
    final pattern = '%${text.trim()}%';
    final rows =
        await (_placed()
              ..where(
                academyLessons.title.like(pattern) |
                    academyLessons.body.like(pattern) |
                    academyCourses.title.like(pattern),
              )
              ..limit(limit))
            .get();

    return _places(rows);
  }

  /// Where a lesson lives, found by the slug a bookmark stored.
  ///
  /// A slug is unique within its module rather than across the curriculum, so this
  /// takes the first match instead of insisting there is only one - two courses may
  /// each have an `open-chords` lesson, and a bookmark on one of them is still worth
  /// opening.
  Future<LessonPlace?> findLessonPlace(String slug) async {
    final rows =
        await (_placed()
              ..where(academyLessons.slug.equals(slug.trim()))
              ..limit(1))
            .get();

    return _places(rows).firstOrNull;
  }

  /// Lessons with the module and course above them, in the order a course reads.
  JoinedSelectStatement<HasResultSet, dynamic> _placed() {
    return select(academyLessons).join([
      innerJoin(
        academyModules,
        academyModules.id.equalsExp(academyLessons.moduleId),
      ),
      innerJoin(
        academyCourses,
        academyCourses.id.equalsExp(academyModules.courseId),
      ),
    ])..orderBy([
      OrderingTerm.asc(academyCourses.title.collate(Collate.noCase)),
      OrderingTerm.asc(academyModules.position),
      OrderingTerm.asc(academyLessons.position),
    ]);
  }

  List<LessonPlace> _places(List<TypedResult> rows) => [
    for (final row in rows)
      (
        course: row.readTable(academyCourses),
        lesson: row.readTable(academyLessons),
      ),
  ];

  Stream<List<AcademyExercise>> watchExercises(int lessonId) {
    return (select(academyExercises)
          ..where((row) => row.lessonId.equals(lessonId))
          ..orderBy([(row) => OrderingTerm.asc(row.position)]))
        .watch();
  }

  /// Every course there is, in curriculum order. What an export walks.
  ///
  /// Not ordered by level, for the same reason [watchPathCourses] is not: the level
  /// is stored as its own name and SQL would sort those alphabetically. An export
  /// keeps the order the courses were written in, which is the order that made
  /// their positions.
  Future<List<AcademyCourse>> allCourses() {
    return (select(academyCourses)..orderBy([
          (row) => OrderingTerm.asc(row.position),
          (row) => OrderingTerm.asc(row.slug),
        ]))
        .get();
  }

  Future<AcademyCourse?> findCourse(int courseId) {
    return (select(
      academyCourses,
    )..where((row) => row.id.equals(courseId))).getSingleOrNull();
  }

  /// The three reads an import makes, as futures rather than streams: an import
  /// runs in one transaction, and a stream inside one would be watching a database
  /// it is itself half-way through changing.
  ///
  /// In curriculum order, so what is written back keeps the order it had unless the
  /// file says otherwise.
  Future<List<AcademyModule>> modulesOf(int courseId) {
    return (select(academyModules)
          ..where((row) => row.courseId.equals(courseId))
          ..orderBy([(row) => OrderingTerm.asc(row.position)]))
        .get();
  }

  Future<List<AcademyLesson>> lessonsOf(int moduleId) {
    return (select(academyLessons)
          ..where((row) => row.moduleId.equals(moduleId))
          ..orderBy([(row) => OrderingTerm.asc(row.position)]))
        .get();
  }

  Future<List<AcademyExercise>> exercisesOf(int lessonId) {
    return (select(academyExercises)
          ..where((row) => row.lessonId.equals(lessonId))
          ..orderBy([(row) => OrderingTerm.asc(row.position)]))
        .get();
  }

  /// Whether the curriculum has been loaded at all, for the seeder to check
  /// before it writes.
  Future<bool> hasAnyCourse() async => await findAnyCourse() != null;

  Future<AcademyCourse?> findAnyCourse() =>
      (select(academyCourses)..limit(1)).getSingleOrNull();
}
