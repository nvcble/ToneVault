import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/music/caged.dart';
import 'package:tone_vault/core/music/chord.dart';
import 'package:tone_vault/core/music/chord_type.dart';
import 'package:tone_vault/core/music/chord_voicing.dart';
import 'package:tone_vault/core/music/pitch_class.dart';

/// The CAGED system, which is the shape library read in the order the shapes climb.
///
/// What is worth testing is the rotation: that the five shapes come back in the order they
/// sit on the neck for whatever root is asked about, because that order is the only thing
/// the system actually claims.
void main() {
  Chord chord(String root, [ChordType type = ChordType.major]) =>
      Chord(PitchClass.parse(root), type);

  /// Where each shape puts its root, which is the fact the order is sorted on.
  Map<String, int> frets(Chord asked) => {
    for (final voicing in cagedVoicings(asked)) voicing.name: voicing.rootFret,
  };

  test('a major chord has all five shapes, each where its root falls', () {
    expect(frets(chord('C')), {
      'C shape': 3,
      'A shape': 3,
      'G shape': 8,
      'E shape': 8,
      'D shape': 10,
    });
  });

  test('and the order rotates with the root rather than starting at C', () {
    // A is the classic worked example: A-G-E-D-C up the neck, the C shape landing at the
    // twelfth fret where the A shape started an octave below.
    expect(frets(chord('A')), {
      'A shape': 0,
      'G shape': 5,
      'E shape': 5,
      'D shape': 7,
      'C shape': 12,
    });

    final climbing = cagedVoicings(chord('A')).map((each) => each.rootFret);
    expect(climbing.toList(), [0, 5, 5, 7, 12]);
  });

  test('a quality held fewer ways says which shapes it has not got', () {
    expect(cagedVoicings(chord('C', ChordType.minor)).map((each) => each.name), [
      'A shape',
      'E shape',
      'D shape',
    ]);
    expect(cagedGaps(ChordType.minor), ['C shape', 'G shape']);
    expect(cagedGaps(ChordType.major), isEmpty);
  });

  test('every chord of the shape library is offered in CAGED order', () {
    for (final type in ChordType.values) {
      final voicings = cagedVoicings(chord('C', type));
      final frets = voicings.map((each) => each.rootFret).toList();

      expect(
        frets,
        orderedEquals([...frets]..sort()),
        reason: '${type.label} is out of neck order',
      );
      // A shape outside the five would be one a player cannot place by the word, so the
      // library is not allowed to grow one quietly.
      expect(
        voicings.length,
        voicingsFor(chord('C', type), fretboard: cagedNeck).length,
        reason: '${type.label} has a shape outside CAGED',
      );
    }
  });
}
