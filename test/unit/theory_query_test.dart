import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/music/chord.dart';
import 'package:tone_vault/core/music/pitch_class.dart';
import 'package:tone_vault/core/music/scale.dart';
import 'package:tone_vault/core/music/scale_type.dart';
import 'package:tone_vault/core/music/theory_query.dart';

/// What a lesson names its theory as, turned into something that can be drawn.
void main() {
  final c = Scale(PitchClass.parse('C'), ScaleType.major);

  Chord? chordIn(String written) => switch (resolveTheoryKey(written, key: c)) {
    ChordReference(:final chord) => chord,
    _ => null,
  };

  Scale? scaleIn(String written) => switch (resolveTheoryKey(written, key: c)) {
    ScaleReference(:final scale) => scale,
    _ => null,
  };

  int? intervalIn(String written) =>
      switch (resolveTheoryKey(written, key: c)) {
        IntervalReference(:final semitones) => semitones,
        _ => null,
      };

  Chord? arpeggioIn(String written) =>
      switch (resolveTheoryKey(written, key: c)) {
        ArpeggioReference(:final chord) => chord,
        _ => null,
      };

  List<String> progressionIn(String written) =>
      switch (resolveTheoryKey(written, key: c)) {
        ProgressionReference(:final chords) => [
          for (final chord in chords) chord.symbol,
        ],
        _ => const [],
      };

  test('a chord symbol comes back as a chord', () {
    expect(chordIn('Am7'), Chord.parse('Am7'));
    expect(chordIn('C/E'), Chord.parse('C/E'));
    expect(chordIn('E5'), Chord.parse('E5'));
  });

  test('a named scale comes back as a scale', () {
    expect(scaleIn('G major'), Scale(PitchClass.parse('G'), ScaleType.major));
    expect(
      scaleIn('A minor pentatonic'),
      Scale(PitchClass.parse('A'), ScaleType.minorPentatonic),
    );
    expect(scaleIn('E dorian'), Scale(PitchClass.parse('E'), ScaleType.dorian));
    expect(
      scaleIn('Ab melodic minor'),
      Scale(PitchClass.parse('Ab'), ScaleType.melodicMinor),
    );
  });

  test('the words players use for a scale are read as that scale', () {
    expect(scaleIn('A blues scale')?.type, ScaleType.blues);
    expect(scaleIn('A NATURAL MINOR')?.type, ScaleType.minor);
    expect(scaleIn('D aeolian')?.type, ScaleType.minor);
    // A bare pentatonic means the major one.
    expect(scaleIn('D pentatonic')?.type, ScaleType.majorPentatonic);
  });

  test('a minor chord and a minor key are told apart by the space', () {
    expect(chordIn('Am'), Chord.parse('Am'));
    expect(scaleIn('A minor')?.type, ScaleType.minor);
    expect(chordIn('A minor'), isNull);
  });

  test('a note and a distance come back as an interval', () {
    expect(
      resolveTheoryKey('A perfect 5th', key: c),
      isA<IntervalReference>()
          .having((each) => each.root, 'root', PitchClass.parse('A'))
          .having((each) => each.semitones, 'semitones', 7),
    );
    expect(intervalIn('C minor 3rd'), 3);
    expect(intervalIn('E tritone'), 6);
    expect(intervalIn('G octave'), 12);
  });

  test('and by the other words players use for the same distance', () {
    // The same fret, asked for the three ways it gets written down.
    expect(intervalIn('B flat 5th'), 6);
    expect(intervalIn('B augmented 4th'), 6);
    expect(intervalIn('B diminished 5th'), 6);
    expect(intervalIn('D whole step'), 2);
  });

  test('an interval says which two notes it is, in the root\'s spelling', () {
    expect(resolveTheoryKey('A perfect 5th', key: c)?.label, 'A perfect 5th');
    // Bb rather than the A# the same fret would be called from the other side.
    expect(resolveTheoryKey('Bb minor 3rd', key: c)?.label, 'Bb minor 3rd');
  });

  test('a chord with the word after it comes back as an arpeggio', () {
    expect(arpeggioIn('Cmaj7 arpeggio'), Chord.parse('Cmaj7'));
    expect(arpeggioIn('Am arp'), Chord.parse('Am'));
    expect(resolveTheoryKey('F#m7 arpeggio', key: c)?.label, 'F#m7 arpeggio');
    // The label is read back as what it was, so a kept one draws itself again.
    expect(arpeggioIn('F#m7 arpeggio'), Chord.parse('F#m7'));
  });

  test('the word alone, or after nothing readable, is not an arpeggio', () {
    expect(resolveTheoryKey('arpeggio', key: c), isNull);
    expect(resolveTheoryKey('the blues arpeggio', key: c), isNull);
    // A spelled-out quality is left to whatever knows what qualities are called.
    expect(resolveTheoryKey('C major arpeggio', key: c), isNull);
  });

  test('a progression is read against the key it is given', () {
    expect(progressionIn('1 5 6 4'), ['C', 'G', 'Am', 'F']);
    expect(resolveTheoryKey('1 5 6 4', key: c)?.label, '1 5 6 4 in C major');
  });

  test('numerals are read as a progression too', () {
    expect(progressionIn('ii-V-I'), ['Dm', 'G', 'C']);
    expect(progressionIn('I-V-vi-IV'), ['C', 'G', 'Am', 'F']);
  });

  test('a progression with no key to read it against is left unread', () {
    expect(resolveTheoryKey('1 5 6 4'), isNull);
    // A chord is still a chord without one, because it does not need a key.
    expect(resolveTheoryKey('Am7'), isA<ChordReference>());
  });

  test('anything unreadable comes back as nothing rather than throwing', () {
    expect(resolveTheoryKey('', key: c), isNull);
    expect(resolveTheoryKey('the blues', key: c), isNull);
    expect(resolveTheoryKey('Hmmm', key: c), isNull);
  });

  test('a list keeps what it could read and says what it is called', () {
    final references = resolveTheoryKeys([
      'Am7',
      'nonsense',
      'G mixolydian',
    ], key: c);
    expect(
      [for (final reference in references) reference.label],
      ['Am7', 'G Mixolydian'],
    );
  });
}
