import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/theme/app_theme.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/database_provider.dart';
import 'package:tone_vault/core/enums/learning_path.dart';
import 'package:tone_vault/core/enums/progress_state.dart';
import 'package:tone_vault/core/enums/skill_level.dart';
import 'package:tone_vault/features/academy/screens/practice_metronome_screen.dart';
import 'package:tone_vault/features/metronome/providers/metronome_providers.dart';
import '../support/curriculum_document_fixture.dart';
import '../support/recording_metronome.dart';
import '../support/repositories.dart';
import '../support/screen_harness.dart';

/// Practice counted on the metronome, credited to the lesson it was opened from.
///
/// The whole way through: a real curriculum in a real in-memory database, the
/// metronome pushed as a route so leaving it is a back button rather than a method
/// call, and a clock handed in so the practice does not have to be sat through.
void main() {
  late AppDatabase database;
  late MetronomeController controller;
  late int lessonId;
  var now = DateTime.utc(2026, 8, 20, 10);

  /// The lesson the next push credits its practice to, read when the route is built.
  ///
  /// A variable rather than an argument to the pump, so a test can open the metronome
  /// twice over one metronome: pumping a second tree would dispose the controller
  /// along with the scope holding it, and the count with it.
  int? openFor;

  setUp(() async {
    now = DateTime.utc(2026, 8, 20, 10);
    openFor = null;
    database = AppDatabase(NativeDatabase.memory());
    controller = MetronomeController(RecordingMetronome(), clock: () => now);

    await curriculumImporter(database).importFile(curriculumJson());
    final curriculum = curriculumRepository(database);
    final courseId =
        (await curriculum
                .watchCourses(LearningPath.rhythm, SkillLevel.beginner)
                .first)
            .single
            .id;
    final moduleId = (await curriculum.watchModules(courseId).first).single.id;
    lessonId = (await curriculum.watchLessons(moduleId).first).single.id;
  });

  tearDown(() => database.close());

  /// A screen with the metronome one push away, the way an exercise offers it.
  Future<void> pumpVault(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          metronomeSettingsProvider.overrideWith((ref) => controller),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          PracticeMetronomeScreen(lessonId: openFor),
                    ),
                  ),
                  child: const Text('Practise'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openMetronome(WidgetTester tester, {int? forLesson}) async {
    openFor = forLesson;
    await tester.tap(find.text('Practise'));
    await tester.pumpAndSettle();
  }

  Future<void> leaveMetronome(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    // The credit is not awaited by the screen, which is already leaving.
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  Future<void> practise(WidgetTester tester, Duration length) async {
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    now = now.add(length);
  }

  /// The lesson's progress, read outside the test's own sense of time.
  ///
  /// Through `runAsync`, because a widget test runs on a fake clock and a drift
  /// stream waits on a real timer to deliver its first row: awaited directly, the
  /// read never arrives and the test sits there until it is killed.
  Future<AcademyProgressRow?> readProgress(WidgetTester tester) {
    return tester.runAsync<AcademyProgressRow?>(
      () => progressRepository(database).watchProgress(lessonId).first,
    );
  }

  Future<int> practisedSeconds(WidgetTester tester) async =>
      (await readProgress(tester))?.practiceSeconds ?? 0;

  screenTest('leaving the metronome credits the practice to the lesson', (
    tester,
  ) async {
    await pumpVault(tester);
    await openMetronome(tester, forLesson: lessonId);
    await practise(tester, const Duration(minutes: 4));
    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();

    await leaveMetronome(tester);

    expect(await practisedSeconds(tester), 240);
  });

  screenTest('and the lesson counts as under way once it has been practised', (
    tester,
  ) async {
    await pumpVault(tester);
    await openMetronome(tester, forLesson: lessonId);
    await practise(tester, const Duration(minutes: 4));
    await leaveMetronome(tester);

    final row = await readProgress(tester);

    // Practised is not finished. Only the player says finished.
    expect(row!.state, ProgressState.inProgress);
  });

  screenTest('a metronome left running is credited with what it counted so far', (
    tester,
  ) async {
    await pumpVault(tester);
    await openMetronome(tester, forLesson: lessonId);
    await practise(tester, const Duration(minutes: 2));

    // Left clicking. Going back to read the lesson is the ordinary way to use it,
    // so waiting for the transport before crediting anything would credit nothing.
    await leaveMetronome(tester);

    expect(await practisedSeconds(tester), 120);
    expect(controller.state.playing, isTrue);
  });

  screenTest('coming back to practise more adds to what was there', (
    tester,
  ) async {
    await pumpVault(tester);
    await openMetronome(tester, forLesson: lessonId);
    await practise(tester, const Duration(minutes: 2));
    await leaveMetronome(tester);

    await openMetronome(tester, forLesson: lessonId);
    now = now.add(const Duration(seconds: 30));
    await leaveMetronome(tester);

    // Two and a half minutes: the second visit picked the count up where the first
    // one left it rather than starting again or counting it twice.
    expect(await practisedSeconds(tester), 150);
  });

  screenTest('a visit with no practice in it writes nothing at all', (
    tester,
  ) async {
    await pumpVault(tester);
    await openMetronome(tester, forLesson: lessonId);
    now = now.add(const Duration(minutes: 10));

    await leaveMetronome(tester);

    // Not a row saying nought seconds: a lesson the player looked at the metronome
    // from has not been started, and a row would say it had.
    expect(await readProgress(tester), isNull);
  });

  screenTest('the metronome opened as itself credits nobody', (tester) async {
    await pumpVault(tester);
    await openMetronome(tester);
    await practise(tester, const Duration(minutes: 5));
    await leaveMetronome(tester);

    expect(await practisedSeconds(tester), 0);
  });

  screenTest('but takes the count, so the next lesson does not inherit it', (
    tester,
  ) async {
    await pumpVault(tester);
    await openMetronome(tester);
    await practise(tester, const Duration(minutes: 5));
    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();
    await leaveMetronome(tester);

    // Now the same metronome, opened from a lesson, and left straight away.
    await openMetronome(tester, forLesson: lessonId);
    await leaveMetronome(tester);

    expect(await practisedSeconds(tester), 0);
  });
}
