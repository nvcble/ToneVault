import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/learning_path.dart';
import 'package:tone_vault/core/enums/music_genre.dart';
import 'package:tone_vault/core/enums/skill_level.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/academy/data/curriculum_document.dart';
import '../support/curriculum_document_fixture.dart';
import '../support/repositories.dart';

/// The Academy read back out as a file, and that file read into another Academy.
///
/// Two databases on purpose. Asserting on the JSON would only say the exporter is
/// self-consistent; importing what it wrote into an empty app is the thing a user
/// actually does when they send a course to somebody.
void main() {
  late AppDatabase database;
  late AppDatabase other;
  final exportedAt = DateTime.utc(2026, 8, 28, 9);

  setUpAll(() {
    // Two databases at once is the point of this file, not a mistake to be warned
    // about: each has its own in-memory executor and they never share a connection.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  tearDownAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = false;
  });

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    other = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
    await other.close();
  });

  /// The curriculum as the other app would have it after being sent the file.
  Future<void> sendItOn(String contents) =>
      curriculumImporter(other).importFile(contents);

  test('everything stored is written out and reads back in', () async {
    await curriculumImporter(database).importFile(curriculumJson());

    final export = await curriculumExporter(
      database,
      clock: () => exportedAt,
    ).exportEverything();
    await sendItOn(export.contents);

    final courses = await curriculumRepository(
      other,
    ).watchCourses(LearningPath.rhythm, SkillLevel.beginner).first;

    expect(courses.single.slug, 'rhythm-beginner-first-chords');
    expect(courses.single.title, 'First Chords');
  });

  test('down to what a lesson says and what it points at', () async {
    await curriculumImporter(database).importFile(
      curriculumJson(
        courses: [
          courseMap(
            modules: [
              moduleMap(
                lessons: [
                  lessonMap(genre: 'blues', theoryKeys: const ['Cmaj7', 'A7']),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    final export = await curriculumExporter(database).exportEverything();
    await sendItOn(export.contents);

    final curriculum = curriculumRepository(other);
    final courseId =
        (await curriculum
                .watchCourses(LearningPath.rhythm, SkillLevel.beginner)
                .first)
            .single
            .id;
    final moduleId = (await curriculum.watchModules(courseId).first).single.id;
    final lesson = (await curriculum.watchLessons(moduleId).first).single;

    expect(lesson.title, 'Em and Am');
    expect(lesson.body, 'Two fingers, moved across one string.');
    expect(lesson.genre, MusicGenre.blues);
    expect(lesson.suggestedBpm, 60);
    // The keys are what the fretboard under the lesson is drawn from. A lesson that
    // arrived without them would read as prose about a chord it cannot show.
    expect(lesson.theoryKeys, contains('Cmaj7'));

    final exercises = await curriculum.watchExercises(lesson.id).first;
    expect(exercises.single.title, 'One chord a bar');
    expect(exercises.single.targetBpm, 100);
  });

  test('and the order the curriculum teaches them in', () async {
    await curriculumImporter(database).importFile(
      curriculumJson(
        courses: [
          courseMap(
            modules: [
              moduleMap(
                slug: 'first-shapes',
                lessons: [
                  lessonMap(slug: 'em', title: 'Em'),
                  lessonMap(slug: 'am', title: 'Am'),
                ],
              ),
              moduleMap(slug: 'changes', title: 'Changes'),
            ],
          ),
        ],
      ),
    );

    final export = await curriculumExporter(database).exportEverything();
    await sendItOn(export.contents);

    final curriculum = curriculumRepository(other);
    final courseId =
        (await curriculum
                .watchCourses(LearningPath.rhythm, SkillLevel.beginner)
                .first)
            .single
            .id;
    final modules = await curriculum.watchModules(courseId).first;
    final lessons = await curriculum.watchLessons(modules.first.id).first;

    expect(modules.map((module) => module.slug), ['first-shapes', 'changes']);
    expect(lessons.map((lesson) => lesson.title), ['Em', 'Am']);
  });

  test('several courses go together, each keeping its own path', () async {
    await curriculumImporter(database).importFile(
      curriculumJson(
        courses: [
          courseMap(),
          courseMap(
            slug: 'lead-advanced-bends',
            path: 'lead',
            level: 'advanced',
            title: 'Bending in Tune',
          ),
        ],
      ),
    );

    final export = await curriculumExporter(database).exportEverything();
    await sendItOn(export.contents);

    final curriculum = curriculumRepository(other);
    final lead = await curriculum
        .watchCourses(LearningPath.lead, SkillLevel.advanced)
        .first;

    expect(lead.single.title, 'Bending in Tune');
    expect(
      (await curriculum
              .watchCourses(LearningPath.rhythm, SkillLevel.beginner)
              .first)
          .single
          .title,
      'First Chords',
    );
  });

  test('one course can be sent on by itself', () async {
    await curriculumImporter(database).importFile(
      curriculumJson(
        courses: [
          courseMap(),
          courseMap(
            slug: 'lead-beginner-first-notes',
            path: 'lead',
            title: 'First Notes',
          ),
        ],
      ),
    );
    final courseId = (await curriculumRepository(
      database,
    ).watchCourses(LearningPath.rhythm, SkillLevel.beginner).first).single.id;

    final export = await curriculumExporter(
      database,
      clock: () => exportedAt,
    ).exportCourse(courseId);
    await sendItOn(export.contents);

    // Only the one, and named after it, so the file says what it is before it is
    // opened.
    expect(decodeCurriculum(export.contents).single.title, 'First Chords');
    expect(export.fileName, contains('rhythm-beginner-first-chords'));
    expect(
      await curriculumRepository(
        other,
      ).watchCourses(LearningPath.lead, SkillLevel.beginner).first,
      isEmpty,
    );
  });

  test('an Academy with nothing in it refuses to write a file', () async {
    // The importer refuses a file with no courses in it, so writing one would be
    // handing the user something that fails on the other phone.
    await expectLater(
      curriculumExporter(database).exportEverything(),
      throwsA(isA<AppFailure>()),
    );
  });

  test('and a course that is no longer there says so', () async {
    await expectLater(
      curriculumExporter(database).exportCourse(-1),
      throwsA(isA<AppFailure>()),
    );
  });

  test('what leaves the app is the curriculum, never the practice', () async {
    await curriculumImporter(database).importFile(curriculumJson());
    final curriculum = curriculumRepository(database);
    final courseId =
        (await curriculum
                .watchCourses(LearningPath.rhythm, SkillLevel.beginner)
                .first)
            .single
            .id;
    final moduleId = (await curriculum.watchModules(courseId).first).single.id;
    final lessonId = (await curriculum.watchLessons(moduleId).first).single.id;
    await progressRepository(database).markCompleted(lessonId);
    await progressRepository(database).addPracticeSeconds(lessonId, 900);

    final export = await curriculumExporter(database).exportEverything();
    await sendItOn(export.contents);

    // A course sent to a student arrives with nothing done in it. Progress is one
    // player's own, and a file carrying it would tell them they had finished
    // lessons they have never opened.
    expect(export.contents, isNot(contains('practiceSeconds')));
    expect(export.contents, isNot(contains('completed')));

    final otherCurriculum = curriculumRepository(other);
    final theirCourse =
        (await otherCurriculum
                .watchCourses(LearningPath.rhythm, SkillLevel.beginner)
                .first)
            .single;
    final theirModule =
        (await otherCurriculum.watchModules(theirCourse.id).first).single;
    final theirLesson =
        (await otherCurriculum.watchLessons(theirModule.id).first).single;

    expect(
      await progressRepository(other).watchProgress(theirLesson.id).first,
      isNull,
    );
  });

  test('and ids, which belong to the phone they were written on', () async {
    await curriculumImporter(database).importFile(curriculumJson());

    final export = await curriculumExporter(database).exportEverything();

    // No ids and no positions. A course matched by slug is the same course after
    // being re-imported; one matched by id would be a different course on every
    // phone it landed on.
    expect(export.contents, isNot(contains('"id"')));
    expect(export.contents, isNot(contains('"position"')));
    expect(export.contents, isNot(contains('createdAt')));
  });
}
