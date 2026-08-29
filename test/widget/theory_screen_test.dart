import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/theme/app_theme.dart';
import 'package:tone_vault/features/theory/screens/theory_screen.dart';
import 'package:tone_vault/features/theory/widgets/circle_of_fifths_wheel.dart';

/// The theory browser: one key, and five views that all follow it.
///
/// Nothing is stubbed. There is no database and no audio behind this screen - every list
/// on it is worked out from the key by the engine, so what a test sets up is the key.
void main() {
  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark(), home: const TheoryScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Six tabs are more than a phone's width, so the bar scrolls and the last of them has
  /// to be brought into view before it can be tapped - as a player would have to.
  Future<void> openTab(WidgetTester tester, String label) async {
    final tab = find.text(label);
    await tester.ensureVisible(tab);
    await tester.pumpAndSettle();
    await tester.tap(tab);
    await tester.pumpAndSettle();
  }

  testWidgets('opens on the chords of C major, numbered three ways', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('The chords of C major'), findsOne);
    expect(find.text('ii'), findsOne);
    expect(find.text('Dm'), findsOne);
    expect(find.text('G7'), findsOne);
  });

  testWidgets('the minor of the same root is a different family of chords', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.text('Minor'));
    await tester.pumpAndSettle();

    expect(find.text('The chords of C minor'), findsOne);
    // The five chord of a natural minor key is minor, which is the whole reason
    // harmonic minor exists.
    expect(find.text('Gm'), findsOne);
  });

  testWidgets('the circle changes the key for every tab at once', (
    tester,
  ) async {
    await pump(tester);

    await openTab(tester, 'Circle');
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();

    expect(find.text('A major'), findsOne);
    expect(find.text('3 sharps'), findsOne);

    await openTab(tester, 'Chords');

    expect(find.text('The chords of A major'), findsOne);
  });

  testWidgets('and says what the key it lands on is made of', (tester) async {
    await pump(tester);
    await openTab(tester, 'Circle');

    // The wheel is as wide as the screen and square, so what it says about the key it
    // is turned to is below it. The tab bar scrolls too, hence naming the wheel's own
    // scrollable rather than taking the first one on the screen.
    await tester.scrollUntilVisible(
      find.text('Relative minor'),
      300,
      scrollable: find.descendant(
        of: find.byType(CircleOfFifthsWheel),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('A minor'), findsOne);
    expect(find.text('C   Dm   Em   F   G   Am   Bdim'), findsOne);
    expect(find.text('I   ii   iii   IV   V   vi   vii°'), findsOne);
  });

  testWidgets('the scales tab puts every mode on the key\'s root', (
    tester,
  ) async {
    await pump(tester);

    await openTab(tester, 'Scales');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Dorian'));
    await tester.pumpAndSettle();

    expect(find.text('C Dorian'), findsOne);
    // The flat third and flat seventh that make it Dorian rather than major.
    expect(find.textContaining('Eb b3'), findsOne);
    expect(find.textContaining('Bb b7'), findsOne);
  });

  testWidgets('the shapes tab is the chords of the key put under a hand', (
    tester,
  ) async {
    await pump(tester);

    await openTab(tester, 'Shapes');
    await tester.tap(find.text('Cm'));
    await tester.pumpAndSettle();

    expect(find.text('E shape'), findsOne);
    expect(find.textContaining('3rd string'), findsWidgets);
  });

  testWidgets('the progressions tab writes each one out three ways', (
    tester,
  ) async {
    await pump(tester);

    await openTab(tester, 'Progressions');

    expect(find.text('Pop'), findsOne);
    expect(find.text('C  G  Am  F'), findsOne);
    expect(find.text('I-V-vi-IV   ·   1 5 6 4'), findsOne);
  });

  testWidgets('the substitutions tab gives a reason, not a list of swaps', (
    tester,
  ) async {
    await pump(tester);

    await openTab(tester, 'Substitutions');

    expect(find.text('Instead of Cmaj7'), findsOne);
    expect(find.textContaining('relative minor'), findsOne);
  });

  testWidgets('and a dominant offers the swap only a dominant can', (
    tester,
  ) async {
    await pump(tester);
    await openTab(tester, 'Substitutions');

    await tester.tap(find.widgetWithText(ChoiceChip, 'V7'));
    await tester.pumpAndSettle();

    expect(find.text('Instead of G7'), findsOne);
    expect(find.text('Db7'), findsOne);
    expect(find.textContaining('Tritone substitute'), findsOne);
  });
}
