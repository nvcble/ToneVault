import 'package:drift/drift.dart' show Value;
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/academy_course_dao.dart';
import 'package:tone_vault/core/enums/learning_path.dart';
import 'package:tone_vault/core/enums/lesson_kind.dart';
import 'package:tone_vault/core/enums/skill_level.dart';
import 'package:tone_vault/core/enums/time_signature.dart';

/// A course with one module and as many lessons as asked for, written straight
/// through the DAO.
///
/// The importer is what writes the curriculum in the app, and it is not built yet.
/// This is not a stand-in for it: a test about progress needs a lesson to have made
/// progress on, and how that lesson got there is not what it is testing.
typedef SeededCourse = ({int courseId, int moduleId, List<int> lessonIds});

Future<SeededCourse> seedCourse(
  AppDatabase database, {
  String slug = 'rhythm-beginner-first-chords',
  LearningPath path = LearningPath.rhythm,
  SkillLevel level = SkillLevel.beginner,
  int lessons = 1,
}) async {
  final dao = AcademyCourseDao(database);
  final now = DateTime.utc(2026, 8, 20, 9);

  final courseId = await dao.insertCourse(
    AcademyCoursesCompanion.insert(
      slug: slug,
      path: path,
      level: level,
      title: 'First Chords',
      summary: 'Open chords, and changing between them in time.',
      position: 0,
      createdAt: now,
      updatedAt: now,
    ),
  );
  final moduleId = await dao.insertModule(
    AcademyModulesCompanion.insert(
      courseId: courseId,
      slug: 'open-chords',
      title: 'Open Chords',
      position: 0,
      createdAt: now,
      updatedAt: now,
    ),
  );

  final lessonIds = <int>[];
  for (var index = 0; index < lessons; index++) {
    lessonIds.add(
      await dao.insertLesson(
        AcademyLessonsCompanion.insert(
          moduleId: moduleId,
          slug: 'lesson-$index',
          title: 'Lesson ${index + 1}',
          kind: LessonKind.technique,
          body: 'Fret it, strum it, listen.',
          suggestedBpm: const Value(70),
          position: index,
          createdAt: now,
          updatedAt: now,
        ),
      ),
    );
  }

  return (courseId: courseId, moduleId: moduleId, lessonIds: lessonIds);
}

/// Exercises on one lesson, for the tests about ticking them off.
///
/// Asked for separately rather than seeded with every course, because most progress
/// tests want a lesson with nothing under it: a row a test never mentions is a row
/// that makes its failures harder to read.
Future<List<int>> seedExercises(
  AppDatabase database,
  int lessonId, {
  int count = 2,
}) async {
  final dao = AcademyCourseDao(database);
  final now = DateTime.utc(2026, 8, 20, 9);

  return [
    for (var index = 0; index < count; index++)
      await dao.insertExercise(
        AcademyExercisesCompanion.insert(
          lessonId: lessonId,
          title: 'Exercise ${index + 1}',
          instructions: 'Slowly first, then a little faster.',
          startBpm: 60,
          targetBpm: 90,
          timeSignature: TimeSignature.fourFour,
          position: index,
          createdAt: now,
          updatedAt: now,
        ),
      ),
  ];
}
