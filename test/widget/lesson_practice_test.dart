import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/theme/app_theme.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/database_provider.dart';
import 'package:tone_vault/features/academy/widgets/lesson_exercises.dart';
import 'package:tone_vault/features/academy/widgets/lesson_practice.dart';
import 'package:tone_vault/shared/formatting/app_date_format.dart';
import '../support/curriculum_fixture.dart';
import '../support/repositories.dart';
import '../support/screen_harness.dart';

/// What a lesson says about the player: which exercises they have got through, and
/// the practice they have put in.
///
/// A real in-memory database rather than stood-in streams, because the tick is a row
/// and the point of tapping it is that the row is there afterwards.
void main() {
  late AppDatabase database;
  late SeededCourse course;
  late List<int> exerciseIds;
  final practisedOn = DateTime.utc(2026, 8, 20, 19);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    course = await seedCourse(database);
    exerciseIds = await seedExercises(database, course.lessonIds.single);
  });

  tearDown(() => database.close());

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// A tap that writes, given time to land.
  ///
  /// Through `runAsync`, because a widget test runs on a fake clock: the write and
  /// the stream that carries the new row back both wait on real timers, and settling
  /// the fake one would never see either.
  Future<void> tapAndSettle(WidgetTester tester, Finder target) async {
    await tester.tap(target);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  Future<Set<int>> ticked(WidgetTester tester) async {
    return await tester.runAsync<Set<int>>(
          () => progressRepository(
            database,
          ).watchExercisesDone(course.lessonIds.single).first,
        ) ??
        const {};
  }

  group('the exercises of a lesson', () {
    screenTest('start unticked, every one of them', (tester) async {
      await pump(tester, LessonExercises(lessonId: course.lessonIds.single));

      expect(find.text('Exercise 1'), findsOne);
      expect(
        find.byIcon(Icons.check_box_outline_blank_outlined),
        findsNWidgets(2),
      );
      expect(find.byIcon(Icons.check_box), findsNothing);
    });

    screenTest('are ticked off one at a time', (tester) async {
      await pump(tester, LessonExercises(lessonId: course.lessonIds.single));

      await tapAndSettle(
        tester,
        find.byTooltip('I have got through this').first,
      );

      // The row is what the tick is, and the box follows it rather than the tap.
      expect(await ticked(tester), {exerciseIds.first});
      expect(find.byIcon(Icons.check_box), findsOne);
      expect(find.byIcon(Icons.check_box_outline_blank_outlined), findsOne);
    });

    screenTest('and can be unticked by the player who ticked them', (
      tester,
    ) async {
      await progressRepository(
        database,
      ).setExerciseDone(exerciseIds.first, done: true);

      await pump(tester, LessonExercises(lessonId: course.lessonIds.single));
      await tapAndSettle(
        tester,
        find.byTooltip('I have not got through this yet'),
      );

      // Nobody else's to take away, and nothing infers it: a player who finds they
      // cannot play it after all says so themselves.
      expect(await ticked(tester), isEmpty);
      expect(find.byIcon(Icons.check_box), findsNothing);
    });
  });

  group('the practice put into a lesson', () {
    screenTest('says nothing at all until there is some', (tester) async {
      await pump(
        tester,
        LessonPractice(lessonId: course.lessonIds.single, practiceSeconds: 0),
      );

      // A lesson that opens with "0 min practised" is the app asking after work the
      // player has not had a chance to do yet.
      expect(find.byIcon(Icons.timelapse), findsNothing);
    });

    screenTest('reads as the time, the sittings and the last of them', (
      tester,
    ) async {
      final progress = progressRepository(database, clock: () => practisedOn);
      await progress.addPracticeSeconds(course.lessonIds.single, 1800);

      await pump(
        tester,
        LessonPractice(
          lessonId: course.lessonIds.single,
          practiceSeconds: 1800,
        ),
      );

      expect(find.byIcon(Icons.timelapse), findsOne);
      expect(
        find.text(
          '30 min in one sitting, last on ${formatDate(practisedOn.toLocal())}',
        ),
        findsOne,
      );
    });

    screenTest('counts the evenings rather than adding them up itself', (
      tester,
    ) async {
      var now = practisedOn;
      final progress = progressRepository(database, clock: () => now);
      await progress.addPracticeSeconds(course.lessonIds.single, 1800);
      now = practisedOn.add(const Duration(days: 1));
      await progress.addPracticeSeconds(course.lessonIds.single, 3600);

      await pump(
        tester,
        LessonPractice(
          lessonId: course.lessonIds.single,
          practiceSeconds: 5400,
        ),
      );

      expect(find.textContaining('1 h 30 min over 2 sittings'), findsOne);
      expect(
        find.textContaining('last on ${formatDate(now.toLocal())}'),
        findsOne,
      );
    });

    screenTest('shows the total even where no sitting is recorded for it', (
      tester,
    ) async {
      // A phone that upgraded into this: the hours were recorded as a total before
      // they were recorded as sittings, and the total is the one that holds them.
      await pump(
        tester,
        LessonPractice(
          lessonId: course.lessonIds.single,
          practiceSeconds: 5400,
        ),
      );

      expect(find.text('1 h 30 min'), findsOne);
      expect(find.textContaining('sitting'), findsNothing);
    });
  });
}
