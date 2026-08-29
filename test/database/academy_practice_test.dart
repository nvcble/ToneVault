import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/features/academy/data/progress_repository.dart';
import '../support/curriculum_fixture.dart';
import '../support/repositories.dart';

/// The two records that are the player's own doing: the exercises they got through,
/// and each sitting of practice they put in.
///
/// Both hang off the curriculum rather than off the progress row, so what happens to
/// them when a lesson or an exercise goes is asserted here too. A re-import that
/// quietly took a year of ticks with it would look like nothing at all.
void main() {
  late AppDatabase database;
  late ProgressRepository progress;
  late SeededCourse course;
  late List<int> exerciseIds;
  var now = DateTime.utc(2026, 8, 20, 10);

  setUp(() async {
    // Reset, because the tests that move the clock forward move this one.
    now = DateTime.utc(2026, 8, 20, 10);
    database = AppDatabase(NativeDatabase.memory());
    progress = progressRepository(database, clock: () => now);
    course = await seedCourse(database, lessons: 2);
    exerciseIds = await seedExercises(database, course.lessonIds.first);
  });

  tearDown(() => database.close());

  Future<List<AcademyExerciseProgressRow>> ticks() =>
      database.select(database.academyExerciseProgress).get();

  group('the exercises got through', () {
    test('a lesson nobody has worked at has none ticked', () async {
      expect(
        await progress.watchExercisesDone(course.lessonIds.first).first,
        isEmpty,
      );
    });

    test('ticking one ticks that one and no other', () async {
      await progress.setExerciseDone(exerciseIds.first, done: true);

      expect(await progress.watchExercisesDone(course.lessonIds.first).first, {
        exerciseIds.first,
      });
      expect(await ticks(), hasLength(1));
      expect((await ticks()).single.completedAt, now);
    });

    test('unticking takes the tick away and leaves nothing behind', () async {
      await progress.setExerciseDone(exerciseIds.first, done: true);
      await progress.setExerciseDone(exerciseIds.first, done: false);

      // Row-presence is the whole record: a row saying "not done" would be a second
      // answer to a question the absence already answers.
      expect(
        await progress.watchExercisesDone(course.lessonIds.first).first,
        isEmpty,
      );
      expect(await ticks(), isEmpty);
    });

    test('unticking one that was never ticked is not a failure', () async {
      // A tap on a stale screen, which is not the player doing anything wrong.
      await progress.setExerciseDone(exerciseIds.first, done: false);

      expect(await ticks(), isEmpty);
    });

    test('ticking twice is one tick, on the day it was first given', () async {
      await progress.setExerciseDone(exerciseIds.first, done: true);
      now = DateTime.utc(2026, 9, 1, 10);
      await progress.setExerciseDone(exerciseIds.first, done: true);

      // What a double tap on a slow phone does. Neither a refusal nor a second row.
      expect(await ticks(), hasLength(1));
      expect((await ticks()).single.completedAt, DateTime.utc(2026, 8, 20, 10));
    });

    test('the ticks of one lesson are not the ticks of another', () async {
      final others = await seedExercises(
        database,
        course.lessonIds.last,
        count: 1,
      );
      await progress.setExerciseDone(exerciseIds.last, done: true);
      await progress.setExerciseDone(others.single, done: true);

      expect(await progress.watchExercisesDone(course.lessonIds.first).first, {
        exerciseIds.last,
      });
      expect(await progress.watchExercisesDone(course.lessonIds.last).first, {
        others.single,
      });
    });

    test('an exercise taken out of a lesson takes its tick with it', () async {
      // The cascade the table declares. An importer that replaces an exercise leaves
      // no tick behind pointing at something the curriculum no longer has.
      await progress.setExerciseDone(exerciseIds.first, done: true);

      await database.academyCourseDao.deleteExercises([exerciseIds.first]);

      expect(await ticks(), isEmpty);
    });
  });

  group('the sittings of practice', () {
    test('practice is filed as a sitting as well as a total', () async {
      await progress.addPracticeSeconds(course.lessonIds.first, 600);

      final sessions = await progress
          .watchPracticeSessions(course.lessonIds.first)
          .first;
      expect(sessions.single.seconds, 600);
      expect(sessions.single.endedAt, now);
      expect(
        (await progress.watchProgress(course.lessonIds.first).first)!
            .practiceSeconds,
        600,
      );
    });

    test('every sitting is kept, most recent first', () async {
      await progress.addPracticeSeconds(course.lessonIds.first, 600);
      now = DateTime.utc(2026, 8, 21, 19);
      await progress.addPracticeSeconds(course.lessonIds.first, 300);
      now = DateTime.utc(2026, 8, 22, 19);
      await progress.addPracticeSeconds(course.lessonIds.first, 900);

      final sessions = await progress
          .watchPracticeSessions(course.lessonIds.first)
          .first;
      // The total is one number; the sittings are how it was earned, and the lesson
      // says the last one by date.
      expect(sessions.map((session) => session.seconds), [900, 300, 600]);
      expect(
        (await progress.watchProgress(course.lessonIds.first).first)!
            .practiceSeconds,
        1800,
      );
    });

    test('a refused sitting is not filed either', () async {
      await expectLater(
        progress.addPracticeSeconds(course.lessonIds.first, 0),
        throwsA(anything),
      );

      expect(
        await progress.watchPracticeSessions(course.lessonIds.first).first,
        isEmpty,
      );
    });

    test('the sittings of one lesson are only its own', () async {
      await progress.addPracticeSeconds(course.lessonIds.first, 600);
      await progress.addPracticeSeconds(course.lessonIds.last, 300);

      expect(
        await progress.watchPracticeSessions(course.lessonIds.first).first,
        hasLength(1),
      );
      expect(
        (await progress.watchPracticeSessions(course.lessonIds.last).first)
            .single
            .seconds,
        300,
      );
    });

    test('the sittings go when the lesson they were at goes', () async {
      await progress.addPracticeSeconds(course.lessonIds.first, 600);

      await database.academyCourseDao.deleteCourse(course.courseId);

      expect(
        await progress.watchPracticeSessions(course.lessonIds.first).first,
        isEmpty,
      );
    });
  });

  test('clearing progress forgets the sittings and the ticks as well', () async {
    await progress.addPracticeSeconds(course.lessonIds.first, 600);
    await progress.setExerciseDone(exerciseIds.first, done: true);

    expect(await progress.clearProgress(course.lessonIds.first), isTrue);

    // Not-started has to mean not-started everywhere. A lesson that says it while
    // three of its exercises are still ticked is the app disagreeing with itself.
    expect(await progress.watchProgress(course.lessonIds.first).first, isNull);
    expect(
      await progress.watchPracticeSessions(course.lessonIds.first).first,
      isEmpty,
    );
    expect(await ticks(), isEmpty);
  });

  test('clearing one lesson leaves the next one alone', () async {
    final others = await seedExercises(
      database,
      course.lessonIds.last,
      count: 1,
    );
    await progress.addPracticeSeconds(course.lessonIds.last, 900);
    await progress.setExerciseDone(others.single, done: true);

    await progress.clearProgress(course.lessonIds.first);

    expect(
      await progress.watchPracticeSessions(course.lessonIds.last).first,
      hasLength(1),
    );
    expect(await progress.watchExercisesDone(course.lessonIds.last).first, {
      others.single,
    });
  });
}
