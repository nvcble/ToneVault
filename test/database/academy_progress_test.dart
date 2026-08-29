import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/learning_path.dart';
import 'package:tone_vault/core/enums/progress_state.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/academy/data/progress_repository.dart';
import '../support/curriculum_fixture.dart';
import '../support/repositories.dart';

/// What the Academy records about the player, and what it refuses to lose.
void main() {
  late AppDatabase database;
  late ProgressRepository progress;
  late SeededCourse course;
  var now = DateTime.utc(2026, 8, 20, 10);

  setUp(() async {
    // Reset, because the tests that move the clock forward move this one.
    now = DateTime.utc(2026, 8, 20, 10);
    database = AppDatabase(NativeDatabase.memory());
    progress = progressRepository(database, clock: () => now);
    course = await seedCourse(database, lessons: 3);
  });

  tearDown(() => database.close());

  test('a lesson never opened has no progress at all', () async {
    // Not-started is the absence of a row rather than a row saying so, which is
    // what lets an untouched Academy be told apart from one worked through.
    expect(await progress.watchProgress(course.lessonIds.first).first, isNull);
    expect(await progress.watchCourseProgress(course.courseId).first, isEmpty);
  });

  test('opening a lesson starts it', () async {
    await progress.markOpened(course.lessonIds.first);

    final row = await progress.watchProgress(course.lessonIds.first).first;
    expect(row!.state, ProgressState.inProgress);
    expect(row.lastOpenedAt, now);
    expect(row.completedAt, isNull);
    expect(row.practiceSeconds, 0);
  });

  test('opening the same lesson again is one row, not two', () async {
    await progress.markOpened(course.lessonIds.first);
    now = DateTime.utc(2026, 8, 21, 10);
    await progress.markOpened(course.lessonIds.first);

    final rows = await progress.watchCourseProgress(course.courseId).first;
    expect(rows, hasLength(1));
    expect(rows.single.lastOpenedAt, DateTime.utc(2026, 8, 21, 10));
  });

  test('a lesson opened again after finishing it stays finished', () async {
    await progress.markCompleted(course.lessonIds.first);
    final finishedOn = DateTime.utc(2026, 8, 20, 10);
    now = DateTime.utc(2026, 8, 25, 10);

    await progress.markOpened(course.lessonIds.first);

    // Going back to check something is revision, and revision does not take the
    // tick away or move the day they finished on.
    final row = await progress.watchProgress(course.lessonIds.first).first;
    expect(row!.state, ProgressState.completed);
    expect(row.completedAt, finishedOn);
    expect(row.lastOpenedAt, DateTime.utc(2026, 8, 25, 10));
  });

  test('practice adds up across sittings', () async {
    await progress.addPracticeSeconds(course.lessonIds.first, 600);
    await progress.addPracticeSeconds(course.lessonIds.first, 300);

    final row = await progress.watchProgress(course.lessonIds.first).first;
    expect(row!.practiceSeconds, 900);
    // Practising a lesson is starting it, for anyone who never tapped the lesson
    // itself first.
    expect(row.state, ProgressState.inProgress);
  });

  test('finishing a lesson keeps the practice already recorded', () async {
    await progress.addPracticeSeconds(course.lessonIds.first, 900);
    await progress.markCompleted(course.lessonIds.first);

    final row = await progress.watchProgress(course.lessonIds.first).first;
    expect(row!.state, ProgressState.completed);
    expect(row.practiceSeconds, 900);
  });

  test('no practice is a refusal rather than a silent nothing', () async {
    await expectLater(
      progress.addPracticeSeconds(course.lessonIds.first, 0),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.message,
          'message',
          'Practice time has to be more than nothing.',
        ),
      ),
    );
    expect(await progress.watchProgress(course.lessonIds.first).first, isNull);
  });

  test('clearing progress forgets the lesson entirely', () async {
    await progress.addPracticeSeconds(course.lessonIds.first, 900);

    expect(await progress.clearProgress(course.lessonIds.first), isTrue);
    expect(await progress.watchProgress(course.lessonIds.first).first, isNull);
    // Nothing to forget is not a failure, only a false.
    expect(await progress.clearProgress(course.lessonIds.first), isFalse);
  });

  test('a course counts only the lessons inside it', () async {
    final other = await seedCourse(
      database,
      slug: 'lead-beginner-first-notes',
      path: LearningPath.lead,
    );
    await progress.markOpened(course.lessonIds.first);
    await progress.markCompleted(course.lessonIds.last);
    await progress.markOpened(other.lessonIds.single);

    final rows = await progress.watchCourseProgress(course.courseId).first;

    expect(rows.map((row) => row.lessonId), [
      course.lessonIds.first,
      course.lessonIds.last,
    ]);
  });

  test('progress goes when the lesson it was against goes', () async {
    // The cascade the tables declare, asserted here because it is the reason the
    // importer has to update lessons in place rather than write them again: this
    // is what a re-import would do to a year of practice.
    await progress.addPracticeSeconds(course.lessonIds.first, 900);

    expect(await curriculumRepository(database).hasAnyCourse(), isTrue);
    await database.academyCourseDao.deleteCourse(course.courseId);

    expect(await progress.watchCourseProgress(course.courseId).first, isEmpty);
    expect(await curriculumRepository(database).hasAnyCourse(), isFalse);
  });
}
