import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/theme/app_theme.dart';
import 'package:tone_vault/core/music/pitch_class.dart';
import 'package:tone_vault/core/music/scale.dart';
import 'package:tone_vault/core/music/scale_type.dart';
import 'package:tone_vault/features/theory/providers/theory_providers.dart';
import 'package:tone_vault/features/theory/widgets/scale_explorer.dart';

/// The scales tab: a scale on the key's root, on the neck, and explained.
///
/// The explaining is below the neck, so a test has to scroll to it the way a player would
/// - the shape comes first, and what the shape is for comes after it.
void main() {
  Future<void> pump(WidgetTester tester, {String root = 'C'}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          theoryKeyProvider.overrideWith(
            (ref) => Scale(PitchClass.parse(root), ScaleType.major),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(body: ScaleExplorer()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> choose(WidgetTester tester, String scale) async {
    await tester.tap(find.widgetWithText(ChoiceChip, scale));
    await tester.pumpAndSettle();
  }

  /// Brings the card below the fretboard into view. A `ListView` does not build what is
  /// off-screen, so without this the facts are not there to be found.
  Future<void> readOn(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 200);
    await tester.pumpAndSettle();
  }

  testWidgets('a mode says the scale it is a rotation of', (tester) async {
    await pump(tester);
    await choose(tester, 'Dorian');
    await readOn(tester, find.text('Parent scale'));

    // C Dorian is Bb major started on its second degree, and the sixth is the note that
    // makes it Dorian rather than the minor scale it otherwise is.
    expect(find.text('1 2 b3 4 5 6 b7'), findsOne);
    expect(find.text('Bb major'), findsOne);
    expect(find.text('natural 6'), findsOne);
  });

  testWidgets('and what it can be played over, and what it is for', (
    tester,
  ) async {
    await pump(tester);
    await choose(tester, 'Dorian');
    await readOn(tester, find.text('Fits over'));

    expect(find.textContaining('Cm7'), findsOne);
    expect(find.textContaining('Minor with a bright sixth'), findsOne);
  });

  testWidgets('a pentatonic comes from a scale rather than being one', (
    tester,
  ) async {
    await pump(tester);
    await choose(tester, 'minor pentatonic');
    await readOn(tester, find.text('Comes from'));

    expect(find.text('1 b3 4 5 b7'), findsOne);
    expect(find.text('C minor'), findsOne);
    expect(find.text('Parent scale'), findsNothing);
    // Five notes with no second among them, so there is no ninth to build a m11 on.
    expect(find.textContaining('Cm11'), findsNothing);
  });

  testWidgets('the intervals are the formula said in words', (tester) async {
    await pump(tester);
    await readOn(tester, find.text('Intervals'));

    expect(
      find.textContaining('root · major 2nd · major 3rd · perfect 4th'),
      findsOne,
    );
  });

  testWidgets('a scale with nothing to lean on leans on nothing', (
    tester,
  ) async {
    await pump(tester);
    await readOn(tester, find.text('Formula'));

    expect(find.text('1 2 3 4 5 6 7'), findsOne);
    expect(find.text('Leans on'), findsNothing);
    expect(find.text('Parent scale'), findsNothing);
    expect(find.text('Comes from'), findsNothing);
  });

  testWidgets('the chromatic scale offers no chords, because it fits all', (
    tester,
  ) async {
    await pump(tester);
    await choose(tester, 'chromatic');
    await readOn(tester, find.text('Formula'));

    expect(find.text('Fits over'), findsNothing);
    expect(find.textContaining('notes between the notes'), findsOne);
  });

  testWidgets('and the facts follow the key', (tester) async {
    await pump(tester, root: 'A');
    await choose(tester, 'minor pentatonic');
    await readOn(tester, find.text('Fits over'));

    expect(find.text('A minor'), findsOne);
    expect(find.textContaining('Am7'), findsOne);
  });
}
