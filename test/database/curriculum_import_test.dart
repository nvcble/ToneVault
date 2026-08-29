import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/learning_path.dart';
import 'package:tone_vault/core/enums/progress_state.dart';
import 'package:tone_vault/core/enums/skill_level.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/academy/data/curriculum_document.dart';
import 'package:tone_vault/features/academy/data/curriculum_importer.dart';
import 'package:tone_vault/features/academy/data/curriculum_repository.dart';
import 'package:tone_vault/features/academy/data/progress_repository.dart';
import '../support/curriculum_document_fixture.dart';
import '../support/repositories.dart';

/// What an import does to what is already stored, which is the part that has to be
/// right: a curriculum arrives more than once over the life of an install, and the
/// player's practice is recorded against the lessons it brings.
void main() {
  late AppDatabase database;
  late CurriculumImporter importer;
  late CurriculumRepository curriculum;
  late ProgressRepository progress;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    importer = curriculumImporter(database);
    curriculum = curriculumRepository(database);
    progress = progressRepository(database);
  });

  tearDown(() => database.close());

  /// The beginner rhythm courses, which is where everything the fixture writes
  /// lands.
  Future<List<AcademyCourse>> storedCourses() =>
      curriculum.watchCourses(LearningPath.rhythm, SkillLevel.beginner).first;

  Future<List<AcademyLesson>> storedLessons() async {
    final course = (await storedCourses()).single;
    final module = (await curriculum.watchModules(course.id).first).single;
    return curriculum.watchLessons(module.id).first;
  }

  test('a file becomes courses, modules, lessons and exercises', () async {
    final result = await importer.importFile(curriculumJson());

    expect(result, (added: 1, updated: 0, kept: 0));
    final course = (await storedCourses()).single;
    expect(course.title, 'First Chords');

    final module = (await curriculum.watchModules(course.id).first).single;
    expect(module.title, 'Open Chords');
    final lesson = (await curriculum.watchLessons(module.id).first).single;
    expect(lesson.title, 'Em and Am');
    expect(await curriculum.watchExercises(lesson.id).first, hasLength(1));
  });

  test(
    'the order courses are written in is the order they come back',
    () async {
      await importer.importFile(
        curriculumJson(
          courses: [
            courseMap(slug: 'second', title: 'Second'),
            courseMap(slug: 'first', title: 'First'),
          ],
        ),
      );

      final courses = await storedCourses();
      expect(courses.map((course) => course.title), ['Second', 'First']);
    },
  );

  test(
    'a course already stored is refused unless the caller says otherwise',
    () async {
      await importer.importFile(curriculumJson());

      await expectLater(
        importer.importFile(curriculumJson()),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.message,
            'message',
            contains('already has a course called "First Chords"'),
          ),
        ),
      );
    },
  );

  test('nothing is written when a file is refused half way through', () async {
    // The transaction is the whole promise: a file whose second course clashes
    // must not leave the first one behind.
    await importer.importFile(curriculumJson());

    await expectLater(
      importer.importFile(
        curriculumJson(
          courses: [
            courseMap(slug: 'brand-new', title: 'New'),
            courseMap(),
          ],
        ),
      ),
      throwsA(isA<AppFailure>()),
    );

    final courses = await storedCourses();
    expect(courses.map((course) => course.slug), [
      'rhythm-beginner-first-chords',
    ]);
  });

  test('keeping leaves a stored course exactly as it was', () async {
    await importer.importFile(curriculumJson());

    final result = await importer.importFile(
      curriculumJson(courses: [courseMap(title: 'Rewritten')]),
      onConflict: CurriculumConflict.keep,
    );

    expect(result, (added: 0, updated: 0, kept: 1));
    expect((await storedCourses()).single.title, 'First Chords');
  });

  test('keeping still adds a course that was not there', () async {
    await importer.importFile(curriculumJson());

    final result = await importer.importFile(
      curriculumJson(
        courses: [
          courseMap(),
          courseMap(slug: 'later', title: 'Added Later'),
        ],
      ),
      onConflict: CurriculumConflict.keep,
    );

    expect(result, (added: 1, updated: 0, kept: 1));
    expect((await storedCourses()).map((course) => course.title), [
      'First Chords',
      'Added Later',
    ]);
  });

  test('updating rewrites a course in place', () async {
    await importer.importFile(curriculumJson());

    final result = await importer.importFile(
      curriculumJson(
        courses: [
          courseMap(
            title: 'First Chords, Again',
            modules: [
              moduleMap(
                title: 'Open Chords, Revised',
                lessons: [lessonMap(title: 'Em and Am, Revised')],
              ),
            ],
          ),
        ],
      ),
      onConflict: CurriculumConflict.update,
    );

    expect(result, (added: 0, updated: 1, kept: 0));
    expect((await storedCourses()).single.title, 'First Chords, Again');
    expect((await storedLessons()).single.title, 'Em and Am, Revised');
  });

  test(
    'the practice a player has done survives the course being updated',
    () async {
      // The reason the writer matches by slug instead of clearing the course and
      // writing it again: the row id is what a year of practice points at.
      await importer.importFile(curriculumJson());
      final lessonId = (await storedLessons()).single.id;

      await progress.markCompleted(lessonId);
      await progress.addPracticeSeconds(lessonId, 1800);

      await importer.importFile(
        curriculumJson(
          courses: [
            courseMap(
              modules: [
                moduleMap(lessons: [lessonMap(title: 'Em and Am, Revised')]),
              ],
            ),
          ],
        ),
        onConflict: CurriculumConflict.update,
      );

      expect((await storedLessons()).single.id, lessonId);
      final row = await progress.watchProgress(lessonId).first;
      expect(row?.state, ProgressState.completed);
      expect(row?.practiceSeconds, 1800);
    },
  );

  test('a lesson the new curriculum no longer has is taken out', () async {
    await importer.importFile(
      curriculumJson(
        courses: [
          courseMap(
            modules: [
              moduleMap(
                lessons: [
                  lessonMap(),
                  lessonMap(slug: 'dropped', title: 'Gone'),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    await importer.importFile(
      curriculumJson(),
      onConflict: CurriculumConflict.update,
    );

    expect((await storedLessons()).map((lesson) => lesson.slug), ['em-and-am']);
  });

  test('re-ordering lessons in the file re-orders them in the app', () async {
    final first = lessonMap();
    final second = lessonMap(slug: 'c-and-g', title: 'C and G');

    await importer.importFile(
      curriculumJson(
        courses: [
          courseMap(
            modules: [
              moduleMap(lessons: [first, second]),
            ],
          ),
        ],
      ),
    );
    await importer.importFile(
      curriculumJson(
        courses: [
          courseMap(
            modules: [
              moduleMap(lessons: [second, first]),
            ],
          ),
        ],
      ),
      onConflict: CurriculumConflict.update,
    );

    expect((await storedLessons()).map((lesson) => lesson.slug), [
      'c-and-g',
      'em-and-am',
    ]);
  });

  test('the courses a file would replace can be asked for first', () async {
    // What the import screen shows before it writes anything, so a user is asked
    // rather than told afterwards.
    await importer.importFile(curriculumJson());

    expect(
      await importer.coursesAlreadyStored(decodeCurriculum(curriculumJson())),
      ['First Chords'],
    );
    expect(
      await importer.coursesAlreadyStored(
        decodeCurriculum(curriculumJson(courses: [courseMap(slug: 'unseen')])),
      ),
      isEmpty,
    );
  });
}
