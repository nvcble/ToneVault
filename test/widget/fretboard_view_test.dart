import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/music/chord.dart';
import 'package:tone_vault/core/music/chord_voicing.dart';
import 'package:tone_vault/core/music/fretboard.dart';
import 'package:tone_vault/core/music/fretboard_diagram.dart';
import 'package:tone_vault/core/music/pitch_class.dart';
import 'package:tone_vault/core/music/scale.dart';
import 'package:tone_vault/core/music/scale_type.dart';
import 'package:tone_vault/core/music/tuning.dart';
import 'package:tone_vault/shared/widgets/fret_cell.dart';
import 'package:tone_vault/shared/widgets/fretboard_view.dart';

/// The one fretboard in the app, drawing whatever it is handed.
void main() {
  Future<void> pumpBoard(
    WidgetTester tester, {
    required FretboardDiagram diagram,
    Fretboard fretboard = const Fretboard(),
    FretMarking marking = FretMarking.degree,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FretboardView(
            diagram: diagram,
            fretboard: fretboard,
            marking: marking,
          ),
        ),
      ),
    );
  }

  final aMinorPentatonic = diagramOfScale(
    Scale(PitchClass.parse('A'), ScaleType.minorPentatonic),
  );

  testWidgets('draws a fret for every string across the window', (
    tester,
  ) async {
    await pumpBoard(
      tester,
      diagram: aMinorPentatonic,
      fretboard: const Fretboard(fretCount: 4),
    );

    // Six strings across five frets, counting the open string as one of them.
    expect(find.byType(FretCell), findsNWidgets(6 * 5));
  });

  testWidgets('says what it is a diagram of', (tester) async {
    await pumpBoard(tester, diagram: aMinorPentatonic);

    expect(find.text('A minor pentatonic'), findsOneWidget);
  });

  testWidgets('marks the degrees of the shape and nothing else', (
    tester,
  ) async {
    await pumpBoard(
      tester,
      diagram: aMinorPentatonic,
      fretboard: const Fretboard(fretCount: 2),
    );

    // The open A string is the root, and the open G string is the flat seventh.
    expect(find.text('1'), findsWidgets);
    expect(find.text('b7'), findsWidgets);
    // Nothing in the scale is a major third or a major seventh.
    expect(find.text('3'), findsNothing);
    expect(find.text('7'), findsNothing);
  });

  testWidgets('writes note names instead when it is asked to', (tester) async {
    await pumpBoard(
      tester,
      diagram: aMinorPentatonic,
      fretboard: const Fretboard(fretCount: 3),
      marking: FretMarking.note,
    );

    expect(find.text('A'), findsWidgets);
    expect(find.text('b7'), findsNothing);
  });

  testWidgets('numbers the frets a guitar has dots on', (tester) async {
    // Note names in the dots, so the only digits on screen are the fret numbers.
    await pumpBoard(
      tester,
      diagram: aMinorPentatonic,
      fretboard: const Fretboard(fretCount: 5),
      marking: FretMarking.note,
    );

    expect(find.text('3'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    // No number under the second fret, because no guitar marks it.
    expect(find.text('2'), findsNothing);
  });

  testWidgets('draws whichever tuning it is handed', (tester) async {
    // In Drop D the low string is a D, so the root of a D chord is at its nut.
    await pumpBoard(
      tester,
      diagram: diagramOfChord(Chord.parse('D')),
      fretboard: const Fretboard(tuning: Tuning.dropD, fretCount: 2),
    );

    final cells = tester.widgetList<FretCell>(find.byType(FretCell)).toList();
    // The rows are drawn high string first, so the last row is the low one, and its
    // first cell is the open string.
    expect(cells.last.label, isNull);
    expect(cells[cells.length - 3].label, '1');
  });

  testWidgets('a chord shows which note is the root', (tester) async {
    await pumpBoard(
      tester,
      diagram: diagramOfChord(Chord.parse('Am')),
      fretboard: const Fretboard(fretCount: 3),
    );

    final roots = tester
        .widgetList<FretCell>(find.byType(FretCell))
        .where((cell) => cell.isRoot && cell.label != null);

    expect(roots, isNotEmpty);
    expect(roots.every((cell) => cell.label == '1'), isTrue);
  });

  group('handed a voicing as well', () {
    const window = Fretboard(fretCount: 4);

    /// The cells of one string, lowest fret first. The rows are drawn high string first,
    /// which is a drawing decision the test has to undo to talk about the 6th string.
    List<FretCell> stringCells(WidgetTester tester, int string) {
      final cells = tester.widgetList<FretCell>(find.byType(FretCell)).toList();
      final width = window.fretCount + 1;
      final row = 5 - string;
      return cells.sublist(row * width, (row + 1) * width);
    }

    Future<void> pumpVoicing(
      WidgetTester tester, {
      FretMarking marking = FretMarking.finger,
    }) async {
      final voicing = voicingsFor(
        Chord.parse('A'),
      ).firstWhere((found) => found.name == 'A shape');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FretboardView(
              diagram: diagramOfChord(voicing.chord),
              fretboard: window,
              voicing: voicing,
              marking: marking,
              showTitle: false,
            ),
          ),
        ),
      );
    }

    testWidgets('marks only the frets the hand presses', (tester) async {
      await pumpVoicing(tester, marking: FretMarking.degree);

      // Six marks: the five strings the shape plays, and the x on the one it does not.
      // Without the voicing every A, C# and E in the window would be marked, which is
      // eighteen dots and not a chord anybody can hold.
      final marked = tester
          .widgetList<FretCell>(find.byType(FretCell))
          .where((cell) => cell.label != null);
      expect(marked, hasLength(6));

      // The open A string is the root of the chord and the second fret of the D string
      // is its fifth; the third fret of the D string is in the window and not in the
      // shape, so it stays bare.
      final dString = stringCells(tester, 2);
      expect(dString[2].label, '5');
      expect(dString[3].label, isNull);
    });

    testWidgets('and says which finger holds each of them', (tester) async {
      await pumpVoicing(tester);

      final aString = stringCells(tester, 1);
      // An open string is written 0, as a chord box writes it, and no finger is on it.
      expect(aString[0].label, '0');
      expect(stringCells(tester, 2)[2].label, '3');
      expect(stringCells(tester, 5)[0].label, '0');
    });

    testWidgets('and draws the string it leaves out as left out', (
      tester,
    ) async {
      await pumpVoicing(tester);

      final low = stringCells(tester, 0);
      // Faint the whole way along, with the x at the near end rather than under the
      // hand: a player has to see the string is out before they read anything.
      expect(low.every((cell) => cell.isMuted), isTrue);
      expect(low.first.label, '×');
      expect(low.skip(1).every((cell) => cell.label == null), isTrue);
      expect(stringCells(tester, 1).any((cell) => cell.isMuted), isFalse);
    });
  });
}
