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
import 'package:tone_vault/features/academy/data/curriculum_importer.dart';
import 'package:tone_vault/features/academy/providers/academy_providers.dart';
import 'package:tone_vault/features/academy/routes/academy_routes.dart';
import 'package:tone_vault/features/academy/screens/course_screen.dart';
import 'package:tone_vault/features/academy/screens/lesson_screen.dart';
import 'package:tone_vault/features/academy/screens/level_screen.dart';
import 'package:tone_vault/features/academy/widgets/lesson_hero.dart';
import '../support/curriculum_document_fixture.dart';
import '../support/repositories.dart';
import '../support/screen_harness.dart';

/// A course as the player meets it: a list of what there is to learn, one lesson of
/// it opened on its own page, read and ticked off.
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
                  lessonMap(
                    body:
                        'Two fingers.\n\n- Second finger, A string, fret 2\n'
                        '- Third finger, D string, fret 2',
                  ),
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

  /// The seed is stood in with a value, because these tests put the curriculum in
  /// themselves and the shipped one would arrive on top of it.
  List<Override> overrides() => [
    appDatabaseProvider.overrideWithValue(database),
    curriculumSeedProvider.overrideWith((ref) async => 0),
  ];

  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(theme: AppTheme.dark(), home: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The Academy on its own router, for the tests that follow a lesson row to the
  /// page it opens and come back from it.
  Future<void> pumpAt(WidgetTester tester, String location) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp.router(
          theme: AppTheme.dark(),
          routerConfig: GoRouter(
            initialLocation: location,
            routes: academyRoutes(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Widget courseScreen() => CourseScreen(
    courseId: courseId,
    path: LearningPath.rhythm,
    level: SkillLevel.beginner,
  );

  String courseLocation() =>
      Routes.academyCourse(LearningPath.rhythm, SkillLevel.beginner, courseId);

  /// Taps a button that may be below the fold, which most of them are on a lesson.
  Future<void> tap(WidgetTester tester, String label) async {
    final button = find.text(label);
    await tester.dragUntilVisible(
      button,
      find.byType(ListView),
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  screenTest('a level lists the courses that were loaded into it', (
    tester,
  ) async {
    await pump(
      tester,
      const LevelScreen(path: LearningPath.rhythm, level: SkillLevel.beginner),
    );

    expect(find.text('First Chords'), findsOne);
    expect(find.text('Six shapes and the changes between them.'), findsOne);
    expect(find.text('No courses here yet'), findsNothing);
  });

  screenTest('a level the curriculum says nothing about says so', (
    tester,
  ) async {
    await pump(
      tester,
      const LevelScreen(
        path: LearningPath.lead,
        level: SkillLevel.professional,
      ),
    );

    expect(find.text('No courses here yet'), findsOne);
  });

  screenTest('a course lists its modules and the lessons in them', (
    tester,
  ) async {
    await pump(tester, courseScreen());

    expect(find.widgetWithText(AppBar, 'First Chords'), findsOne);
    expect(find.text('Open Chords'), findsOne);
    expect(find.text('Em and Am'), findsOne);
    expect(find.text('C and G'), findsOne);

    // A list of what there is to learn and nothing else. The text of a lesson is on
    // the lesson's own page, which is what keeps a course of forty readable.
    expect(find.textContaining('Two fingers'), findsNothing);
    expect(find.text('Watch on YouTube'), findsNothing);
  });

  screenTest('a lesson row says what it asks of the player and how long', (
    tester,
  ) async {
    await pump(tester, courseScreen());

    expect(find.text('Technique - 15 min'), findsExactly(2));
  });

  screenTest('tapping a lesson opens it on a page of its own', (tester) async {
    await pumpAt(tester, courseLocation());

    await tester.tap(find.text('Em and Am'));
    await tester.pumpAndSettle();

    // The lesson's own page, titled as the lesson rather than as the course, with
    // the rest of the course no longer between the player and the reading.
    expect(find.widgetWithText(AppBar, 'Em and Am'), findsOne);
    expect(find.text('C and G'), findsNothing);
    expect(find.textContaining('Two fingers'), findsOne);
  });

  screenTest('a lesson shows its text and its exercises', (tester) async {
    await pump(tester, LessonScreen(lessonId: lessonIds.first));

    expect(find.textContaining('Two fingers'), findsOne);
    // The list in the body is rendered as a list rather than as its markdown.
    expect(find.textContaining('• Second finger'), findsOne);
    expect(find.text('One chord a bar'), findsOne);
    expect(find.textContaining('60 to 100 BPM'), findsOne);
  });

  screenTest('and reads as a lesson rather than as a page of text', (
    tester,
  ) async {
    await pump(tester, LessonScreen(lessonId: lessonIds.first));

    // The teaching around the body, in the order an instructor would say it: what
    // the lesson is for, then what goes wrong, then what to do about it, then
    // where to go next.
    expect(find.text('What this is for'), findsOne);
    expect(find.text('Change between Em and Am without stopping.'), findsOne);
    expect(find.text('Common mistakes'), findsOne);
    expect(find.text('• Placing each finger separately.'), findsOne);
    expect(find.text('Practice tips'), findsOne);
    expect(find.text('• Move the pair as one block.'), findsOne);
    expect(find.text('Next: C and G'), findsOne);
  });

  screenTest('a lesson draws the chords it says it teaches', (tester) async {
    await pump(tester, LessonScreen(lessonId: lessonIds.first));

    // Em and Am are what the lesson points at, and the neck is drawn from them.
    expect(find.text('On the neck'), findsOne);
    expect(find.widgetWithText(ChoiceChip, 'Em'), findsOne);
    expect(find.widgetWithText(ChoiceChip, 'Am'), findsOne);
  });

  screenTest('and opens with a picture of itself and a video to watch', (
    tester,
  ) async {
    await pump(tester, LessonScreen(lessonId: lessonIds.first));

    // Nothing was downloaded: this lesson names no picture, so the banner is drawn
    // from the shapes it teaches. The video is offered all the same - it is a search
    // for the lesson's own title, which a player who learns by watching would have
    // typed themselves.
    expect(find.byType(LessonHero), findsOne);
    expect(find.byType(Image), findsNothing);
    expect(find.text('Watch on YouTube'), findsOne);
  });

  screenTest('a lesson that names a video is shown the still of it', (
    tester,
  ) async {
    // The same two lessons again with a video pinned to the first, which is what a
    // curated course looks like. The banner becomes YouTube's own still of that
    // video, so curating one link gets the picture with it.
    await curriculumImporter(database).importFile(
      curriculumJson(
        courses: [
          courseMap(
            modules: [
              moduleMap(
                lessons: [
                  lessonMap(
                    videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      onConflict: CurriculumConflict.update,
    );

    await pump(tester, LessonScreen(lessonId: lessonIds.first));

    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as NetworkImage).url,
      'https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
    );
  });

  screenTest('opening a lesson is what records that it was started', (
    tester,
  ) async {
    await pumpAt(tester, courseLocation());

    await tester.tap(find.text('Em and Am'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    // The one that was opened, and only that one.
    expect(find.text('Technique - 15 min - In progress'), findsOne);
    expect(find.text('Technique - 15 min'), findsOne);
  });

  screenTest('finishing a lesson ticks it, and it can be undone', (
    tester,
  ) async {
    await pumpAt(tester, courseLocation());
    await tester.tap(find.text('Em and Am'));
    await tester.pumpAndSettle();

    // Scrolled to first: a lesson is taller than the screen once its banner, its
    // text, its fretboard and its exercises are all on it.
    await tap(tester, 'I have finished this');
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Technique - 15 min - Done'), findsOne);
    expect(find.byIcon(Icons.check_circle), findsOne);

    await tester.tap(find.text('Em and Am'));
    await tester.pumpAndSettle();
    await tap(tester, 'Clear my progress');
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Technique - 15 min - Done'), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsNothing);
  });

  screenTest('a course that is not there does not throw', (tester) async {
    // What a link kept from before a re-import that dropped the course lands on.
    await pump(
      tester,
      const CourseScreen(
        courseId: -1,
        path: LearningPath.rhythm,
        level: SkillLevel.beginner,
      ),
    );

    expect(find.widgetWithText(AppBar, 'Course'), findsOne);
    expect(find.text('Nothing in this course'), findsOne);
  });

  screenTest('and neither does a lesson that is not there', (tester) async {
    // A bookmark or a link that outlived the lesson it points at. Nothing is
    // recorded as started, because there is nothing to record it against.
    await pump(tester, const LessonScreen(lessonId: -1));

    expect(find.widgetWithText(AppBar, 'Lesson'), findsOne);
    expect(find.text('This lesson is not here'), findsOne);
  });
}
