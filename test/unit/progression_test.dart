import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/core/music/chord.dart';
import 'package:tone_vault/core/music/pitch_class.dart';
import 'package:tone_vault/core/music/progression.dart';
import 'package:tone_vault/core/music/scale.dart';
import 'package:tone_vault/core/music/scale_type.dart';

/// Progressions written in roman numerals, resolved into chords in a key.
void main() {
  final c = Scale(PitchClass.parse('C'), ScaleType.major);
  final a = Scale(PitchClass.parse('A'), ScaleType.minor);

  List<String> symbolsOf(List<Chord> chords) => [
    for (final chord in chords) chord.symbol,
  ];

  test('case says major or minor where nothing else does', () {
    expect(romanChord('I', c).symbol, 'C');
    expect(romanChord('vi', c).symbol, 'Am');
    expect(romanChord('IV', c).symbol, 'F');
    expect(romanChord('iv', c).symbol, 'Fm');
  });

  test('what is written after the numeral is read as a chord symbol', () {
    expect(romanChord('V7', c).symbol, 'G7');
    expect(romanChord('Imaj7', c).symbol, 'Cmaj7');
    // A lower-case numeral has already said minor, so an extension need not repeat it.
    expect(romanChord('ii7', c).symbol, 'Dm7');
    expect(romanChord('iim7', c).symbol, 'Dm7');
    expect(romanChord('imaj7', c).symbol, 'CmMaj7');
  });

  test('the marked qualities are read the way theory writes them', () {
    expect(romanChord('vii°', c).symbol, 'Bdim');
    expect(romanChord('vii°7', c).symbol, 'Bdim7');
    expect(romanChord('iiø7', c).symbol, 'Dm7b5');
    expect(romanChord('III+', c).symbol, 'Eaug');
  });

  test('an accidental in front moves the root out of the key', () {
    expect(romanChord('bVII', c).symbol, 'Bb');
    expect(romanChord('bIII', c).symbol, 'Eb');
    expect(romanChord('#IV', c).symbol, 'F#');
  });

  test('a whole progression is read however it was separated', () {
    expect(symbolsOf(romanProgression('I-V-vi-IV', c)), ['C', 'G', 'Am', 'F']);
    expect(symbolsOf(romanProgression('ii V I', c)), ['Dm', 'G', 'C']);
    expect(symbolsOf(romanProgression('I | IV | V7 | I', c)), [
      'C',
      'F',
      'G7',
      'C',
    ]);
  });

  test('numerals are read against whichever key they are given', () {
    expect(symbolsOf(romanProgression('I-IV-V', c)), ['C', 'F', 'G']);
    expect(symbolsOf(romanProgression('i-iv-v', a)), ['Am', 'Dm', 'Em']);
    // In a minor key the seventh degree is already flat, so `VII` is the G a chart
    // means and `bVII` would be a semitone below it.
    expect(romanChord('VII', a).symbol, 'G');
  });

  test('the named progressions all resolve in a major and a minor key', () {
    for (final written in namedProgressions.values) {
      expect(romanProgression(written, c), isNotEmpty);
      expect(romanProgression(written, a), isNotEmpty);
    }
  });

  test('the ones players know by name are the chords they know them as', () {
    expect(symbolsOf(romanProgression(namedProgressions['Pop']!, c)), [
      'C',
      'G',
      'Am',
      'F',
    ]);
    expect(symbolsOf(romanProgression(namedProgressions['Two five one']!, c)), [
      'Dm',
      'G',
      'C',
    ]);
    expect(symbolsOf(romanProgression(namedProgressions['Andalusian']!, a)), [
      'Am',
      'G',
      'F',
      'E',
    ]);
    expect(symbolsOf(romanProgression(namedProgressions['Backdoor']!, c)), [
      'F',
      'Bb7',
      'C',
    ]);
  });

  test('something that is not a numeral is refused', () {
    expect(() => romanChord('VIII', c), throwsA(isA<AppFailure>()));
    expect(() => romanChord('nine', c), throwsA(isA<AppFailure>()));
    expect(
      () => romanChord('I', Scale(PitchClass(0), ScaleType.minorPentatonic)),
      throwsA(isA<AppFailure>()),
    );
  });
}
