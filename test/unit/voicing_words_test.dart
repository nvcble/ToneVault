import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/music/chord.dart';
import 'package:tone_vault/core/music/chord_type.dart';
import 'package:tone_vault/core/music/chord_voicing.dart';
import 'package:tone_vault/core/music/pitch_class.dart';
import 'package:tone_vault/features/theory/data/voicing_words.dart';

/// A chord box in words, which is the version a player can check themselves against.
void main() {
  ChordVoicing shapeOf(PitchClass root, ChordType type, String name) =>
      voicingsFor(Chord(root, type)).firstWhere((found) => found.name == name);

  test('a string is named the way a player names it, from the treble down', () {
    // The engine counts up from the bass and a guitarist counts down from the treble,
    // and every sentence the app writes has to be in the player's order.
    expect(stringName(0), '6th string');
    expect(stringName(5), '1st string');
  });

  test('a finger is named rather than numbered', () {
    expect(fingerName(1), 'index');
    expect(fingerName(4), 'little');
  });

  test('an open chord is written out string by string', () {
    final open = shapeOf(PitchClass(9), ChordType.major, 'A shape');

    expect(voicingWords(open), [
      '6th string: not played',
      '5th string: open, A',
      '4th string: 2nd fret, E, ring finger',
      '3rd string: 2nd fret, A, ring finger',
      '2nd string: 2nd fret, C#, ring finger',
      '1st string: open, E',
    ]);
  });

  test('and a barre chord says which fret the hand has moved to', () {
    final barred = shapeOf(PitchClass(7), ChordType.major, 'E shape');

    expect(voicingWords(barred).first, '6th string: 3rd fret, G, index finger');
    expect(voicingWords(barred).last, '1st string: 3rd fret, G, index finger');
  });

  test('where the shape sits and how far it reaches', () {
    expect(
      voicingPlace(shapeOf(PitchClass(4), ChordType.major, 'E shape')),
      'Open, 2 frets under the hand',
    );
    expect(
      voicingPlace(shapeOf(PitchClass(7), ChordType.major, 'E shape')),
      'From the 3rd fret, 3 frets under the hand',
    );
  });

  test('and the counting reads properly past ten', () {
    expect(ordinal(1), '1st');
    expect(ordinal(2), '2nd');
    expect(ordinal(3), '3rd');
    expect(ordinal(4), '4th');
    expect(ordinal(11), '11th');
    expect(ordinal(12), '12th');
    expect(ordinal(21), '21st');
  });
}
