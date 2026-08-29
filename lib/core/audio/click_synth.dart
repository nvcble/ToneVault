import 'dart:math';
import 'dart:typed_data';

import '../enums/time_signature.dart';
import 'wav_writer.dart';

/// The metronome's click, and a whole bar of them.
///
/// A bar rather than a click is what gets rendered, because a bar can be looped. A
/// timer firing a click every so often drifts - Dart's timers are not a clock, and a
/// player hears a few milliseconds of wobble as sloppiness - where a looped file is
/// counted by the audio device and stays in time for as long as it is left running.
///
/// The accent is part of the file for the same reason. Which beat is the strong one is
/// what makes a bar of 3/4 sound like 3/4, and it has to land exactly on the beat.

/// The two pitches. High for the accent and low for the rest, far enough apart to be
/// told from each other over a guitar and neither of them near a note being played.
const double accentPitch = 2000;
const double beatPitch = 1000;

/// How long a click lasts. Short enough to be a tick rather than a note, and long
/// enough to carry at the bottom of the range where there is a lot of silence.
const Duration clickLength = Duration(milliseconds: 35);

/// One bar of clicks, as a file made to be played on a loop.
///
/// The bar is exactly as long as its beats, so the loop point falls on the downbeat
/// and the count carries over it without a gap or a stumble.
Uint8List wavOfBar({
  required TimeSignature signature,
  required int bpm,
  bool accentFirst = true,
  int sampleRate = defaultSampleRate,
}) {
  final interval = signature.clickInterval(bpm);
  final samples = Float64List(_samples(interval * signature.beats, sampleRate));

  for (var beat = 0; beat < signature.beats; beat++) {
    _click(
      samples,
      from: _samples(interval * beat, sampleRate),
      pitch: accentFirst && beat == 0 ? accentPitch : beatPitch,
      sampleRate: sampleRate,
    );
  }

  return wavOfSamples(samples, sampleRate: sampleRate);
}

/// One tick: a pitch that falls away almost at once, which is what makes it a click
/// rather than a beep.
void _click(
  Float64List samples, {
  required int from,
  required double pitch,
  required int sampleRate,
}) {
  final count = _samples(clickLength, sampleRate);

  for (var index = 0; index < count && from + index < samples.length; index++) {
    final seconds = index / sampleRate;
    samples[from + index] =
        0.9 * exp(-40 * index / count) * sin(2 * pi * pitch * seconds);
  }
}

int _samples(Duration duration, int sampleRate) =>
    duration.inMicroseconds * sampleRate ~/ Duration.microsecondsPerSecond;
