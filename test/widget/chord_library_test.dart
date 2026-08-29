import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/theme/app_theme.dart';
import 'package:tone_vault/core/music/pitch_class.dart';
import 'package:tone_vault/core/music/scale.dart';
import 'package:tone_vault/core/music/scale_type.dart';
import 'package:tone_vault/features/theory/providers/theory_providers.dart';
import 'package:tone_vault/features/theory/widgets/chord_library.dart';

/// The chord library: every quality on the key's root, each opening onto the fingerings.
///
/// Nothing is stubbed and nothing is stored. The names, the spellings and the shapes are
/// all worked out from the key by the engine, so what a test sets up is the key.
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
          home: const Scaffold(body: ChordLibrary()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('names every quality on the key\'s root and what it spells', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('C'), findsOne);
    expect(find.text('Cm'), findsOne);
    expect(find.text('Cdim'), findsOne);
    expect(find.text('major · C E G'), findsOne);
    expect(find.text('minor · C Eb G'), findsOne);
  });

  testWidgets('and nothing is drawn until one of them is asked about', (
    tester,
  ) async {
    await pump(tester);

    // Twenty-six qualities' worth of chord boxes is a screen nobody can read and a lot
    // of placement arithmetic for the one chord they wanted.
    expect(find.text('C shape'), findsNothing);
  });

  testWidgets('opening one shows every way the app knows to hold it', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.text('C'));
    await tester.pumpAndSettle();

    // C major has four shapes that fit the first twelve frets: the open C, the A shape
    // barred at the third, and the G and E shapes at the eighth.
    expect(find.text('C shape'), findsOne);
    expect(find.text('A shape'), findsOne);
    expect(find.text('G shape'), findsOne);
    expect(find.text('E shape'), findsOne);
  });

  testWidgets('and what the chord is made of, not only what it spells here', (
    tester,
  ) async {
    await pump(tester);

    await tester.scrollUntilVisible(find.text('Cm7'), 200);
    await tester.tap(find.text('Cm7'));
    await tester.pumpAndSettle();

    // `1 b3 5 b7` is a minor seventh in every key; `C Eb G Bb` is one of them.
    expect(find.text('1 b3 5 b7'), findsOne);
    expect(find.text('root · minor 3rd · perfect 5th · minor 7th'), findsOne);
  });

  testWidgets('and says where the hand goes, in words as well as dots', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.text('C'));
    await tester.pumpAndSettle();

    expect(find.text('Open, 3 frets under the hand'), findsOne);
    expect(find.text('6th string: not played'), findsWidgets);
    expect(find.text('5th string: 3rd fret, C, little finger'), findsOne);
    expect(find.text('3rd string: open, G'), findsWidgets);
  });

  testWidgets('the library follows the key', (tester) async {
    await pump(tester, root: 'A');

    expect(find.text('A'), findsOne);
    expect(find.text('major · A C# E'), findsOne);
    expect(find.text('Am'), findsOne);
  });

  testWidgets('and says so where no shape it knows fits the neck', (
    tester,
  ) async {
    await pump(tester, root: 'Bb');

    // The one shape for a minor ninth reaches two frets below its root, and the only Bb
    // on the A string that leaves room for that is past the twelfth fret. Saying so is
    // better than an empty space, which reads as a chord that does not exist.
    await tester.scrollUntilVisible(find.text('Bbm9'), 200);
    await tester.tap(find.text('Bbm9'));
    await tester.pumpAndSettle();

    expect(find.textContaining('No shape for this one fits'), findsOne);
  });
}
