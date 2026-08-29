import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/music/pitch_class.dart';
import 'package:tone_vault/core/music/progression.dart';
import 'package:tone_vault/core/music/scale.dart';
import 'package:tone_vault/core/music/scale_type.dart';
import 'package:tone_vault/features/theory/data/key_facts.dart';
import 'package:tone_vault/features/theory/data/progression_chart.dart';

/// What the theory browser says about a key, worked out rather than tabulated.
///
/// The engine underneath is tested elsewhere; these are the two things the browser adds
/// to it - the facts about a key, and the named progressions read into one.
void main() {
  Scale key(String root, [ScaleType type = ScaleType.major]) =>
      Scale(PitchClass.parse(root), type);

  group('key facts', () {
    test('a key signature is counted round the circle, not looked up', () {
      expect(KeyFacts.of(key('C')).signature, 0);
      expect(KeyFacts.of(key('G')).signature, 1);
      expect(KeyFacts.of(key('D')).signature, 2);
      expect(KeyFacts.of(key('F')).signature, -1);
      expect(KeyFacts.of(key('Eb')).signature, -3);
    });

    test('and a minor key is counted by the major one it shares with', () {
      expect(KeyFacts.of(key('A', ScaleType.minor)).signature, 0);
      expect(KeyFacts.of(key('E', ScaleType.minor)).signature, 1);
    });

    test('the number is said in words, because a minus sign is not flats', () {
      expect(KeyFacts.of(key('C')).signatureLabel, 'No sharps or flats');
      expect(KeyFacts.of(key('G')).signatureLabel, '1 sharp');
      expect(KeyFacts.of(key('D')).signatureLabel, '2 sharps');
      expect(KeyFacts.of(key('F')).signatureLabel, '1 flat');
      expect(KeyFacts.of(key('Eb')).signatureLabel, '3 flats');
    });

    test('the relative key runs both ways', () {
      expect(KeyFacts.of(key('C')).relative, key('A', ScaleType.minor));
      expect(KeyFacts.of(key('A', ScaleType.minor)).relative, key('C'));
    });

    test('the neighbours are a fifth either way and the relative one', () {
      final facts = KeyFacts.of(key('C'));

      expect(facts.neighbours, [key('G'), key('F'), key('A', ScaleType.minor)]);
      // Next door is next door, and the far side of the circle is six steps away.
      expect(facts.distanceTo(key('G')), 1);
      expect(facts.distanceTo(key('F#')), 6);
    });
  });

  group('named progressions', () {
    test('are read in the key that was chosen', () {
      final charts = chartsIn(key('C'));
      final pop = charts.firstWhere((chart) => chart.name == 'Pop');

      expect(pop.symbols, 'C  G  Am  F');
      expect(pop.numbers, '1 5 6 4');
      expect(pop.numerals, 'I-V-vi-IV');
    });

    test('and spelled the way that key spells its notes', () {
      final charts = chartsIn(key('Eb'));
      final pop = charts.firstWhere((chart) => chart.name == 'Pop');

      // Ab, not G#: a chart in Eb is read by somebody who knows which key they are in.
      expect(pop.symbols, contains('Ab'));
      expect(pop.symbols, isNot(contains('#')));
    });

    test('a minor progression is read in the minor key of the same root', () {
      final andalusian = chartsIn(
        key('C'),
      ).firstWhere((chart) => chart.name == 'Andalusian');

      // Read in C major it would spell chords outside the key it lives in.
      expect(andalusian.key, key('C', ScaleType.minor));
      expect(andalusian.symbols, startsWith('Cm'));
    });

    test('a seventh keeps its quality in the number, not just the symbol', () {
      final blues = chartsIn(
        key('C'),
      ).firstWhere((chart) => chart.name == 'Twelve bar blues');

      expect(blues.numbers, startsWith('17'));
      expect(blues.symbols, startsWith('C7'));
    });

    test('and every one of them reads in all twenty-four keys', () {
      for (final type in const [ScaleType.major, ScaleType.minor]) {
        for (var semitone = 0; semitone < 12; semitone++) {
          final chosen = Scale(PitchClass(semitone), type);

          expect(
            chartsIn(chosen),
            hasLength(namedProgressions.length),
            reason: 'something is unreadable in ${chosen.label}',
          );
        }
      }
    });
  });
}
