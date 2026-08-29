import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/music/chord.dart';
import 'package:tone_vault/core/music/chord_type.dart';
import 'package:tone_vault/core/music/chord_voicing.dart';
import 'package:tone_vault/core/music/fretboard.dart';
import 'package:tone_vault/core/music/pitch_class.dart';

/// Shapes put on the neck: the chords a player already knows, arrived at by arithmetic.
///
/// The strongest thing that can be said for the shape library is that placing its shapes
/// gives back the chords everybody learns first without any of them being written down.
/// If the C shape at the third fret is not the open C chord, something in here is wrong.
void main() {
  ChordVoicing shapeOf(Chord chord, String name, {Fretboard? fretboard}) =>
      voicingsFor(
        chord,
        fretboard: fretboard ?? const Fretboard(),
      ).firstWhere((voicing) => voicing.name == name);

  List<int?> fretsOf(ChordVoicing voicing) => [
    for (var string = 0; string < voicing.stringCount; string++)
      voicing.fretOn(string),
  ];

  group('the open chords fall out of the shapes', () {
    test('the E shape at the nut is the open E', () {
      final voicing = shapeOf(Chord(PitchClass(4), ChordType.major), 'E shape');

      expect(voicing.rootFret, 0);
      expect(fretsOf(voicing), [0, 2, 2, 1, 0, 0]);
      expect(voicing.isOpen, isTrue);
    });

    test(
      'the A shape at the nut is the open A, and the low string is left out',
      () {
        final voicing = shapeOf(
          Chord(PitchClass(9), ChordType.major),
          'A shape',
        );

        expect(fretsOf(voicing), [null, 0, 2, 2, 2, 0]);
        expect(voicing.mutedStrings, [0]);
        expect(voicing.soundingStrings, [1, 2, 3, 4, 5]);
      },
    );

    test('the C shape at the third fret is the open C', () {
      final voicing = shapeOf(Chord(PitchClass(0), ChordType.major), 'C shape');

      // Three frets up, because the shape reaches three frets below its own root. That
      // is the whole reason the first chord anybody learns is not at the nut.
      expect(voicing.rootFret, 3);
      expect(fretsOf(voicing), [null, 3, 2, 0, 1, 0]);
    });

    test('the G shape at the third fret is the open G', () {
      final voicing = shapeOf(Chord(PitchClass(7), ChordType.major), 'G shape');

      expect(fretsOf(voicing), [3, 2, 0, 0, 0, 3]);
    });

    test('and the D shape at the nut is the open D', () {
      final voicing = shapeOf(Chord(PitchClass(2), ChordType.major), 'D shape');

      expect(fretsOf(voicing), [null, null, 0, 2, 3, 2]);
      expect(voicing.mutedStrings, [0, 1]);
    });
  });

  group('a shape moved', () {
    test('is the same fingering somewhere else on the neck', () {
      final barred = shapeOf(Chord(PitchClass(7), ChordType.major), 'E shape');

      // G, held as the E shape: the open E chord carried up three frets, which is what a
      // barre chord is and what makes one shape worth learning.
      expect(barred.rootFret, 3);
      expect(fretsOf(barred), [3, 5, 5, 4, 3, 3]);
      expect(barred.isOpen, isFalse);
    });

    test('and sounds the chord it was moved to', () {
      final voicing = shapeOf(Chord(PitchClass(5), ChordType.minor), 'A shape');

      // F minor: F, Ab, C and nothing else, whatever fret each of them is at.
      expect({for (final note in voicing.notes) note.note.semitone}, {5, 8, 0});
    });
  });

  group('what the hand has to do', () {
    test('an open string is held by no finger, whatever the shape says', () {
      final open = shapeOf(Chord(PitchClass(4), ChordType.major), 'E shape');
      final barred = shapeOf(Chord(PitchClass(7), ChordType.major), 'E shape');

      // The same shape, and the same entry in its fingering table. At the nut the index
      // finger has nothing to do; three frets up it is barring everything.
      expect(open.fingerOn(0), isNull);
      expect(barred.fingerOn(0), 1);
    });

    test('and the span is what the fingers have to cover', () {
      final barred = shapeOf(Chord(PitchClass(7), ChordType.major), 'E shape');
      final open = shapeOf(Chord(PitchClass(4), ChordType.major), 'E shape');

      // Frets 3 to 5 is a three-fret hand. The open shape holds only frets 1 and 2, so
      // the reach is two even though the shape is the same one.
      expect(barred.span, 3);
      expect(open.lowestHeldFret, 1);
      expect(open.span, 2);
    });
  });

  group('what is offered', () {
    test('is every shape that fits, low to high', () {
      final voicings = voicingsFor(Chord(PitchClass(0), ChordType.major));

      // C: the open C shape at 3, the A shape barred at 3, and the G and E shapes at 8.
      expect(voicings.map((voicing) => voicing.name), [
        'C shape',
        'A shape',
        'G shape',
        'E shape',
      ]);
      expect(voicings.map((voicing) => voicing.rootFret), [3, 3, 8, 8]);
    });

    test('and not one that runs off the end of the neck', () {
      final twelve = voicingsFor(Chord(PitchClass(0), ChordType.major));
      final longer = voicingsFor(
        Chord(PitchClass(0), ChordType.major),
        fretboard: const Fretboard(fretCount: 15),
      );

      // The D shape for C wants the thirteenth fret. On a neck drawn to the twelfth it is
      // left out rather than drawn off the edge.
      expect(twelve.map((voicing) => voicing.name), isNot(contains('D shape')));
      expect(longer.map((voicing) => voicing.name), contains('D shape'));
    });

    test('and every quality is offered something', () {
      // On A, where the root is at the nut on the fifth string and low on the sixth, so
      // nothing is squeezed off the end.
      for (final type in ChordType.values) {
        expect(
          voicingsFor(
            Chord(PitchClass(9), type),
            fretboard: const Fretboard(fretCount: 15),
          ),
          isNotEmpty,
          reason: 'nothing to hold for A${type.symbol}',
        );
      }
    });

    test('and a slash chord is voiced as the chord itself', () {
      final slash = voicingsFor(
        Chord(PitchClass(0), ChordType.major, bass: PitchClass(4)),
      );

      // C/E gets the shapes of C. Bending one into putting an E underneath would be
      // inventing a fingering, and a wrong fingering is worse than a plain one.
      expect(slash, isNotEmpty);
      expect(slash.first.chord.bass, PitchClass(4));
      expect(fretsOf(slash.first), [null, 3, 2, 0, 1, 0]);
    });
  });
}
