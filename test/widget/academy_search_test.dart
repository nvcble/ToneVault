import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/app.dart';
import 'package:tone_vault/core/audio/metronome_provider.dart';
import 'package:tone_vault/core/audio/tone_player_provider.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/database_provider.dart';
import 'package:tone_vault/features/theory/widgets/circle_of_fifths_wheel.dart';
import '../support/academy_streams.dart';
import '../support/curriculum_fixture.dart';
import '../support/home_streams.dart';
import '../support/recording_metronome.dart';
import '../support/recording_tone_player.dart';
import '../support/screen_harness.dart';

/// One field, two halves of an answer: the curriculum and the theory.
///
/// The whole app is pumped, because half of what a search offers is somewhere to go and
/// a route is the thing being tested. The database is a real one held in memory - the
/// lessons are searched by querying them, and the theory is not stored at all.
void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          ...homeStreamOverrides(),
          ...academyStreamOverrides(),
          tonePlayerProvider.overrideWithValue(RecordingTonePlayer()),
          metronomeProvider.overrideWithValue(RecordingMetronome()),
        ],
        child: const ToneVaultApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> search(WidgetTester tester, String query) async {
    await tester.tap(find.byTooltip('Guitar Academy'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Search the Academy'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), query);
    await tester.pumpAndSettle();
  }

  screenTest(
    'a word is answered with the theory first and the lessons under it',
    (tester) async {
      await seedCourse(database);
      await pumpApp(tester);

      await search(tester, 'chords');

      expect(find.text('Chord families'), findsOne);
      expect(find.text('Lessons'), findsOne);
      expect(find.text('Lesson 1'), findsOne);
      // The theory above the lessons, because it is the exact answer and they are the
      // reading around it.
      expect(
        tester.getTopLeft(find.text('Chord families')).dy,
        lessThan(tester.getTopLeft(find.text('Lesson 1')).dy),
      );
    },
  );

  screenTest('a scale typed in is found as a scale', (tester) async {
    await pumpApp(tester);

    // The spec's own example, and the reason the two halves share a field: nothing in
    // the curriculum has to mention a scale for the app to be able to show it.
    await search(tester, 'minor pentatonic');

    expect(find.text('C minor pentatonic'), findsOne);
    expect(find.text('Scale'), findsOne);
  });

  screenTest('and a chord opens on the neck rather than as a screen', (
    tester,
  ) async {
    await pumpApp(tester);
    await search(tester, 'm7b5');

    // Built on the key the browser is in, which is what the tab it came from would show.
    await tester.tap(find.text('Cm7b5'));
    await tester.pumpAndSettle();

    expect(find.text('On the neck'), findsOne);
  });

  screenTest('a topic goes to the tab that teaches it', (tester) async {
    await pumpApp(tester);
    await search(tester, 'key signatures');

    await tester.tap(find.text('Circle of fifths'));
    await tester.pumpAndSettle();

    expect(find.byType(CircleOfFifthsWheel), findsOne);
  });

  screenTest('a letter is asked about rather than answered', (tester) async {
    await pumpApp(tester);
    await search(tester, 'c');

    // `c` is a key, a chord and a note, and answering it would be answering nothing.
    expect(find.text('What are you looking for?'), findsOne);
  });

  screenTest('and a word nothing is called says so once', (tester) async {
    await seedCourse(database);
    await pumpApp(tester);
    await search(tester, 'zzzz');

    // One empty state for both halves: neither the lessons nor the theory has it.
    expect(find.text('Nothing matches'), findsOne);
    expect(find.textContaining('lessons or the theory'), findsOne);
  });
}
