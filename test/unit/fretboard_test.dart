import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/music/chord.dart';
import 'package:tone_vault/core/music/fretboard.dart';
import 'package:tone_vault/core/music/fretboard_diagram.dart';
import 'package:tone_vault/core/music/interval.dart';
import 'package:tone_vault/core/music/pitch_class.dart';
import 'package:tone_vault/core/music/scale.dart';
import 'package:tone_vault/core/music/scale_type.dart';
import 'package:tone_vault/core/music/theory_query.dart';
import 'package:tone_vault/core/music/tuning.dart';

/// Where the notes are on a neck, and what a diagram calls them.
void main() {
  const board = Fretboard();

  test('a tuning says what the open strings are', () {
    expect(Tuning.standard.label, 'E A D G B E');
    expect(Tuning.dropD.label, 'D A D G B E');
    expect(Tuning.standard.stringCount, 6);
  });

  test('a fret is a semitone, so the twelfth is the open string again', () {
    expect(board.noteAt(0, 0), PitchClass.parse('E'));
    expect(board.noteAt(0, 5), PitchClass.parse('A'));
    expect(board.noteAt(0, 12), board.noteAt(0, 0));
    expect(board.noteAt(4, 3), PitchClass.parse('D'));
  });

  test('a note is found everywhere it can be played in the window', () {
    final found = board.positionsOf([PitchClass.parse('E')]);

    // Twice on every string across twelve frets, because the twelfth fret repeats
    // the open string.
    expect(found.where((note) => note.string == 0).map((note) => note.fret), [
      0,
      12,
    ]);
    expect(found.every((note) => note.note == PitchClass.parse('E')), isTrue);
  });

  test('a window higher up the neck leaves the open strings out of it', () {
    const position = Fretboard(firstFret: 5, fretCount: 4);
    final found = position.positionsOf([PitchClass.parse('E')]);

    expect(
      found.map((note) => note.fret),
      everyElement(inInclusiveRange(5, 9)),
    );
    expect(position.lastFret, 9);
  });

  test('the lowest place on each string is one place per string', () {
    final lowest = board.lowestOf(PitchClass.parse('G'));

    expect(lowest, hasLength(6));
    expect(lowest.map((note) => note.string).toSet(), hasLength(6));
    // Third fret of the low E, which is where a guitarist plays a G without thinking.
    expect(lowest.first.fret, 3);
  });

  test('the frets a guitar puts a dot on are the ones it puts a dot on', () {
    expect(Fretboard.isInlaid(3), isTrue);
    expect(Fretboard.isInlaid(12), isTrue);
    expect(Fretboard.isInlaid(4), isFalse);
    expect(Fretboard.isInlaid(0), isFalse);
  });

  test('a scale is numbered the way it is taught', () {
    final diagram = diagramOfScale(
      Scale(PitchClass.parse('A'), ScaleType.minorPentatonic),
    );

    expect(diagram.title, 'A minor pentatonic');
    expect(diagram.root, PitchClass.parse('A'));
    expect(diagram.degrees.values, ['1', 'b3', '4', '5', 'b7']);
    expect(diagram.degreeOf(PitchClass.parse('C')), 'b3');
    expect(diagram.degreeOf(PitchClass.parse('C#')), isNull);
  });

  test('a chord is numbered by its extensions', () {
    final diagram = diagramOfChord(Chord.parse('C9'));

    expect(diagram.title, 'C9');
    expect(diagram.degrees.values, ['1', '3', '5', 'b7', '9']);
  });

  test('an altered dominant spells its sharp ninth as one', () {
    // The semitones alone cannot tell a #9 from a b10, and the chord can: it has a
    // major third in it already.
    expect(degreeLabel(augmentedNinth), 'b10');
    expect(diagramOfChord(Chord.parse('G7#9')).degrees.values, contains('#9'));
  });

  test('a slash chord marks the note underneath it', () {
    expect(
      diagramOfChord(Chord.parse('C/B')).degreeOf(PitchClass.parse('B')),
      '7',
    );
    // E is the third of C, and is still called the third when it is in the bass.
    expect(
      diagramOfChord(Chord.parse('C/E')).degreeOf(PitchClass.parse('E')),
      '3',
    );
  });

  test('a scale is spelled the way its key is written', () {
    final diagram = diagramOfScale(
      Scale(PitchClass.parse('Eb'), ScaleType.major),
    );

    expect(diagram.nameOf(PitchClass.parse('Ab')), 'Ab');
  });

  test('a progression becomes one diagram per chord, in order', () {
    final reference = resolveTheoryKey(
      'ii-V-I',
      key: Scale(PitchClass.parse('C'), ScaleType.major),
    );

    expect(
      [for (final diagram in diagramsFor(reference!)) diagram.title],
      ['Dm', 'G', 'C'],
    );
  });

  test('a lesson reads its progression in the key it also names', () {
    final diagrams = diagramsForKeys(const ['G major', '1 6 4 5']);

    expect(
      [for (final diagram in diagrams) diagram.title],
      ['G major', 'G', 'Em', 'C', 'D'],
    );
  });

  test('a lesson that names nothing readable asks for no diagrams', () {
    expect(diagramsForKeys(const []), isEmpty);
    expect(diagramsForKeys(const ['whatever this is']), isEmpty);
    // The one it can read survives the one it cannot.
    expect(diagramsForKeys(const ['whatever this is', 'Am']), hasLength(1));
  });

  test('a chord and a scale each become one diagram', () {
    expect(diagramsFor(ChordReference(Chord.parse('Am7'))), hasLength(1));
    expect(
      diagramsFor(
        ScaleReference(Scale(PitchClass.parse('G'), ScaleType.mixolydian)),
      ),
      hasLength(1),
    );
  });

  test('an interval is two notes, numbered from the one it is measured from', () {
    final diagram = diagramOfInterval(PitchClass.parse('A'), perfectFifth);

    expect(diagram.title, 'A perfect 5th');
    expect(diagram.degreeOf(PitchClass.parse('A')), '1');
    expect(diagram.degreeOf(PitchClass.parse('E')), '5');
    // Two and no more: everything else on the neck is left unmarked, which is what
    // makes the shape of the distance the only thing there is to see.
    expect(diagram.notes, hasLength(2));
  });

  test('an octave is the one note, because that is where it lands', () {
    final diagram = diagramOfInterval(PitchClass.parse('G'), octave);

    expect(diagram.notes, [PitchClass.parse('G')]);
    // A 1 rather than an 8: the note an octave up is the same note.
    expect(diagram.degreeOf(PitchClass.parse('G')), '1');
  });

  test('an interval is spelled the way its own root is written', () {
    expect(
      diagramOfInterval(
        PitchClass.parse('Bb'),
        minorThird,
      ).nameOf(PitchClass.parse('Db')),
      'Db',
    );
  });

  test('an arpeggio is the chord it is of, said to be one', () {
    final chord = Chord.parse('Cmaj7');
    final arpeggio = diagramOfArpeggio(chord);

    expect(arpeggio.title, 'Cmaj7 arpeggio');
    // The same notes under the same numbers: an arpeggio is not other notes.
    expect(arpeggio.degrees, diagramOfChord(chord).degrees);
    expect(arpeggio.root, chord.root);
  });

  test('an interval and an arpeggio each become one diagram', () {
    expect(diagramsFor(IntervalReference(PitchClass.parse('D'), majorSixth)), [
      isA<FretboardDiagram>().having(
        (each) => each.title,
        'title',
        'D major 6th',
      ),
    ]);
    expect(diagramsFor(ArpeggioReference(Chord.parse('Am7'))), [
      isA<FretboardDiagram>().having(
        (each) => each.title,
        'title',
        'Am7 arpeggio',
      ),
    ]);
  });

  test('a lesson can name an interval or an arpeggio among its keys', () {
    final diagrams = diagramsForKeys(const [
      'G major',
      'G perfect 5th',
      'Em7 arpeggio',
    ]);

    expect(
      [for (final diagram in diagrams) diagram.title],
      ['G major', 'G perfect 5th', 'Em7 arpeggio'],
    );
  });
}
