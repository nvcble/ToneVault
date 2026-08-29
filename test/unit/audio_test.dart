import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/audio/pitch_frequency.dart';
import 'package:tone_vault/core/audio/tone_synth.dart';
import 'package:tone_vault/core/audio/wav_writer.dart';
import 'package:tone_vault/core/music/chord.dart';
import 'package:tone_vault/core/music/pitch_class.dart';

/// The audio layer, which is pure arithmetic and can be checked without a speaker.
///
/// Everything the ear training plays comes through here, so a wrong octave or a
/// mangled header is a silent feature on a device and a failing test in this file.
void main() {
  group('pitches', () {
    test('concert pitch and the octaves around it', () {
      expect(frequencyOfMidi(concertAMidi), closeTo(concertA, 0.001));
      expect(frequencyOfMidi(concertAMidi + 12), closeTo(880, 0.001));
      expect(frequencyOfMidi(concertAMidi - 12), closeTo(220, 0.001));
    });

    test('middle C and the low open E are where MIDI says they are', () {
      expect(midiOf(PitchClass(0)), middleC);
      expect(midiOf(PitchClass(4), octave: 2), guitarLowE);
    });

    test('a note is found at or above where the search started', () {
      expect(midiAtOrAbove(PitchClass(0), guitarLowE), 48);
      // Already there, so it stays rather than jumping an octave.
      expect(midiAtOrAbove(PitchClass(4), guitarLowE), guitarLowE);
    });
  });

  group('voicings', () {
    test('a chord is stacked upwards from the bottom of the neck', () {
      expect(voicingOf(Chord.parse('C')), [48, 52, 55]);
    });

    test('a ninth sounds above the seventh rather than beside the root', () {
      final notes = voicingOf(Chord.parse('C9'));
      expect(notes.last - notes.first, greaterThan(12));
    });

    test('a slash chord puts its bass note underneath the rest', () {
      final notes = voicingOf(Chord.parse('C/E'));
      expect(notes.first, 28);
      expect(notes, [28, 48, 52, 55]);
    });

    test('the wanted note ends up on top, and the chord stays in register', () {
      final chord = Chord.parse('Cmaj7');

      // The seventh is already the highest note of the stack.
      expect(voicingTopped(chord, 11).last, 59);
      // The third, with everything that was above it dropped an octave.
      expect(voicingTopped(chord, 4), [43, 47, 48, 52]);
    });
  });

  group('wav files', () {
    test('the header says what the samples are', () {
      final bytes = wavOfSamples(const [0, 0, 0], sampleRate: 8000);
      final data = bytes.buffer.asByteData();

      expect(bytes.length, 44 + 6);
      expect(_ascii(bytes, 0, 4), 'RIFF');
      expect(_ascii(bytes, 8, 4), 'WAVE');
      expect(_ascii(bytes, 36, 4), 'data');
      expect(data.getUint32(24, Endian.little), 8000);
      expect(data.getUint16(22, Endian.little), 1);
      expect(data.getUint16(34, Endian.little), 16);
      expect(data.getUint32(40, Endian.little), 6);
    });

    test('a sample past full scale is clipped rather than wrapped', () {
      final data = wavOfSamples(const [2, -2]).buffer.asByteData();

      expect(data.getInt16(44, Endian.little), 32767);
      expect(data.getInt16(46, Endian.little), -32767);
    });
  });

  group('tones', () {
    test('a note is as long as it was asked to be', () {
      final bytes = wavOfChord(const [
        middleC,
      ], duration: const Duration(seconds: 1));

      expect(bytes.length, 44 + 2 * defaultSampleRate);
    });

    test('a strum is longer than the note, by the spread of the stroke', () {
      const duration = Duration(seconds: 1);
      final one = wavOfChord(const [48], duration: duration);
      final three = wavOfChord(const [48, 52, 55], duration: duration);

      expect(three.length - one.length, 2 * _samples(strumSpacing * 2));
    });

    test('a chord of six notes is no louder than one note', () {
      final peak = _peak(wavOfChord(const [40, 47, 52, 55, 59, 64]));

      // Normalised to just under full scale, so it cannot clip whatever is in it.
      expect(peak, closeTo(0.89 * 32767, 2));
    });

    test('bars are laid out one after another in a single file', () {
      final bytes = wavOfSequence(const [
        [60],
        [62],
      ], each: const Duration(seconds: 1));

      // Two seconds: the second bar starts where the first one began, a second on.
      expect(bytes.length, 44 + 2 * 2 * defaultSampleRate);
    });

    test('nothing to play is a file with no samples in it', () {
      expect(wavOfTones(const []).length, 44);
    });
  });
}

String _ascii(Uint8List bytes, int offset, int length) =>
    String.fromCharCodes(bytes.sublist(offset, offset + length));

int _samples(Duration duration) =>
    duration.inMicroseconds *
    defaultSampleRate ~/
    Duration.microsecondsPerSecond;

/// The loudest sample in a rendered file, as a sixteen-bit number.
int _peak(Uint8List bytes) {
  final data = bytes.buffer.asByteData();
  var peak = 0;
  for (var offset = 44; offset + 1 < bytes.length; offset += 2) {
    peak = max(peak, data.getInt16(offset, Endian.little).abs());
  }
  return peak;
}
