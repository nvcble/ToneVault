import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/music/circle_of_fifths.dart';
import 'package:tone_vault/core/music/pitch_class.dart';
import 'package:tone_vault/core/music/scale.dart';
import 'package:tone_vault/core/music/scale_type.dart';

/// Key relationships, counted round the circle rather than tabulated.
void main() {
  Scale major(String root) => Scale(PitchClass.parse(root), ScaleType.major);
  Scale minor(String root) => Scale(PitchClass.parse(root), ScaleType.minor);

  test('a fifth up and a fifth down are where they should be', () {
    expect(fifthsFrom(PitchClass.parse('C'), 1), PitchClass.parse('G'));
    expect(fifthsFrom(PitchClass.parse('C'), -1), PitchClass.parse('F'));
    expect(fifthsFrom(PitchClass.parse('C'), 12), PitchClass.parse('C'));
  });

  test('a key signature is counted, not looked up', () {
    expect(keySignature(major('C')), 0);
    expect(keySignature(major('G')), 1);
    expect(keySignature(major('D')), 2);
    expect(keySignature(major('F')), -1);
    expect(keySignature(major('Eb')), -3);
  });

  test('a minor key is written with its relative major key signature', () {
    expect(keySignature(minor('A')), 0);
    expect(keySignature(minor('E')), 1);
    expect(keySignature(minor('D')), -1);
  });

  test('the relative keys are the ones that share a key signature', () {
    expect(relativeMinor(major('C')), minor('A'));
    expect(relativeMajor(minor('A')), major('C'));
    expect(keySignature(relativeMinor(major('Eb'))), keySignature(major('Eb')));
  });

  test('the keys next door share all but one note', () {
    for (final neighbour in neighbourKeys(major('C'))) {
      final shared = neighbour.notes.where(major('C').contains).length;
      expect(shared, greaterThanOrEqualTo(6));
    }
    expect(neighbourKeys(major('C')), contains(minor('A')));
    expect(neighbourKeys(minor('A')), contains(major('C')));
  });

  test('the cycle of fourths passes every key once', () {
    final cycle = cycleOfFourths(ScaleType.major);
    expect(cycle.length, 12);
    expect(cycle.map((scale) => scale.root).toSet().length, 12);
    // C, F, Bb, Eb: the order chord progressions actually move in.
    expect(cycle.take(3).map((scale) => scale.root.name(flats: true)), [
      'C',
      'F',
      'Bb',
    ]);
  });

  test('the distance round the circle is counted the short way', () {
    final c = PitchClass.parse('C');
    expect(fifthsBetween(c, c), 0);
    expect(fifthsBetween(c, PitchClass.parse('G')), 1);
    expect(fifthsBetween(c, PitchClass.parse('F')), 1);
    expect(fifthsBetween(c, PitchClass.parse('F#')), 6);
  });
}
