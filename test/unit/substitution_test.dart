import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/music/chord.dart';
import 'package:tone_vault/core/music/pitch_class.dart';
import 'package:tone_vault/core/music/scale.dart';
import 'package:tone_vault/core/music/scale_type.dart';
import 'package:tone_vault/core/music/substitution.dart';

/// Substitutions, worked out from what a chord is rather than looked up.
void main() {
  final c = Scale(PitchClass.parse('C'), ScaleType.major);

  List<String> symbolsFor(String written, [Scale? key]) => [
    for (final substitution in substitutionsFor(Chord.parse(written), key ?? c))
      substitution.chord.symbol,
  ];

  test('a dominant is offered its tritone substitute', () {
    expect(symbolsFor('G7'), contains('Db7'));
    expect(symbolsFor('D7'), contains('Ab7'));
  });

  test(
    'the tritone substitute of the tritone substitute is where it started',
    () {
      final g7 = Chord.parse('G7');
      expect(tritoneSubstituteOf(tritoneSubstituteOf(g7)), g7);
    },
  );

  test('a dominant is offered itself, altered', () {
    expect(symbolsFor('G7'), contains('G7#9'));
  });

  test('anything that is not a dominant is offered one that leads to it', () {
    expect(symbolsFor('Dm7'), contains('A7'));
    expect(dominantOf(PitchClass.parse('D')), Chord.parse('A7'));
  });

  test('the tonic is offered its relative minor and the backdoor dominant', () {
    expect(symbolsFor('C'), containsAll(['Am', 'Bb7']));
  });

  test(
    'the four chord is offered the minor four borrowed from the parallel key',
    () {
      expect(symbolsFor('F'), contains('Fm'));
    },
  );

  test('the five chord is offered a suspended dominant', () {
    expect(symbolsFor('G7'), contains('G7sus4'));
  });

  test('a chord that is not the tonic is offered a diminished approach to it', () {
    // A diminished seventh a semitone below moves every voice by a semitone into the
    // chord after it, which is why it turns up in front of anything. Compared as
    // chords rather than as symbols, because a chord left to spell itself calls this
    // one Dbdim7 and a chart reading it in C major calls it C#dim7.
    expect([
      for (final one in substitutionsFor(Chord.parse('Dm7'), c)) one.chord,
    ], contains(Chord.parse('C#dim7')));
    expect(symbolsFor('C'), isNot(contains('Bdim7')));
  });

  test('every substitution says why, because that is what is being taught', () {
    final substitutions = substitutionsFor(Chord.parse('G7'), c);
    expect(substitutions, isNotEmpty);
    for (final substitution in substitutions) {
      expect(substitution.reason, isNotEmpty);
      expect(substitution.toString(), contains(substitution.chord.symbol));
    }
  });

  test('the same reasoning applies in a key it was never written for', () {
    // Nothing here is tabulated per key, so Eb has to work as well as C does.
    final eb = Scale(PitchClass.parse('Eb'), ScaleType.major);
    expect(symbolsFor('Bb7', eb), contains('E7'));
    expect(symbolsFor('Eb', eb), containsAll(['Cm', 'Db7']));
  });

  test('a chord borrowed from outside the key still gets what it can', () {
    // No degree, so no degree-specific advice - and no crash either.
    final substitutions = substitutionsFor(Chord.parse('Ab7'), c);
    expect([for (final one in substitutions) one.chord.symbol], contains('D7'));
  });
}
