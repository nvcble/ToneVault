import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/music/chord.dart';
import 'package:tone_vault/core/music/chord_family.dart';
import 'package:tone_vault/core/music/pitch_class.dart';
import 'package:tone_vault/core/music/scale.dart';
import 'package:tone_vault/core/music/scale_type.dart';

/// The chords of a key, stacked out of its scale rather than listed per key.
void main() {
  ChordFamily familyOf(String root, ScaleType type) =>
      ChordFamily(Scale(PitchClass.parse(root), type));

  List<String> triadsOf(ChordFamily family) => [
    for (final chord in family.chords) chord.triad.symbol,
  ];

  test('a major key gives the pattern every guitarist learns first', () {
    expect(triadsOf(familyOf('C', ScaleType.major)), [
      'C',
      'Dm',
      'Em',
      'F',
      'G',
      'Am',
      'Bdim',
    ]);
  });

  test('the same stacking gives a minor key its own pattern for free', () {
    expect(triadsOf(familyOf('A', ScaleType.minor)), [
      'Am',
      'Bdim',
      'C',
      'Dm',
      'Em',
      'F',
      'G',
    ]);
  });

  test('the sevenths are the same chords with one more note on top', () {
    final chords = familyOf('C', ScaleType.major).chords;
    expect(
      [for (final chord in chords) chord.seventh.symbol],
      ['Cmaj7', 'Dm7', 'Em7', 'Fmaj7', 'G7', 'Am7', 'Bm7b5'],
    );
  });

  test('the numerals say the quality without repeating it', () {
    final chords = familyOf('C', ScaleType.major).chords;
    expect(
      [for (final chord in chords) chord.roman],
      ['I', 'ii', 'iii', 'IV', 'V', 'vi', 'vii°'],
    );
    expect(
      [for (final chord in chords) chord.romanSeventh],
      ['Imaj7', 'ii7', 'iii7', 'IVmaj7', 'V7', 'vi7', 'viiø7'],
    );
  });

  test('a mode is harmonised by the same rule', () {
    // The major four chord is what makes dorian sound like it does, and it falls out
    // of the stacking rather than being written down anywhere.
    expect(familyOf('D', ScaleType.dorian).chordOn(4)!.triad.symbol, 'G');
    expect(familyOf('G', ScaleType.mixolydian).chordOn(5)!.triad.symbol, 'Dm');
  });

  test('harmonic minor gives the dominant five chord a minor key wants', () {
    final family = familyOf('A', ScaleType.harmonicMinor);
    expect(family.chordOn(5)!.triad.symbol, 'E');
    expect(family.chordOn(5)!.seventh.symbol, 'E7');
    // Spelled as the key spells it: the chord on its own would call itself Abdim7.
    expect(family.chordOn(7)!.seventh.spell(flats: false), 'G#dim7');
  });

  test(
    'a degree past seven wraps, because a chart calls the two chord a nine',
    () {
      final family = familyOf('C', ScaleType.major);
      expect(family.chordOn(9)!.triad, family.chordOn(2)!.triad);
    },
  );

  test('a chord knows which degree of a key it is, and when it is borrowed', () {
    final family = familyOf('C', ScaleType.major);
    expect(family.degreeOf(Chord.parse('G')), 5);
    // A ii played as a ii7 is still the ii: the third is what is matched, not the rest.
    expect(family.degreeOf(Chord.parse('Dm7')), 2);
    expect(family.degreeOf(Chord.parse('Eb')), isNull);
    expect(family.degreeOf(Chord.parse('Fm')), isNull);
  });

  test(
    'a scale with no seventh degree has no family rather than a wrong one',
    () {
      expect(familyOf('A', ScaleType.minorPentatonic).chords, isEmpty);
      expect(familyOf('A', ScaleType.blues).chordOn(1), isNull);
    },
  );
}
