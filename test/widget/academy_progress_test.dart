import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tone_vault/app/router/routes.dart';
import 'package:tone_vault/app/theme/app_theme.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/database_provider.dart';
import 'package:tone_vault/core/enums/learning_path.dart';
import 'package:tone_vault/core/enums/skill_level.dart';
import 'package:tone_vault/features/academy/providers/academy_providers.dart';
import 'package:tone_vault/features/academy/routes/academy_routes.dart';
import 'package:tone_vault/features/academy/screens/academy_screen.dart';
import 'package:tone_vault/features/academy/screens/course_screen.dart';
import 'package:tone_vault/features/academy/screens/learning_path_screen.dart';
import 'package:tone_vault/features/academy/screens/level_screen.dart';
import '../support/curriculum_document_fixture.dart';
import '../support/repositories.dart';
import '../support/screen_harness.dart';

/// How far through the curriculum the player is, as the screens say it.
///
/// A real curriculum in a real in-memory database rather than stood-in streams: the
/// count is a query, and a test that hands the screens a number would say nothing
/// about whether the query behind it is asked or right.
void main() {
  late AppDatabase database;
  late int courseId;
  late List<int> lessonIds;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await curriculumImporter(database).importFile(
      curriculumJson(
        courses: [
          courseMap(
            modules: [
              moduleMap(
                lessons: [
                  lessonMap(),
                  lessonMap(slug: 'c-and-g', title: 'C and G'),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    final curriculum = curriculumRepository(database);
    courseId =
        (await curriculum
                .watchCourses(LearningPath.rhythm, SkillLevel.beginner)
                .first)
            .single
            .id;
    final moduleId = (await curriculum.watchModules(courseId).first).single.id;
    lessonIds = [
      for (final lesson in await curriculum.watchLessons(moduleId).first)
        lesson.id,
    ];
  });

  tearDown(() => database.close());

  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          curriculumSeedProvider.overrideWith((ref) async => 0),
        ],
        child: MaterialApp(theme: AppTheme.dark(), home: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The Academy on its own router, for the one test that has to follow a link out
  /// of it and see where it lands.
  Future<void> pumpAcademy(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          curriculumSeedProvider.overrideWith((ref) async => 0),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark(),
          routerConfig: GoRouter(
            initialLocation: Routes.academy,
            routes: academyRoutes(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  screenTest('a course nobody has started says so rather than showing nought', (
    tester,
  ) async {
    await pump(
      tester,
      const LevelScreen(path: LearningPath.rhythm, level: SkillLevel.beginner),
    );

    // "Not started" in the player's own words. A bar sitting at nought per cent is
    // the same fact read off a chart.
    expect(find.text('Not started - 2 lessons'), findsOne);
  });

  screenTest('finishing a lesson moves the count on the course', (
    tester,
  ) async {
    await progressRepository(database).markCompleted(lessonIds.first);

    await pump(
      tester,
      const LevelScreen(path: LearningPath.rhythm, level: SkillLevel.beginner),
    );

    expect(find.text('1 of 2 lessons - 50%'), findsOne);
    expect(find.byType(LinearProgressIndicator), findsOne);
  });

  screenTest('and finishing them all says so as well', (tester) async {
    final progress = progressRepository(database);
    for (final lessonId in lessonIds) {
      await progress.markCompleted(lessonId);
    }

    await pump(
      tester,
      const LevelScreen(path: LearningPath.rhythm, level: SkillLevel.beginner),
    );

    expect(find.text('All 2 lessons done'), findsOne);
  });

  screenTest('a level with nothing in it shows no bar at all', (tester) async {
    await pump(
      tester,
      const LevelScreen(
        path: LearningPath.lead,
        level: SkillLevel.professional,
      ),
    );

    // Nothing to be part way through is not the same as none of it done, and a bar
    // at nought here would read as the player's fault.
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  screenTest('a course carries its own count above its modules', (
    tester,
  ) async {
    await progressRepository(database).markCompleted(lessonIds.first);

    await pump(tester, CourseScreen(courseId: courseId));

    expect(find.text('1 of 2 lessons - 50%'), findsOne);
  });

  screenTest('a path counts every level it has', (tester) async {
    await progressRepository(database).markCompleted(lessonIds.first);

    await pump(tester, const LearningPathScreen(path: LearningPath.rhythm));

    // On Beginner, which is where the two lessons are, and nowhere else: the other
    // three levels have nothing loaded into them.
    expect(find.text('1 of 2 lessons - 50%'), findsOne);
    expect(find.byType(LinearProgressIndicator), findsOne);
  });

  screenTest('the way in offers nothing to carry on with, at first', (
    tester,
  ) async {
    await pump(tester, const AcademyScreen());

    // A player who has opened nothing is not being asked to remember anything.
    expect(find.text('Carry on'), findsNothing);
    expect(find.text('Em and Am'), findsNothing);
  });

  screenTest('and offers the lesson left unfinished once there is one', (
    tester,
  ) async {
    await progressRepository(database).markOpened(lessonIds.first);

    await pump(tester, const AcademyScreen());

    expect(find.text('Carry on'), findsOne);
    expect(find.text('Em and Am'), findsOne);
    // The course and the level with it: a lesson title alone does not say where in
    // the curriculum it came from.
    expect(find.text('First Chords - Beginner'), findsOne);
  });

  screenTest('a lesson finished is dropped from the carry-on offer', (
    tester,
  ) async {
    await progressRepository(database).markCompleted(lessonIds.first);

    await pump(tester, const AcademyScreen());

    expect(find.text('Carry on'), findsNothing);
  });

  screenTest('carrying on lands on the lesson itself, already open', (
    tester,
  ) async {
    await progressRepository(database).markOpened(lessonIds.last);

    await pumpAcademy(tester);
    await tester.tap(find.text('C and G'));
    await tester.pumpAndSettle();

    // The course screen, with the one lesson expanded. Landing on the course and
    // hunting for the lesson again is the work the section exists to save.
    expect(find.widgetWithText(AppBar, 'First Chords'), findsOne);
    expect(find.textContaining('Two fingers'), findsOne);
  });
}
