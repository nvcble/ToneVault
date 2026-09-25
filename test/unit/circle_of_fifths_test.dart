import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/music/chord.dart';
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

  test('the twelve notes go round it clockwise from C', () {
    final wheel = circleNotes();

    expect(wheel, hasLength(12));
    expect(wheel.take(4), [
      PitchClass.parse('C'),
      PitchClass.parse('G'),
      PitchClass.parse('D'),
      PitchClass.parse('A'),
    ]);
    // Halfway round is as far from home as a key gets, which is the tritone.
    expect(wheel[6], PitchClass.parse('F#'));
  });

  group('the way round onto a chord', () {
    List<String> onto(String chord, {int steps = 3}) => [
      for (final each in circleOnto(Chord.parse(chord), steps: steps))
        each.symbol,
    ];

    test('is the progression every song is made of, in a major key', () {
      // vi-ii-V-I, worked out from the circle rather than written down as itself.
      expect(onto('C'), ['Am7', 'Dm7', 'G7', 'C']);
      expect(onto('G'), ['Em7', 'Am7', 'D7', 'G']);
    });

    test('and every change in it falls a fifth', () {
      final chords = circleOnto(Chord.parse('C'), steps: 5);

      for (var index = 1; index < chords.length; index++) {
        expect(
          fifthsFrom(chords[index].root, 1),
          chords[index - 1].root,
          reason: 'the change onto ${chords[index]} is not a fifth',
        );
      }
    });

    test('a minor chord is walked onto in its own key', () {
      // Bm7b5 and Em7 are A minor's own two chords on those steps. F# is not in the key
      // at all, so it arrives as the dominant seventh a player would actually play.
      expect(onto('Am'), ['F#7', 'Bm7b5', 'Em7', 'Am']);
    });

    test(
      'and the chord asked about is the one it lands on, as it was written',
      () {
        expect(circleOnto(Chord.parse('Cmaj7')).last, Chord.parse('Cmaj7'));
        expect(circleOnto(Chord.parse('C'), steps: 1), hasLength(2));
        expect(onto('C', steps: 1), ['G7', 'C']);
      },
    );
  });

  test('the distance round the circle is counted the short way', () {
    final c = PitchClass.parse('C');
    expect(fifthsBetween(c, c), 0);
    expect(fifthsBetween(c, PitchClass.parse('G')), 1);
    expect(fifthsBetween(c, PitchClass.parse('F')), 1);
    expect(fifthsBetween(c, PitchClass.parse('F#')), 6);
  });
}
