import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/music/chord_type.dart';
import 'package:tone_vault/core/music/pitch_class.dart';
import 'package:tone_vault/core/music/scale.dart';
import 'package:tone_vault/core/music/scale_type.dart';
import 'package:tone_vault/features/theory/data/scale_facts.dart';
import 'package:tone_vault/features/theory/data/scale_uses.dart';

/// What the browser says about a scale beyond its notes, checked as music.
///
/// The formula, the parent and the characteristic tone are all derived from twelve
/// semitones, and the point of deriving them is that they agree with what a teacher would
/// say. These are the sentences a teacher would say.
void main() {
  Scale scaleOf(String root, ScaleType type) =>
      Scale(PitchClass.parse(root), type);

  ScaleFacts factsOf(String root, ScaleType type) =>
      ScaleFacts.of(scaleOf(root, type));

  group('the formula', () {
    test('is the scale in every key at once', () {
      expect(ScaleType.minorPentatonic.formula, '1 b3 4 5 b7');
      expect(ScaleType.major.formula, '1 2 3 4 5 6 7');
      expect(ScaleType.blues.formula, '1 b3 4 b5 5 b7');
    });

    test('and the intervals are the same thing said in words', () {
      expect(ScaleType.minorPentatonic.intervalNames, [
        'root',
        'minor 3rd',
        'perfect 4th',
        'perfect 5th',
        'minor 7th',
      ]);
    });

    test('and every scale has both, however many notes it has', () {
      for (final type in ScaleType.values) {
        expect(type.formula.split(' '), hasLength(type.semitones.length));
        expect(type.intervalNames, hasLength(type.semitones.length));
      }
    });
  });

  group('where a scale comes from', () {
    test('a mode is its parent scale started somewhere else', () {
      expect(
        factsOf('D', ScaleType.dorian).parent,
        scaleOf('C', ScaleType.major),
      );
      expect(
        factsOf('E', ScaleType.phrygian).parent,
        scaleOf('C', ScaleType.major),
      );
      expect(
        factsOf('F', ScaleType.lydian).parent,
        scaleOf('C', ScaleType.major),
      );
      expect(
        factsOf('G', ScaleType.mixolydian).parent,
        scaleOf('C', ScaleType.major),
      );
      expect(
        factsOf('A', ScaleType.minor).parent,
        scaleOf('C', ScaleType.major),
      );
      expect(
        factsOf('B', ScaleType.locrian).parent,
        scaleOf('C', ScaleType.major),
      );
    });

    test('including the two modes of melodic minor', () {
      expect(
        factsOf('G', ScaleType.lydianDominant).parent,
        scaleOf('D', ScaleType.melodicMinor),
      );
      expect(
        factsOf('G', ScaleType.altered).parent,
        scaleOf('Ab', ScaleType.melodicMinor),
      );
    });

    test('and a parent has the notes of the scale it is parent to', () {
      for (final type in ScaleType.values) {
        final facts = factsOf('C', type);
        final parent = facts.parent;
        if (parent == null) {
          continue;
        }
        expect(
          facts.scale.notes.where((note) => !parent.contains(note)),
          isEmpty,
          reason: '${type.label} has notes ${parent.label} does not',
        );
      }
    });

    test('a pentatonic comes from a scale it does not have all of', () {
      final facts = factsOf('C', ScaleType.majorPentatonic);

      expect(facts.parent, scaleOf('C', ScaleType.major));
      expect(facts.isRotationOfParent, isFalse);
      expect(factsOf('D', ScaleType.dorian).isRotationOfParent, isTrue);
    });

    test('and the scales that are nobody\'s rotation come from nowhere', () {
      // The blues scale is here because it adds a note to the minor pentatonic rather
      // than taking notes out of anything, so nothing above it contains it.
      for (final type in const [
        ScaleType.major,
        ScaleType.blues,
        ScaleType.harmonicMinor,
        ScaleType.melodicMinor,
        ScaleType.wholeTone,
        ScaleType.diminished,
        ScaleType.chromatic,
      ]) {
        expect(factsOf('C', type).parent, isNull, reason: type.label);
      }
    });
  });

  group('the note a scale leans on', () {
    test('is named by its degree, not by the semitone it lands on', () {
      // Lydian's raised fourth is the whole scale. Called a flat five - which is the
      // same fret - it would be describing something else entirely.
      expect(factsOf('C', ScaleType.lydian).characteristicTones, ['#4']);
      expect(factsOf('C', ScaleType.mixolydian).characteristicTones, ['b7']);
      expect(factsOf('C', ScaleType.phrygian).characteristicTones, ['b2']);
      expect(factsOf('C', ScaleType.locrian).characteristicTones, ['b2', 'b5']);
      expect(factsOf('C', ScaleType.lydianDominant).characteristicTones, [
        '#4',
        'b7',
      ]);
    });

    test('and a degree put back where the major scale has it is natural', () {
      // "Natural 6" is what a Dorian player calls it. Nobody says sharp six.
      expect(factsOf('C', ScaleType.dorian).characteristicTones, ['natural 6']);
      expect(factsOf('C', ScaleType.harmonicMinor).characteristicTones, [
        'natural 7',
      ]);
    });

    test('the plain major and minor scales lean on nothing', () {
      expect(factsOf('C', ScaleType.major).characteristicTones, isEmpty);
      expect(factsOf('C', ScaleType.minor).characteristicTones, isEmpty);
    });

    test('and neither does a scale with no seven degrees to compare', () {
      for (final type in const [
        ScaleType.majorPentatonic,
        ScaleType.minorPentatonic,
        ScaleType.blues,
        ScaleType.wholeTone,
        ScaleType.diminished,
        ScaleType.chromatic,
      ]) {
        expect(
          factsOf('C', type).characteristicTones,
          isEmpty,
          reason: type.label,
        );
      }
    });
  });

  group('the chords a scale fits over', () {
    test('are the ones on its root whose notes it already has', () {
      final types = factsOf(
        'A',
        ScaleType.minorPentatonic,
      ).chords.map((chord) => chord.type).toSet();

      expect(types, contains(ChordType.minorSeventh));
      expect(types, contains(ChordType.minor));
      expect(types, contains(ChordType.sus4));
      expect(types, isNot(contains(ChordType.major)));
      // The ninth is not in the pentatonic, so a m11 is not a chord it covers.
      expect(types, isNot(contains(ChordType.minorEleventh)));
    });

    test('and are spelled the way the scale spells its own root', () {
      final chords = factsOf('Eb', ScaleType.major).chords.map(
        (chord) =>
            chord.spell(flats: scaleOf('Eb', ScaleType.major).prefersFlats),
      );

      expect(chords, contains('Ebmaj7'));
      expect(chords.where((symbol) => symbol.startsWith('D#')), isEmpty);
    });

    test('a symmetrical scale fits the chord it is built for', () {
      final wholeTone = factsOf(
        'C',
        ScaleType.wholeTone,
      ).chords.map((chord) => chord.type);
      final diminished = factsOf(
        'C',
        ScaleType.diminished,
      ).chords.map((chord) => chord.type);

      expect(wholeTone, contains(ChordType.dominantSeventhSharpFive));
      expect(wholeTone, isNot(contains(ChordType.major)));
      expect(diminished, contains(ChordType.diminishedSeventh));
    });

    test(
      'and the chromatic scale says nothing, because it fits everything',
      () {
        expect(factsOf('C', ScaleType.chromatic).chords, isEmpty);
      },
    );

    test('every note of every chord offered is in the scale', () {
      for (final type in ScaleType.values) {
        final facts = factsOf('F#', type);
        for (final chord in facts.chords) {
          expect(
            chord.notes.where((note) => !facts.scale.contains(note)),
            isEmpty,
            reason: '${chord.symbol} does not fit ${facts.scale.label}',
          );
        }
      }
    });
  });

  test('every scale says what it is for', () {
    for (final type in ScaleType.values) {
      expect(scaleUse(type), isNotEmpty, reason: type.label);
      expect(scaleUse(type).length, greaterThan(40), reason: type.label);
    }
  });
}
