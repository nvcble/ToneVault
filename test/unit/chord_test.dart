import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/core/music/chord.dart';
import 'package:tone_vault/core/music/chord_type.dart';
import 'package:tone_vault/core/music/pitch_class.dart';

/// Chords: a quality applied to a root, read from and written back to a chart.
void main() {
  /// The notes a chord is made of, as a player would read them off it.
  List<String> notesOf(Chord chord) => [
    for (final note in chord.notes) note.name(flats: chord.prefersFlats),
  ];

  test('a plain triad is read from its letter', () {
    final chord = Chord.parse('C');
    expect(chord.type, ChordType.major);
    expect(notesOf(chord), ['C', 'E', 'G']);
  });

  test('the qualities a lesson writes are all read', () {
    expect(Chord.parse('Am7').type, ChordType.minorSeventh);
    expect(Chord.parse('F#m7b5').type, ChordType.halfDiminished);
    expect(Chord.parse('Bb13').type, ChordType.dominantThirteenth);
    expect(Chord.parse('Cadd9').type, ChordType.add9);
    expect(Chord.parse('Dsus4').type, ChordType.sus4);
    expect(Chord.parse('E5').type, ChordType.fifth);
    expect(Chord.parse('G7alt').type, ChordType.dominantSeventhSharpNine);
  });

  test('the spellings players use for one quality mean the same chord', () {
    expect(Chord.parse('Cmaj'), Chord.parse('C'));
    expect(Chord.parse('Amin7'), Chord.parse('Am7'));
    expect(Chord.parse('CM7'), Chord.parse('Cmaj7'));
    expect(Chord.parse('Bø'), Chord.parse('Bm7b5'));
  });

  test('a slash chord keeps the bass note under it', () {
    final chord = Chord.parse('C/E');
    expect(chord.bass, PitchClass.parse('E'));
    expect(chord.symbol, 'C/E');
    // E is already in C, so the note list is not lengthened by asking for it below.
    expect(notesOf(chord), ['C', 'E', 'G']);
    expect(notesOf(Chord.parse('C/B')), ['B', 'C', 'E', 'G']);
  });

  test('something that is not a chord is refused rather than guessed at', () {
    expect(() => Chord.parse('Cwhat'), throwsA(isA<AppFailure>()));
    expect(() => Chord.parse('Hm'), throwsA(isA<AppFailure>()));
  });

  test('the third is the note that says major or minor', () {
    expect(Chord.parse('C').third, PitchClass.parse('E'));
    expect(Chord.parse('Cm').third, PitchClass.parse('Eb'));
    expect(Chord.parse('C5').third, isNull);
  });

  test('an extension stays where it is played rather than folding down', () {
    // The ninth of C9 is a D an octave up, and a fretboard needs to know that.
    expect(ChordType.dominantNinth.intervals.last, 14);
    expect(Chord.parse('C9').contains(PitchClass.parse('D')), isTrue);
  });

  test('a chord transposes with its bass note', () {
    expect(Chord.parse('C/E').transpose(2), Chord.parse('D/F#'));
  });

  test(
    'a chord is written with the flats its root is usually written with',
    () {
      expect(Chord.parse('Bb7').symbol, 'Bb7');
      expect(Chord(PitchClass(3), ChordType.minor).symbol, 'Ebm');
      expect(Chord(PitchClass(6), ChordType.major).symbol, 'F#');
    },
  );

  test('which quality knows it is a dominant', () {
    expect(ChordType.dominantSeventh.isDominant, isTrue);
    expect(ChordType.dominantThirteenth.isDominant, isTrue);
    expect(ChordType.majorSeventh.isDominant, isFalse);
    expect(ChordType.minorSeventh.isDominant, isFalse);
    expect(ChordType.dominantSeventhSus4.isDominant, isFalse);
  });

  test('a quality is written as the degrees it stacks', () {
    // The formula is the chord in every key at once, which is why it is worth showing
    // beside a spelling that is only one key's worth of it.
    expect(ChordType.major.formula, '1 3 5');
    expect(ChordType.minorSeventh.formula, '1 b3 5 b7');
    expect(ChordType.halfDiminished.formula, '1 b3 b5 b7');
    // An extension is numbered as one rather than folded into the octave.
    expect(ChordType.dominantNinth.formula, '1 3 5 b7 9');
    expect(ChordType.dominantThirteenth.formula, '1 3 5 b7 9 13');
  });

  test('and as the distances between its notes, said in words', () {
    expect(ChordType.major.intervalNames, ['root', 'major 3rd', 'perfect 5th']);
    expect(
      ChordType.dominantNinth.intervalNames.last,
      'octave and a major 2nd',
    );
    for (final type in ChordType.values) {
      expect(type.formula.split(' '), hasLength(type.intervals.length));
      expect(type.intervalNames, hasLength(type.intervals.length));
    }
  });

  test('a stack of intervals is named back into a quality', () {
    expect(chordTypeFor(const [0, 4, 7]), ChordType.major);
    expect(chordTypeFor(const [0, 3, 6, 10]), ChordType.halfDiminished);
    // Compared as pitch classes, so a ninth two octaves up is still a ninth.
    expect(chordTypeFor(const [0, 4, 7, 10, 26]), ChordType.dominantNinth);
    expect(chordTypeFor(const [0, 1, 2]), isNull);
  });
}
