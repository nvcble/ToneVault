import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/core/music/interval.dart';
import 'package:tone_vault/core/music/pitch_class.dart';

/// The twelve notes and the distances between them, which everything else is built on.
void main() {
  test('a note is read from how it is written', () {
    expect(PitchClass.parse('C').semitone, 0);
    expect(PitchClass.parse('F#').semitone, 6);
    expect(PitchClass.parse('Bb').semitone, 10);
  });

  test('the enharmonic spellings of one note are one note', () {
    expect(PitchClass.parse('C#'), PitchClass.parse('Db'));
    expect(PitchClass.parse('Cb'), PitchClass.parse('B'));
    expect(PitchClass.parse('A##'), PitchClass.parse('B'));
  });

  test('a note is spelled the way the caller asks for', () {
    expect(PitchClass(3).name(), 'D#');
    expect(PitchClass(3).name(flats: true), 'Eb');
  });

  test('something that is not a note name is refused', () {
    expect(() => PitchClass.parse('H'), throwsA(isA<AppFailure>()));
    expect(() => PitchClass.parse('Cx'), throwsA(isA<AppFailure>()));
    expect(() => PitchClass.parse(''), throwsA(isA<AppFailure>()));
  });

  test('transposing wraps round the octave in both directions', () {
    expect(PitchClass.parse('B').transpose(majorSecond).name(), 'C#');
    expect(PitchClass.parse('C').transpose(-minorSecond).name(), 'B');
    expect(PitchClass.parse('G').transpose(octave), PitchClass.parse('G'));
  });

  test('an interval is measured upwards, so it is not the same both ways', () {
    final c = PitchClass.parse('C');
    final a = PitchClass.parse('A');
    expect(c.intervalTo(a), majorSixth);
    expect(a.intervalTo(c), minorThird);
  });

  test('an interval is named the way a musician says it', () {
    expect(intervalLabel(perfectFifth), 'perfect 5th');
    expect(intervalLabel(octave), 'octave');
    expect(intervalLabel(majorNinth), 'octave and a major 2nd');
    expect(intervalLabel(24), '2 octaves');
    expect(intervalLabel(28), '2 octaves and a major 3rd');
  });

  test('an interval knows which degree it lands on', () {
    expect(intervalDegree(unison), 1);
    expect(intervalDegree(perfectFifth), 5);
    expect(intervalDegree(majorNinth), 9);
    expect(intervalDegree(thirteenth), 13);
  });
}
