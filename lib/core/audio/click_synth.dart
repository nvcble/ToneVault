import 'dart:math';
import 'dart:typed_data';

import '../enums/time_signature.dart';
import 'wav_writer.dart';

/// The metronome's click, and the bars it is heard in.
///
/// Bars rather than a click are what gets rendered, because the spacing of clicks inside
/// a file is counted by the audio device and cannot slip. A timer firing a click every
/// so often drifts - Dart's timers are not a clock, and a player hears a few
/// milliseconds of wobble as sloppiness - so the fewer moments the app has to get right,
/// the better, and a file of many bars has only one of them: its start.
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

/// [bars] bars of clicks, as one file made to be started and left to run.
///
/// It is exactly as long as the beats in it, so the last beat gets its whole beat of
/// silence and the file that follows begins on the downbeat.
Uint8List wavOfBars({
  required TimeSignature signature,
  required int bpm,
  bool accentFirst = true,
  int bars = 1,
  int sampleRate = defaultSampleRate,
}) {
  final interval = signature.clickInterval(bpm);
  final beats = signature.beats * bars;
  final samples = Float64List(_samples(interval * beats, sampleRate));

  for (var beat = 0; beat < beats; beat++) {
    _click(
      samples,
      // Where the beat falls counted from the top of the file rather than from the
      // click before it, so a tempo that is not a whole number of samples long cannot
      // round its way out of time across the bars.
      from: _samples(interval * beat, sampleRate),
      pitch:
          accentFirst && beat % signature.beats == 0 ? accentPitch : beatPitch,
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
