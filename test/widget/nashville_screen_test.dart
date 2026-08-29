import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/theme/app_theme.dart';
import 'package:tone_vault/core/music/pitch_class.dart';
import 'package:tone_vault/core/music/scale.dart';
import 'package:tone_vault/core/music/scale_type.dart';
import 'package:tone_vault/features/theory/providers/theory_providers.dart';
import 'package:tone_vault/features/theory/screens/nashville_screen.dart';

/// The number system: explained, then usable in the key the browser is set to.
///
/// Nothing is stubbed. The reading goes through the same engine the progressions tab
/// uses, so what a test sets up is the key and what a player types.
void main() {
  /// The explaining comes first and fills a phone, so the translator is below the fold
  /// and has to be scrolled to - as a player would have to read their way down to it.
  Future<void> reveal(WidgetTester tester) async {
    await tester.scrollUntilVisible(find.byType(TextField), 200);
    await tester.pumpAndSettle();
  }

  Future<void> pump(
    WidgetTester tester, {
    String root = 'C',
    bool toTranslator = true,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          theoryKeyProvider.overrideWith(
            (ref) => Scale(PitchClass.parse(root), ScaleType.major),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const NashvilleScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (toTranslator) {
      await reveal(tester);
    }
  }

  Future<void> type(WidgetTester tester, String line) async {
    await tester.enterText(find.byType(TextField), line);
    await tester.pumpAndSettle();
  }

  testWidgets('explains the system and translates an example straight away', (
    tester,
  ) async {
    await pump(tester, toTranslator: false);

    expect(find.text('A chord called by where it sits'), findsOne);

    await reveal(tester);

    // The field starts on the example, so the screen answers its own question before
    // anything is typed.
    expect(find.text('C   G   Am   F'), findsOne);
    expect(find.textContaining('Read in C major'), findsOne);
  });

  testWidgets('a typed line is read as the chords of the key', (tester) async {
    await pump(tester);

    await type(tester, '2m7 57 1maj7');

    expect(find.text('Dm7   G7   Cmaj7'), findsOne);
  });

  testWidgets('and the same numbers in another key are other chords', (
    tester,
  ) async {
    await pump(tester, root: 'A');

    await type(tester, '1 5 6m 4');

    expect(find.text('A   E   F#m   D'), findsOne);
  });

  testWidgets('the other direction turns chords into numbers', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Chords to numbers'));
    await tester.pumpAndSettle();
    await type(tester, 'C G Am F');

    expect(find.text('1 5 6 4'), findsOne);
  });

  testWidgets('turning the switch reads the answer back the other way', (
    tester,
  ) async {
    await pump(tester);

    // The field holds `1 5 6m 4` and the answer is `C   G   Am   F`; flipping puts
    // that answer into the field, so the two directions demonstrate each other.
    await tester.tap(find.text('Chords to numbers'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'C   G   Am   F'), findsOne);
    expect(find.text('1 5 6 4'), findsOne);
  });

  testWidgets('a line the engine cannot read says so and stays open', (
    tester,
  ) async {
    await pump(tester);

    await type(tester, '1 5 9');

    expect(find.text('"9" is not a chord number in a key.'), findsOne);

    // And a correction is read as usual: the field never explodes underneath them.
    await type(tester, '1 5 6');
    expect(find.text('C   G   Am'), findsOne);
  });

  testWidgets('an empty field says nothing rather than complaining', (
    tester,
  ) async {
    await pump(tester);

    await type(tester, '');

    expect(find.text('Nothing typed yet.'), findsOne);
  });
}
