import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/app.dart';
import 'package:tone_vault/core/audio/metronome_provider.dart';
import 'package:tone_vault/core/audio/tone_player_provider.dart';
import 'package:tone_vault/features/theory/widgets/circle_of_fifths_wheel.dart';
import '../support/academy_streams.dart';
import '../support/app_tabs.dart';
import '../support/home_streams.dart';
import '../support/recording_metronome.dart';
import '../support/recording_tone_player.dart';

/// The way into the Academy and back out of it.
///
/// The streams that read the database are stood in with plain values: they would
/// otherwise open the file on disk, which never resolves under the test binding
/// and has nothing to do with navigation.
void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...homeStreamOverrides(),
          ...academyStreamOverrides(),
          // Nothing here listens to anything, and the real one would go looking for
          // a temporary directory the test binding has no plugin for.
          tonePlayerProvider.overrideWithValue(RecordingTonePlayer()),
          metronomeProvider.overrideWithValue(RecordingMetronome()),
        ],
        child: const ToneVaultApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openAcademy(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Guitar Academy'));
    await tester.pumpAndSettle();
  }

  testWidgets('the header opens the Academy from every tab', (tester) async {
    await pumpApp(tester);

    for (final tab in const ['Home', 'Pedals', 'History', 'Settings']) {
      await openTab(tester, tab);

      expect(
        find.byTooltip('Guitar Academy'),
        findsOne,
        reason: 'the $tab tab has no way into the Academy',
      );
    }
  });

  testWidgets('and the back arrow returns to the tab it was opened from', (
    tester,
  ) async {
    await pumpApp(tester);
    await openTab(tester, 'History');

    await openAcademy(tester);

    // Over the tabs rather than beside them: the Academy is somewhere to go and
    // come back from, so the bar it covers is the bar it returns to.
    expect(find.text('Guitar Academy'), findsOne);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Nothing logged yet'), findsOne);
  });

  testWidgets('the two paths are separate, and each has four levels', (
    tester,
  ) async {
    await pumpApp(tester);
    await openAcademy(tester);

    expect(find.text('Rhythm Guitar'), findsOne);
    expect(find.text('Lead Guitar'), findsOne);

    await tester.tap(find.text('Lead Guitar'));
    await tester.pumpAndSettle();

    for (final level in const [
      'Beginner',
      'Intermediate',
      'Advanced',
      'Professional',
    ]) {
      expect(find.text(level), findsOne, reason: '$level is missing');
    }
  });

  testWidgets('a level says which path it belongs to', (tester) async {
    await pumpApp(tester);
    await openAcademy(tester);

    await tester.tap(find.text('Rhythm Guitar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Advanced'));
    await tester.pumpAndSettle();

    // "Advanced" on its own would not say which of the two paths it is advanced
    // in, and the two are meant never to be confused for each other.
    expect(find.widgetWithText(AppBar, 'Advanced Rhythm'), findsOne);
  });

  testWidgets('ear training is reached from the Academy, not from a path', (
    tester,
  ) async {
    await pumpApp(tester);
    await openAcademy(tester);

    await tester.tap(find.text('Ear training'));
    await tester.pumpAndSettle();

    // A drill belongs to a level, not to rhythm or lead, so `/academy/ear` has to
    // be read as itself rather than as the name of a path.
    expect(find.widgetWithText(AppBar, 'Ear training'), findsOne);
    expect(find.text('Rhythm Guitar'), findsNothing);

    await tester.tap(find.text('Major or minor'));
    await tester.pumpAndSettle();

    expect(find.text('Major or minor?'), findsOne);
    expect(find.text('Play it again'), findsOne);
  });

  testWidgets('so is the theory browser, which no path owns either', (
    tester,
  ) async {
    await pumpApp(tester);
    await openAcademy(tester);

    // Named topics rather than a tile called Theory: the shortcut says what it opens,
    // and it is the shortcut that names the tab.
    await tester.tap(find.text('Chord families'));
    await tester.pumpAndSettle();

    // `/academy/theory` has to be read as itself too, for the same reason as `ear`.
    expect(find.widgetWithText(AppBar, 'Theory'), findsOne);
    expect(find.text('The chords of C major'), findsOne);
  });

  testWidgets('and a shortcut lands on the tab that answers it', (
    tester,
  ) async {
    await pumpApp(tester);
    await openAcademy(tester);

    await tester.tap(find.text('Circle of fifths'));
    await tester.pumpAndSettle();

    // The tab is named in the route rather than counted, so the wheel is what opens
    // even though it is the last tab of seven.
    expect(find.byType(CircleOfFifthsWheel), findsOne);
    expect(find.text('The chords of C major'), findsNothing);
  });

  testWidgets('and so is the metronome, which is a tool rather than a lesson', (
    tester,
  ) async {
    await pumpApp(tester);
    await openAcademy(tester);

    await tester.tap(find.text('Metronome'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Metronome'), findsOne);
    expect(find.text('Tap tempo'), findsOne);
  });

  testWidgets('the Rigs tab it replaced is nowhere to be found', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Rigs'), findsNothing);
    expect(find.textContaining('rig', findRichText: true), findsNothing);
  });
}
