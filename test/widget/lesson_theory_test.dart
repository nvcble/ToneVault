import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/features/academy/widgets/lesson_theory.dart';
import 'package:tone_vault/shared/widgets/fret_cell.dart';
import 'package:tone_vault/shared/widgets/fretboard_view.dart';

/// The theory a lesson names, drawn on a neck underneath it.
void main() {
  Future<void> pumpTheory(WidgetTester tester, List<String> keys) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: LessonTheory(theoryKeys: keys)),
      ),
    );
  }

  testWidgets('a lesson that names no theory draws nothing', (tester) async {
    await pumpTheory(tester, const []);

    expect(find.byType(FretboardView), findsNothing);
    expect(find.text('On the neck'), findsNothing);
  });

  testWidgets('one thing is drawn without a row of chips to choose from', (
    tester,
  ) async {
    await pumpTheory(tester, const ['A minor pentatonic']);

    expect(find.text('A minor pentatonic'), findsOne);
    expect(find.byType(ChoiceChip), findsNothing);
  });

  testWidgets('several things are chosen between, one at a time', (
    tester,
  ) async {
    await pumpTheory(tester, const ['Em', 'Am', 'C']);

    expect(find.byType(ChoiceChip), findsExactly(3));
    expect(find.byType(FretboardView), findsOne);

    await tester.tap(find.widgetWithText(ChoiceChip, 'C'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<FretboardView>(find.byType(FretboardView)).diagram.title,
      'C',
    );
  });

  testWidgets('a progression becomes a chip for each of its chords', (
    tester,
  ) async {
    // The scale is what says which key the numbers are in, so it is read first.
    await pumpTheory(tester, const ['G major', '1 6 4 5']);

    expect(find.widgetWithText(ChoiceChip, 'G major'), findsOne);
    expect(find.widgetWithText(ChoiceChip, 'Em'), findsOne);
    expect(find.widgetWithText(ChoiceChip, 'D'), findsOne);
  });

  testWidgets('the dots can be read as degrees or as note names', (
    tester,
  ) async {
    await pumpTheory(tester, const ['Am']);

    expect(find.text('b3'), findsWidgets);

    await tester.tap(find.text('Note names'));
    await tester.pumpAndSettle();

    expect(find.text('b3'), findsNothing);
    expect(find.text('Degrees'), findsOne);
    expect(
      tester.widget<FretboardView>(find.byType(FretboardView)).marking,
      FretMarking.note,
    );
  });

  testWidgets('anything the engine cannot read is left out', (tester) async {
    await pumpTheory(tester, const ['Am', 'not a chord at all']);

    expect(find.byType(FretCell), findsWidgets);
    expect(find.byType(ChoiceChip), findsNothing);
  });
}
