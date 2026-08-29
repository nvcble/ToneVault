import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/core/music/chord.dart';
import 'package:tone_vault/core/music/nashville.dart';
import 'package:tone_vault/core/music/pitch_class.dart';
import 'package:tone_vault/core/music/scale.dart';
import 'package:tone_vault/core/music/scale_type.dart';

/// The Nashville Number System, read both ways.
void main() {
  final c = Scale(PitchClass.parse('C'), ScaleType.major);
  final a = Scale(PitchClass.parse('A'), ScaleType.minor);

  List<String> symbolsOf(List<Chord> chords) => [
    for (final chord in chords) chord.symbol,
  ];

  test('a bare number is the chord the key already has there', () {
    expect(nashvilleChord('1', c).symbol, 'C');
    expect(nashvilleChord('2', c).symbol, 'Dm');
    expect(nashvilleChord('7', c).symbol, 'Bdim');
  });

  test('a quality written after the number overrides the key', () {
    expect(nashvilleChord('27', c).symbol, 'D7');
    expect(nashvilleChord('6', c).symbol, 'Am');
    expect(nashvilleChord('4maj7', c).symbol, 'Fmaj7');
    expect(nashvilleChord('5sus4', c).symbol, 'Gsus4');
  });

  test('a flat or a sharp moves the root outside the key', () {
    // Nothing is there to inherit a quality from, so it is read as major - which is
    // what a chart means by a flat seven.
    expect(nashvilleChord('b7', c).symbol, 'Bb');
    expect(nashvilleChord('b3', c).symbol, 'Eb');
    expect(nashvilleChord('b77', c).symbol, 'Bb7');
  });

  test(
    'the same numbers in another key are another song in the same shape',
    () {
      expect(symbolsOf(nashvilleLine('1 5 6 4', c)), ['C', 'G', 'Am', 'F']);
      expect(symbolsOf(nashvilleLine('1 5 6 4', a)), ['Am', 'Em', 'F', 'Dm']);
    },
  );

  test('a line is read however a chart separates it', () {
    expect(symbolsOf(nashvilleLine('1-5-6m-4', c)), ['C', 'G', 'Am', 'F']);
    expect(symbolsOf(nashvilleLine('2m7 | 57 | 1maj7', c)), [
      'Dm7',
      'G7',
      'Cmaj7',
    ]);
  });

  test('a chord is written back as the number it is called by', () {
    expect(nashvilleNumber(Chord.parse('C'), c), '1');
    expect(nashvilleNumber(Chord.parse('Am'), c), '6');
    expect(nashvilleNumber(Chord.parse('G7'), c), '57');
    // A bare number would be read back as the minor chord the key has there, so a
    // major two says so.
    expect(nashvilleNumber(Chord.parse('D'), c), '2maj');
  });

  test('a chord from outside the key comes back with an accidental on it', () {
    // Eb in C is the flat third every chart writes, not the sharp second it also is.
    expect(nashvilleNumber(Chord.parse('Eb'), c), 'b3');
    expect(nashvilleNumber(Chord.parse('Bb7'), c), 'b77');
  });

  test('writing a chord down and reading it back gives the chord again', () {
    for (final written in ['C', 'Dm7', 'G7', 'Bb', 'Am', 'Fmaj7', 'D', 'Eb7']) {
      final chord = Chord.parse(written);
      expect(nashvilleChord(nashvilleNumber(chord, c), c), chord);
    }
  });

  test('something that is not a number in a key is refused', () {
    expect(() => nashvilleChord('9', c), throwsA(isA<AppFailure>()));
    expect(() => nashvilleChord('x', c), throwsA(isA<AppFailure>()));
    expect(
      () => nashvilleChord('1', Scale(PitchClass(0), ScaleType.blues)),
      throwsA(isA<AppFailure>()),
    );
  });
}
