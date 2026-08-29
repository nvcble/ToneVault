import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/learning_path.dart';
import 'package:tone_vault/core/enums/skill_level.dart';
import 'package:tone_vault/features/academy/data/lesson_tally.dart';
import 'package:tone_vault/features/academy/data/progress_repository.dart';
import '../support/curriculum_fixture.dart';
import '../support/repositories.dart';

/// How far through the curriculum the player is, counted in the database rather
/// than by walking it in Dart.
void main() {
  late AppDatabase database;
  late ProgressRepository progress;
  var now = DateTime.utc(2026, 8, 20, 10);

  setUp(() {
    now = DateTime.utc(2026, 8, 20, 10);
    database = AppDatabase(NativeDatabase.memory());
    progress = progressRepository(database, clock: () => now);
  });

  tearDown(() => database.close());

  test('a course with no progress against it is counted, not skipped', () async {
    final course = await seedCourse(database, lessons: 3);

    final tally = await progress.watchCourseTally(course.courseId).first;

    // Three lessons and none done, which is a different answer from "no lessons":
    // the bar has to know there is something to be at the start of.
    expect(tally, (lessons: 3, done: 0));
    expect(tally.isEmpty, isFalse);
  });

  test('only a finished lesson counts as done', () async {
    final course = await seedCourse(database, lessons: 3);
    await progress.markOpened(course.lessonIds[0]);
    await progress.markCompleted(course.lessonIds[1]);
    await progress.addPracticeSeconds(course.lessonIds[2], 600);

    // Opened, and practised for ten minutes, are both still not done: only the
    // player saying so is.
    expect(await progress.watchCourseTally(course.courseId).first, (
      lessons: 3,
      done: 1,
    ));
  });

  test('clearing a lesson takes it back out of the count', () async {
    final course = await seedCourse(database, lessons: 2);
    await progress.markCompleted(course.lessonIds.first);
    await progress.clearProgress(course.lessonIds.first);

    expect(await progress.watchCourseTally(course.courseId).first, (
      lessons: 2,
      done: 0,
    ));
  });

  test('a course with nothing in it counts nothing', () async {
    final course = await seedCourse(database, lessons: 0);

    // No lessons means no group for the query to return, so the empty answer has to
    // come from the reading rather than from a row.
    expect(await progress.watchCourseTally(course.courseId).first, emptyTally);
  });

  test('a course that is not there counts nothing either', () async {
    expect(await progress.watchCourseTally(-1).first, emptyTally);
  });

  test('a path is counted a course at a time, keyed by course', () async {
    final beginner = await seedCourse(database, lessons: 2);
    final advanced = await seedCourse(
      database,
      slug: 'rhythm-advanced-time',
      level: SkillLevel.advanced,
      lessons: 4,
    );
    await progress.markCompleted(beginner.lessonIds.first);
    await progress.markCompleted(advanced.lessonIds.first);
    await progress.markCompleted(advanced.lessonIds.last);

    final tallies = await progress.watchPathTallies(LearningPath.rhythm).first;

    expect(tallies[beginner.courseId], (lessons: 2, done: 1));
    expect(tallies[advanced.courseId], (lessons: 4, done: 2));
  });

  test('and one path does not count the other', () async {
    final rhythm = await seedCourse(database, lessons: 2);
    final lead = await seedCourse(
      database,
      slug: 'lead-beginner-first-notes',
      path: LearningPath.lead,
      lessons: 3,
    );
    await progress.markCompleted(lead.lessonIds.first);

    final tallies = await progress.watchPathTallies(LearningPath.rhythm).first;

    expect(tallies.keys, [rhythm.courseId]);
    expect(sumTallies(tallies.values), (lessons: 2, done: 0));
  });

  test('the count follows a lesson being finished, without being asked', () async {
    final course = await seedCourse(database, lessons: 2);
    final seen = <LessonTally>[];
    final watching = progress
        .watchCourseTally(course.courseId)
        .listen(seen.add);
    addTearDown(watching.cancel);

    // Collected rather than matched in order, because the point is that the second
    // reading arrives without anything asking for it: the screens watch this, and a
    // ticked lesson has to move the bar on its own.
    await pumpEventQueue();
    await progress.markCompleted(course.lessonIds.first);
    await pumpEventQueue();

    expect(seen, [(lessons: 2, done: 0), (lessons: 2, done: 1)]);
  });

  test('the lesson to carry on with is the last one left unfinished', () async {
    final course = await seedCourse(database, lessons: 3);
    await progress.markOpened(course.lessonIds[0]);
    now = DateTime.utc(2026, 8, 21, 10);
    await progress.markOpened(course.lessonIds[1]);

    final place = await progress.watchUnfinished().first;

    expect(place!.lesson.id, course.lessonIds[1]);
    // The course comes with it, because the route to a lesson names the course.
    expect(place.course.id, course.courseId);
    expect(place.course.path, LearningPath.rhythm);
  });

  test('a lesson finished is not something to carry on with', () async {
    final course = await seedCourse(database, lessons: 2);
    await progress.markOpened(course.lessonIds.first);
    now = DateTime.utc(2026, 8, 21, 10);
    await progress.markCompleted(course.lessonIds.first);

    // Being sent back to the lesson they just ticked would be the app arguing with
    // them about whether they had finished it.
    expect(await progress.watchUnfinished().first, isNull);
  });

  test('and a lesson re-opened after finishing it is not one either', () async {
    final course = await seedCourse(database, lessons: 2);
    await progress.markCompleted(course.lessonIds.first);
    now = DateTime.utc(2026, 8, 25, 10);
    await progress.markOpened(course.lessonIds.first);

    // Revision keeps the tick, and a lesson with the tick is not unfinished.
    expect(await progress.watchUnfinished().first, isNull);
  });

  test(
    'a player who has opened nothing has nothing to carry on with',
    () async {
      await seedCourse(database, lessons: 2);

      expect(await progress.watchUnfinished().first, isNull);
    },
  );
}
