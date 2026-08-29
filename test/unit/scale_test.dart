import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/music/pitch_class.dart';
import 'package:tone_vault/core/music/scale.dart';
import 'package:tone_vault/core/music/scale_type.dart';

/// Scales, which are derived from one pattern of steps rather than listed.
void main() {
  /// The notes as a player would read them out, which is what these tests are about.
  List<String> notesOf(Scale scale) => [
    for (final note in scale.notes) note.name(flats: scale.prefersFlats),
  ];

  Scale scale(String root, ScaleType type) =>
      Scale(PitchClass.parse(root), type);

  test('the major scale is the pattern everything else comes from', () {
    expect(notesOf(scale('C', ScaleType.major)), [
      'C',
      'D',
      'E',
      'F',
      'G',
      'A',
      'B',
    ]);
  });

  test('a mode is the major scale started somewhere else', () {
    // D dorian and C major are the same seven notes, which is the whole point of a
    // mode and the reason the engine rotates rather than tabulates.
    expect(
      notesOf(scale('D', ScaleType.dorian)).toSet(),
      notesOf(scale('C', ScaleType.major)).toSet(),
    );
    expect(notesOf(scale('G', ScaleType.mixolydian)).last, 'F');
    expect(notesOf(scale('E', ScaleType.phrygian)).first, 'E');
  });

  test('the minor scales differ by the notes that name them', () {
    expect(notesOf(scale('A', ScaleType.minor)).last, 'G');
    expect(notesOf(scale('A', ScaleType.harmonicMinor)).last, 'G#');
    expect(notesOf(scale('A', ScaleType.melodicMinor)).sublist(5), [
      'F#',
      'G#',
    ]);
  });

  test('the pentatonics and the blues scale have notes taken out', () {
    expect(notesOf(scale('A', ScaleType.minorPentatonic)), [
      'A',
      'C',
      'D',
      'E',
      'G',
    ]);
    expect(notesOf(scale('C', ScaleType.majorPentatonic)), [
      'C',
      'D',
      'E',
      'G',
      'A',
    ]);
    // The blues scale is the minor pentatonic with the flat fifth put back in.
    expect(notesOf(scale('A', ScaleType.blues)).length, 6);
    expect(
      scale('A', ScaleType.blues).contains(PitchClass.parse('Eb')),
      isTrue,
    );
  });

  test('a scale says whether a note is in it', () {
    final g = scale('G', ScaleType.major);
    expect(g.contains(PitchClass.parse('F#')), isTrue);
    expect(g.contains(PitchClass.parse('F')), isFalse);
  });

  test('degrees count from the root and wrap past the top', () {
    final c = scale('C', ScaleType.major);
    expect(c.degree(1), PitchClass.parse('C'));
    expect(c.degree(5), PitchClass.parse('G'));
    expect(c.degree(9), PitchClass.parse('D'));
    expect(c.degreeOf(PitchClass.parse('A')), 6);
    expect(c.degreeOf(PitchClass.parse('Ab')), isNull);
  });

  test('the two useful modes of melodic minor are rotations of it', () {
    // G lydian dominant is a major scale with a flat seventh and a sharp fourth: the
    // scale for a dominant chord that is not going anywhere.
    expect(notesOf(scale('G', ScaleType.lydianDominant)), [
      'G',
      'A',
      'B',
      'C#',
      'D',
      'E',
      'F',
    ]);
    expect(scale('G', ScaleType.altered).notes.length, 7);
  });

  test('the symmetrical scales have as many notes as their steps give them', () {
    // Not seven. Nothing in the engine may assume a scale has seven notes, and these
    // three are what would catch it if something did.
    expect(notesOf(scale('C', ScaleType.wholeTone)), [
      'C',
      'D',
      'E',
      'F#',
      'G#',
      'A#',
    ]);
    expect(scale('C', ScaleType.diminished).notes.length, 8);
    expect(scale('C', ScaleType.chromatic).notes.length, 12);
  });

  test('and they repeat, which is what makes them symmetrical', () {
    // Whole tone from C and from D are the same six notes, because a scale built of
    // equal steps has no root to speak of - which is exactly what a player uses it for.
    expect(
      notesOf(scale('D', ScaleType.wholeTone)).toSet(),
      notesOf(scale('C', ScaleType.wholeTone)).toSet(),
    );
    // The diminished scale starts tone then semitone, so it holds the minor third and
    // the flat fifth of a diminished chord and not the major third.
    final diminished = scale('C', ScaleType.diminished);
    expect(diminished.contains(PitchClass.parse('Eb')), isTrue);
    expect(diminished.contains(PitchClass.parse('Gb')), isTrue);
    expect(diminished.contains(PitchClass.parse('E')), isFalse);
    // And the chromatic scale holds everything, so nothing is ever outside it.
    final chromatic = scale('C', ScaleType.chromatic);
    for (var semitone = 0; semitone < 12; semitone++) {
      expect(chromatic.contains(PitchClass(semitone)), isTrue);
    }
  });

  test('a key is spelled the way a chart spells it', () {
    expect(scale('Eb', ScaleType.major).label, 'Eb major');
    expect(scale('C#', ScaleType.minor).label, 'C# minor');
    expect(scale('Db', ScaleType.major).prefersFlats, isTrue);
    expect(scale('C#', ScaleType.minor).prefersFlats, isFalse);
  });

  test('a scale of the same root and type is the same scale', () {
    expect(scale('F', ScaleType.dorian), scale('F', ScaleType.dorian));
    expect(scale('F', ScaleType.dorian), isNot(scale('F', ScaleType.minor)));
  });
}
