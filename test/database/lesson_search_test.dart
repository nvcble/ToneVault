import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/academy_course_dao.dart';
import 'package:tone_vault/core/enums/learning_path.dart';
import 'package:tone_vault/core/enums/lesson_kind.dart';
import 'package:tone_vault/core/enums/skill_level.dart';
import 'package:tone_vault/features/academy/data/curriculum_repository.dart';
import '../support/curriculum_fixture.dart';
import '../support/repositories.dart';

/// Finding a lesson by what it is about, and finding where it lives.
void main() {
  late AppDatabase database;
  late CurriculumRepository curriculum;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    curriculum = curriculumRepository(database);
  });

  tearDown(() => database.close());

  test('a lesson is found by its title, its text or its course', () async {
    final seeded = await seedCourse(database);
    await _lesson(
      database,
      moduleId: seeded.moduleId,
      slug: 'barre-chords',
      title: 'Barre Chords',
      body: 'One finger across the strings, and the shape moves.',
    );

    // The title, then a word only the body has, then the course everything sits in.
    expect(await _titles(curriculum, 'barre'), ['Barre Chords']);
    expect(await _titles(curriculum, 'across the strings'), ['Barre Chords']);
    expect(await _titles(curriculum, 'First Chords'), [
      'Lesson 1',
      'Barre Chords',
    ]);
  });

  test('the case it is typed in does not matter', () async {
    final seeded = await seedCourse(database);
    await _lesson(
      database,
      moduleId: seeded.moduleId,
      slug: 'barre-chords',
      title: 'Barre Chords',
      body: 'One finger across the strings.',
    );

    expect(await _titles(curriculum, 'BARRE'), ['Barre Chords']);
  });

  test('a single letter is not a search yet', () async {
    await seedCourse(database);

    // Otherwise the first keystroke answers with the whole curriculum, which is the
    // table of contents the player already had.
    expect(await curriculum.searchLessons('L'), isEmpty);
    expect(await curriculum.searchLessons('  '), isEmpty);
    expect(await _titles(curriculum, 'Le'), ['Lesson 1']);
  });

  test('a search says which course each lesson came from', () async {
    await seedCourse(database);
    await seedCourse(
      database,
      slug: 'lead-beginner-first-notes',
      path: LearningPath.lead,
      level: SkillLevel.intermediate,
    );

    final found = await curriculum.searchLessons('Lesson');
    expect(found, hasLength(2));
    // Both seeded courses are titled the same, so what tells them apart is the row
    // the join brought back rather than the lesson itself.
    expect(found.map((place) => place.course.path), [
      LearningPath.rhythm,
      LearningPath.lead,
    ]);
    expect(found.map((place) => place.course.level), [
      SkillLevel.beginner,
      SkillLevel.intermediate,
    ]);
  });

  test('a bookmarked slug finds the course it has to be opened in', () async {
    final seeded = await seedCourse(database);

    final place = await curriculum.findLessonPlace('lesson-0');
    expect(place?.lesson.id, seeded.lessonIds.single);
    expect(place?.course.id, seeded.courseId);
    expect(place?.course.path, LearningPath.rhythm);
  });

  test('a slug that is no longer in the curriculum finds nothing', () async {
    await seedCourse(database);

    // A bookmark outlives an import that dropped its lesson, and the screen it is on
    // needs to be told rather than left waiting.
    expect(await curriculum.findLessonPlace('lesson-gone'), isNull);
  });
}

Future<String> _lesson(
  AppDatabase database, {
  required int moduleId,
  required String slug,
  required String title,
  required String body,
}) async {
  final now = DateTime.utc(2026, 8, 20, 9);
  await AcademyCourseDao(database).insertLesson(
    AcademyLessonsCompanion.insert(
      moduleId: moduleId,
      slug: slug,
      title: title,
      kind: LessonKind.technique,
      body: body,
      position: 1,
      suggestedBpm: const Value(70),
      createdAt: now,
      updatedAt: now,
    ),
  );
  return slug;
}

Future<List<String>> _titles(
  CurriculumRepository curriculum,
  String query,
) async {
  final found = await curriculum.searchLessons(query);
  return [for (final place in found) place.lesson.title];
}
