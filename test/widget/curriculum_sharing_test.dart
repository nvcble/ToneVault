import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/theme/app_theme.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/database_provider.dart';
import 'package:tone_vault/core/enums/learning_path.dart';
import 'package:tone_vault/core/enums/skill_level.dart';
import 'package:tone_vault/features/academy/data/curriculum_document.dart';
import 'package:tone_vault/features/academy/screens/course_screen.dart';
import 'package:tone_vault/features/academy/screens/curriculum_screen.dart';
import '../support/curriculum_document_fixture.dart';
import '../support/fake_curriculum_files.dart';
import '../support/repositories.dart';
import '../support/screen_harness.dart';

/// Passing a curriculum on: the whole Academy, or one course out of it.
void main() {
  late AppDatabase database;
  late FakeCurriculumFiles files;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    files = FakeCurriculumFiles();
  });

  tearDown(() => database.close());

  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          ...curriculumFileOverrides(files),
        ],
        child: MaterialApp(theme: AppTheme.dark(), home: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The one course, or that course beside another on the other path.
  ///
  /// The second sits under Lead so the read below still finds one course under
  /// Rhythm; what it is there for is to be left behind by an export of one course.
  Future<int> seedCourses(
    WidgetTester tester, {
    bool andAnother = false,
  }) async {
    await tester.runAsync(
      () => curriculumImporter(database).importFile(
        curriculumJson(
          courses: [
            courseMap(),
            if (andAnother)
              courseMap(
                slug: 'lead-beginner-first-notes',
                path: 'lead',
                title: 'First Notes',
              ),
          ],
        ),
      ),
    );

    final courses = await tester.runAsync(
      () => curriculumRepository(
        database,
      ).watchCourses(LearningPath.rhythm, SkillLevel.beginner).first,
    );
    return courses!.single.id;
  }

  screenTest('the whole curriculum goes out as one named file', (tester) async {
    await seedCourses(tester);
    await pump(tester, const CurriculumScreen());

    await tester.tap(find.text('Export the curriculum'));
    await tester.pumpAndSettle();

    expect(files.sent, hasLength(1));
    expect(files.last!.fileName, startsWith('tonevault-curriculum-'));
    // Readable as a curriculum on the way out, not merely written: what leaves has
    // to be what another copy of the app can take back in.
    expect(decodeCurriculum(files.last!.contents).single.title, 'First Chords');
  });

  screenTest('and with the teaching that came in with it', (tester) async {
    await seedCourses(tester);
    await pump(tester, const CurriculumScreen());

    await tester.tap(find.text('Export the curriculum'));
    await tester.pumpAndSettle();

    // Through the tables and out again. The objective, the warnings and the tips
    // are stored as columns of their own, so a lesson that arrived complete and
    // left as bare prose would be a silent loss nobody would notice until the
    // course was opened on the other phone.
    final lesson = decodeCurriculum(
      files.last!.contents,
    ).single.modules.single.lessons.single;
    expect(lesson.objective, 'Change between Em and Am without stopping.');
    expect(lesson.commonMistakes, ['Placing each finger separately.']);
    expect(lesson.practiceTips, ['Move the pair as one block.']);
    expect(lesson.nextSkill, 'C and G');
  });

  screenTest(
    'an Academy with nothing in it says so rather than sending an empty file',
    (tester) async {
      await pump(tester, const CurriculumScreen());

      await tester.tap(find.text('Export the curriculum'));
      await tester.pumpAndSettle();

      expect(files.sent, isEmpty);
      expect(find.textContaining('no curriculum here'), findsOne);
    },
  );

  screenTest('the screen says plainly that progress is not in the file', (
    tester,
  ) async {
    await pump(tester, const CurriculumScreen());

    // The one question a player asks before sending a course to somebody, answered
    // where they are about to send it rather than in a release note.
    expect(find.textContaining('Your progress is yours'), findsOne);
  });

  screenTest('one course can be sent from the course itself', (tester) async {
    final courseId = await seedCourses(tester, andAnother: true);
    await pump(tester, CourseScreen(courseId: courseId));

    await tester.tap(find.byTooltip('Send this course on'));
    await tester.pumpAndSettle();

    // Only the one course, and the file named after it.
    final sent = decodeCurriculum(files.last!.contents);
    expect(sent.single.slug, 'rhythm-beginner-first-chords');
    expect(files.last!.fileName, contains('rhythm-beginner-first-chords'));
  });

  screenTest('and a course that is no longer there offers nothing to send', (
    tester,
  ) async {
    await pump(tester, const CourseScreen(courseId: -1));

    // A link kept from before an import that dropped the course. There is nothing
    // to export, so there is no button offering to.
    expect(find.byTooltip('Send this course on'), findsNothing);
  });
}
