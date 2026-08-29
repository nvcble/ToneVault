import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/theme/app_theme.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/database_provider.dart';
import 'package:tone_vault/core/enums/learning_path.dart';
import 'package:tone_vault/core/enums/skill_level.dart';
import 'package:tone_vault/features/academy/screens/curriculum_screen.dart';
import '../support/curriculum_document_fixture.dart';
import '../support/fake_curriculum_files.dart';
import '../support/repositories.dart';
import '../support/screen_harness.dart';

/// Taking a curriculum in from a file: read, described, asked about, then written.
///
/// The order is what these tests are about. A file that turns out to be a photo, or
/// one from a newer app, has to be refused before anything is written; and a course
/// this app already has must be named in the question rather than quietly rewritten
/// underneath whoever has been practising it.
void main() {
  late AppDatabase database;
  late FakeCurriculumFiles files;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    files = FakeCurriculumFiles();
  });

  tearDown(() => database.close());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          ...curriculumFileOverrides(files),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const CurriculumScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Reads of the Academy, taken outside the test's own sense of time.
  ///
  /// Through `runAsync`, because a widget test runs on a fake clock and a drift
  /// stream waits on a real timer to deliver its first row: awaited directly, the
  /// read never arrives.
  Future<List<AcademyCourse>> storedCourses(WidgetTester tester) async {
    final courses = await tester.runAsync<List<AcademyCourse>>(
      () => curriculumRepository(
        database,
      ).watchCourses(LearningPath.rhythm, SkillLevel.beginner).first,
    );
    return courses ?? const [];
  }

  /// The one lesson of the one course, as it now stands.
  Future<AcademyLesson> storedLesson(WidgetTester tester) async {
    final lesson = await tester.runAsync<AcademyLesson>(() async {
      final curriculum = curriculumRepository(database);
      final course =
          (await curriculum
                  .watchCourses(LearningPath.rhythm, SkillLevel.beginner)
                  .first)
              .single;
      final module = (await curriculum.watchModules(course.id).first).single;
      return (await curriculum.watchLessons(module.id).first).single;
    });
    return lesson!;
  }

  Future<void> seedStored(WidgetTester tester) async {
    await tester.runAsync(
      () => curriculumImporter(database).importFile(curriculumJson()),
    );
  }

  Future<void> tapImport(WidgetTester tester) async {
    await tester.tap(find.text('Import a curriculum'));
    await tester.pumpAndSettle();
  }

  screenTest('a file is described before any of it is written', (tester) async {
    files.offers = curriculumJson();
    await pump(tester);

    await tapImport(tester);

    // The question first, and the Academy still empty behind it: the user is
    // answering about this file, and backing out here costs them nothing.
    expect(find.text('Import this?'), findsOne);
    expect(find.textContaining('1 course and 1 lesson'), findsOne);
    expect(await storedCourses(tester), isEmpty);
  });

  screenTest('and written once it has been agreed to', (tester) async {
    files.offers = curriculumJson();
    await pump(tester);
    await tapImport(tester);

    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();

    expect((await storedCourses(tester)).single.title, 'First Chords');
    expect(find.textContaining('1 course added'), findsOne);
  });

  screenTest('backing out of the picker changes nothing and says nothing', (
    tester,
  ) async {
    files.offers = null;
    await pump(tester);

    await tapImport(tester);

    // Not a failure. Somebody who opened the picker and thought better of it is not
    // to be told off about it.
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    expect(await storedCourses(tester), isEmpty);
  });

  screenTest('and so does backing out of the question', (tester) async {
    files.offers = curriculumJson();
    await pump(tester);
    await tapImport(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(await storedCourses(tester), isEmpty);
  });

  screenTest('a file that is not a curriculum is refused, unasked about', (
    tester,
  ) async {
    files.offers = '{"holiday": "photo"}';
    await pump(tester);

    await tapImport(tester);

    // Refused at the reading, before there is anything to agree to: there is no
    // sense asking whether to import a file that cannot be imported.
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.textContaining('not a ToneVault curriculum'), findsOne);
    expect(await storedCourses(tester), isEmpty);
  });

  screenTest('and so is one written by a newer version of the app', (
    tester,
  ) async {
    files.offers = curriculumJson(formatVersion: 99);
    await pump(tester);

    await tapImport(tester);

    // Told to update rather than shown a half-understood course. The file may hold
    // fields this app does not know to write.
    expect(find.textContaining('newer version of ToneVault'), findsOne);
    expect(await storedCourses(tester), isEmpty);
  });

  screenTest('a course already here is named in the question', (tester) async {
    await seedStored(tester);
    files.offers = curriculumJson();
    await pump(tester);

    await tapImport(tester);

    expect(find.text('Some of this is already here'), findsOne);
    expect(find.textContaining('"First Chords"'), findsOne);
    // Both answers offered, because both are reasonable and neither is safe to
    // assume on the user's behalf.
    expect(find.text('Keep mine'), findsOne);
    expect(find.text('Bring up to date'), findsOne);
  });

  screenTest('keeping mine leaves the lesson saying what it said', (
    tester,
  ) async {
    await seedStored(tester);
    files.offers = curriculumJson(
      courses: [
        courseMap(
          modules: [
            moduleMap(lessons: [lessonMap(body: 'Rewritten.')]),
          ],
        ),
      ],
    );
    await pump(tester);
    await tapImport(tester);

    await tester.tap(find.text('Keep mine'));
    await tester.pumpAndSettle();

    expect(
      (await storedLesson(tester)).body,
      'Two fingers, moved across one string.',
    );
    expect(find.textContaining('left as it was'), findsOne);
  });

  screenTest('and bringing it up to date rewrites it but keeps the practice', (
    tester,
  ) async {
    await seedStored(tester);
    final before = await storedLesson(tester);
    await tester.runAsync(
      () => progressRepository(database).addPracticeSeconds(before.id, 600),
    );
    files.offers = curriculumJson(
      courses: [
        courseMap(
          modules: [
            moduleMap(lessons: [lessonMap(body: 'Rewritten.')]),
          ],
        ),
      ],
    );
    await pump(tester);
    await tapImport(tester);

    await tester.tap(find.text('Bring up to date'));
    await tester.pumpAndSettle();

    final after = await storedLesson(tester);
    expect(after.body, 'Rewritten.');
    // The same lesson, corrected - not a new one. The hours already put into it hang
    // off this id, and a lesson replaced rather than updated would take them.
    expect(after.id, before.id);
    expect(
      (await tester.runAsync(
        () => progressRepository(database).watchProgress(after.id).first,
      ))?.practiceSeconds,
      600,
    );
    expect(find.textContaining('brought up to date'), findsOne);
  });
}
