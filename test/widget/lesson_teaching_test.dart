import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tone_vault/app/router/routes.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/database_provider.dart';
import 'package:tone_vault/features/academy/screens/lesson_search_screen.dart';
import 'package:tone_vault/features/academy/widgets/lesson_next_skill.dart';
import 'package:tone_vault/features/academy/widgets/lesson_note_list.dart';
import 'package:tone_vault/features/academy/widgets/lesson_objective.dart';

/// What an instructor writes around a lesson, on the screen.
///
/// Each of the three is silent when the lesson says nothing: a course imported
/// from another phone may have been written before these existed, and a heading
/// with nothing under it would read as something missing rather than something
/// never said.
void main() {
  testWidgets('an objective is headed by what it is for', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LessonObjective(objective: 'Change between Em and Am.'),
        ),
      ),
    );

    expect(find.text('What this is for'), findsOne);
    expect(find.text('Change between Em and Am.'), findsOne);
  });

  testWidgets('and a lesson without one shows no heading at all', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LessonObjective(objective: null))),
    );

    expect(find.text('What this is for'), findsNothing);
  });

  testWidgets('notes are listed one to a line under their own heading', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LessonNoteList(
            title: 'Common mistakes',
            icon: Icons.error_outline,
            notes: ['Placing each finger separately.', 'Six strings on Am.'],
          ),
        ),
      ),
    );

    expect(find.text('Common mistakes'), findsOne);
    expect(find.text('• Placing each finger separately.'), findsOne);
    expect(find.text('• Six strings on Am.'), findsOne);
  });

  testWidgets('and nothing is written where there are no notes', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LessonNoteList(
            title: 'Practice tips',
            icon: Icons.lightbulb_outline,
            notes: [],
          ),
        ),
      ),
    );

    expect(find.text('Practice tips'), findsNothing);
  });

  group('the skill a lesson hands on to', () {
    late AppDatabase database;

    setUp(() => database = AppDatabase(NativeDatabase.memory()));
    tearDown(() => database.close());

    /// The widget on a screen of its own, with the Academy search a push away.
    ///
    /// A router rather than a plain [MaterialApp]: tapping the skill is a
    /// navigation, and where it lands is the half of this worth testing.
    Future<void> pump(WidgetTester tester, String? skill) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(database)],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) =>
                      Scaffold(body: LessonNextSkill(nextSkill: skill)),
                ),
                GoRoute(
                  path: Routes.academySearch,
                  builder: (context, state) => const LessonSearchScreen(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('is named at the bottom of it', (tester) async {
      await pump(tester, 'C and G');

      expect(find.text('Next: C and G'), findsOne);
    });

    testWidgets('and tapping it searches the Academy for those words', (
      tester,
    ) async {
      await pump(tester, 'Barre chords');

      await tester.tap(find.text('Next: Barre chords'));
      await tester.pumpAndSettle();

      // Searched rather than linked, so the field arrives with the skill already
      // typed into it and the player can widen the search from there.
      expect(find.widgetWithText(AppBar, 'Barre chords'), findsOne);
    });

    testWidgets('and a lesson that leads nowhere says nothing', (tester) async {
      await pump(tester, null);

      expect(find.textContaining('Next:'), findsNothing);
    });
  });
}
