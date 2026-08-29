import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/theme/app_theme.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/database_provider.dart';
import 'package:tone_vault/core/enums/learning_path.dart';
import 'package:tone_vault/core/enums/skill_level.dart';
import 'package:tone_vault/features/academy/providers/academy_providers.dart';
import 'package:tone_vault/features/academy/screens/course_screen.dart';
import 'package:tone_vault/features/academy/screens/level_screen.dart';
import '../support/curriculum_document_fixture.dart';
import '../support/repositories.dart';
import '../support/screen_harness.dart';

/// A course as the player meets it: the lessons in it, opened, read and ticked
/// off.
void main() {
  late AppDatabase database;
  late int courseId;

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

    courseId = (await curriculumRepository(
      database,
    ).watchCourses(LearningPath.rhythm, SkillLevel.beginner).first).single.id;
  });

  tearDown(() => database.close());

  /// The seed is stood in with a value, because these tests put the curriculum in
  /// themselves and the shipped one would arrive on top of it.
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

  /// Taps a button that may be below the fold, which most of them are on a course
  /// screen with a lesson open.
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

  screenTest('a course shows its modules and the lessons in them', (
    tester,
  ) async {
    await pump(tester, CourseScreen(courseId: courseId));

    expect(find.widgetWithText(AppBar, 'First Chords'), findsOne);
    expect(find.text('Open Chords'), findsOne);
    expect(find.text('Em and Am'), findsOne);
    expect(find.text('C and G'), findsOne);

    // Closed, so the text of the lesson is not on screen yet.
    expect(find.textContaining('Two fingers'), findsNothing);
  });

  screenTest('a lesson says what it asks of the player and how long it takes', (
    tester,
  ) async {
    await pump(tester, CourseScreen(courseId: courseId));

    expect(find.text('Technique - 15 min'), findsExactly(2));
  });

  screenTest('opening a lesson shows its text and its exercises', (
    tester,
  ) async {
    await pump(tester, CourseScreen(courseId: courseId));

    await tester.tap(find.text('Em and Am'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Two fingers'), findsOne);
    // The list in the body is rendered as a list rather than as its markdown.
    expect(find.textContaining('• Second finger'), findsOne);
    expect(find.text('One chord a bar'), findsOne);
    expect(find.textContaining('60 to 100 BPM'), findsOne);
  });

  screenTest('and reads as a lesson rather than as a page of text', (
    tester,
  ) async {
    await pump(tester, CourseScreen(courseId: courseId));

    await tester.tap(find.text('Em and Am'));
    await tester.pumpAndSettle();

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
    await pump(tester, CourseScreen(courseId: courseId));

    await tester.tap(find.text('Em and Am'));
    await tester.pumpAndSettle();

    // Em and Am are what the lesson points at, and the neck is drawn from them.
    expect(find.text('On the neck'), findsOne);
    expect(find.widgetWithText(ChoiceChip, 'Em'), findsOne);
    expect(find.widgetWithText(ChoiceChip, 'Am'), findsOne);
  });

  screenTest('opening a lesson is what records that it was started', (
    tester,
  ) async {
    await pump(tester, CourseScreen(courseId: courseId));

    await tester.tap(find.text('Em and Am'));
    await tester.pumpAndSettle();

    // The one it was told about, and only that one.
    expect(find.text('Technique - 15 min - In progress'), findsOne);
    expect(find.text('Technique - 15 min'), findsOne);
  });

  screenTest('finishing a lesson ticks it, and it can be undone', (
    tester,
  ) async {
    await pump(tester, CourseScreen(courseId: courseId));
    await tester.tap(find.text('Em and Am'));
    await tester.pumpAndSettle();

    // Scrolled to first: an open lesson is taller than the screen once its text, its
    // fretboard and its exercises are all on it.
    await tap(tester, 'I have finished this');

    expect(find.text('Technique - 15 min - Done'), findsOne);
    expect(find.byIcon(Icons.check_circle), findsOne);

    await tap(tester, 'Clear my progress');

    expect(find.text('Technique - 15 min - Done'), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsNothing);
  });

  screenTest('a course that is not there does not throw', (tester) async {
    // What a link kept from before a re-import that dropped the course lands on.
    await pump(tester, const CourseScreen(courseId: -1));

    expect(find.widgetWithText(AppBar, 'Course'), findsOne);
    expect(find.text('Nothing in this course'), findsOne);
  });
}
