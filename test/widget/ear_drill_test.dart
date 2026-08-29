import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/theme/app_theme.dart';
import 'package:tone_vault/core/audio/tone_player_provider.dart';
import 'package:tone_vault/core/enums/skill_level.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/academy/data/ear_drill.dart';
import 'package:tone_vault/features/academy/data/ear_question.dart';
import 'package:tone_vault/features/academy/data/ear_questions.dart';
import 'package:tone_vault/features/academy/providers/ear_training_providers.dart';
import 'package:tone_vault/features/academy/screens/ear_drill_screen.dart';
import 'package:tone_vault/features/academy/screens/ear_training_screen.dart';
import '../support/recording_tone_player.dart';

/// A drill as the player works through it: something is played, they name it, and they
/// are told what it was.
///
/// The randomness is seeded and the speaker is a recorder, so the test knows which
/// chord is about to be played and can check that it was the one on screen.
void main() {
  const seed = 1;
  late RecordingTonePlayer player;

  setUp(() => player = RecordingTonePlayer());

  /// The question the screen will open on, worked out the same way it works it out.
  EarQuestion opening(EarDrill drill) => questionFor(drill, Random(seed));

  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tonePlayerProvider.overrideWithValue(player),
          earRandomProvider.overrideWithValue(Random(seed)),
        ],
        child: MaterialApp(theme: AppTheme.dark(), home: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('the drills are listed under the level they belong to', (
    tester,
  ) async {
    await pump(tester, const EarTrainingScreen());

    /// Scrolled to, because the drills under four headings are taller than a phone and
    /// only what is on screen is built. Settled afterwards as well: scrolling on its own
    /// leaves the list built the way it was where it started, so the next heading down
    /// would be looked for among rows that have not been laid out yet.
    Future<void> reveal(String label, {required String missing}) async {
      await tester.scrollUntilVisible(find.text(label), 200);
      await tester.pumpAndSettle();
      expect(find.text(label), findsOne, reason: missing);
    }

    for (final level in SkillLevel.values) {
      await reveal(level.label, missing: '${level.name} is missing');

      for (final drill in EarDrill.forLevel(level)) {
        await reveal(drill.label, missing: '${drill.name} is not offered');
      }
    }
  });

  testWidgets('opening a drill plays the question without being asked', (
    tester,
  ) async {
    final question = opening(EarDrill.openChords);
    await pump(tester, const EarDrillScreen(drill: EarDrill.openChords));

    expect(find.text('Which open chord did you hear?'), findsOne);
    // The chord that was played is the chord the question was made from.
    expect(player.played, question.sound.bars);
  });

  testWidgets('and it can be heard again as often as the player likes', (
    tester,
  ) async {
    await pump(tester, const EarDrillScreen(drill: EarDrill.openChords));

    await tap(tester, 'Play it again');
    await tap(tester, 'Play it again');

    expect(player.played, hasLength(3));
  });

  testWidgets('a right answer is marked, scored and explained anyway', (
    tester,
  ) async {
    final question = opening(EarDrill.majorOrMinor);
    await pump(tester, const EarDrillScreen(drill: EarDrill.majorOrMinor));

    expect(find.text('0 of 0'), findsOne);

    await tap(tester, question.answerLabel);

    expect(find.text('That is it'), findsOne);
    expect(find.text('1 of 1'), findsOne);
    // Explained even when it was right, so a lucky tap still teaches the spelling.
    expect(find.text(question.explanation), findsOne);
  });

  testWidgets('a wrong answer says what it was instead', (tester) async {
    final question = opening(EarDrill.majorOrMinor);
    await pump(tester, const EarDrillScreen(drill: EarDrill.majorOrMinor));

    final wrong = question.choices.firstWhere(
      (choice) => choice != question.answerLabel,
    );
    await tap(tester, wrong);

    expect(find.text('Not this time'), findsOne);
    expect(find.text('0 of 1'), findsOne);
    expect(find.text(question.explanation), findsOne);
  });

  testWidgets('a marked question cannot be answered a second time', (
    tester,
  ) async {
    final question = opening(EarDrill.majorOrMinor);
    await pump(tester, const EarDrillScreen(drill: EarDrill.majorOrMinor));

    final wrong = question.choices.firstWhere(
      (choice) => choice != question.answerLabel,
    );
    await tap(tester, wrong);
    await tap(tester, question.answerLabel);

    // Still wrong, and still one question: tapping the answer afterwards is not
    // getting it right.
    expect(find.text('Not this time'), findsOne);
    expect(find.text('0 of 1'), findsOne);
  });

  testWidgets('the next question is another one, and it plays itself', (
    tester,
  ) async {
    final question = opening(EarDrill.majorOrMinor);
    await pump(tester, const EarDrillScreen(drill: EarDrill.majorOrMinor));
    await tap(tester, question.answerLabel);

    await tap(tester, 'Next question');

    expect(find.text('Next question'), findsNothing);
    expect(find.text('1 of 1'), findsOne);
    expect(player.played, hasLength(2));
  });

  testWidgets('a device that cannot play says so and shows the question', (
    tester,
  ) async {
    player.failure = const AppFailure('No sound on this device.');
    await pump(tester, const EarDrillScreen(drill: EarDrill.majorOrMinor));

    expect(find.text('No sound on this device.'), findsOne);
    // The question is still answerable from the explanation afterwards.
    expect(find.text('Major or minor?'), findsOne);
  });

  testWidgets('leaving the drill silences it', (tester) async {
    await pump(tester, const EarDrillScreen(drill: EarDrill.majorOrMinor));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    expect(player.stops, 1);
  });
}
