import 'dart:math';
import 'dart:typed_data';

import 'pitch_frequency.dart';
import 'wav_writer.dart';

/// The sound of a note, made up rather than recorded.
///
/// A string sample per note would be twelve times seven files to ship and would still
/// only cover the notes somebody remembered to record. Adding a few sine waves gets a
/// tone that is plainly a pitch, which is all the ear training needs: the question is
/// which chord was played, not which guitar played it.
///
/// The shape of a plucked note is what makes it recognisable - it starts at once and
/// falls away - so there is an attack of a few milliseconds and a decay across the
/// whole note, and the harmonics above the fundamental fall away faster than it does.
class ToneEvent {
  const ToneEvent({
    required this.midi,
    required this.start,
    this.duration = const Duration(milliseconds: 1600),
  });

  final int midi;

  /// When the note is struck, from the beginning of the sound.
  final Duration start;
  final Duration duration;
}

/// The amplitude of the fundamental and the harmonics above it. Three is enough to
/// stop it sounding like a test tone and few enough to render a progression quickly.
const List<double> _harmonics = [1, 0.4, 0.15];

/// How far apart the notes of a strummed chord are struck.
///
/// A chord played dead together sounds like an organ. Twenty-five milliseconds is
/// about a downstroke, and it also lets the ear hear the notes as separate pitches,
/// which is what it is being trained to do.
const Duration strumSpacing = Duration(milliseconds: 25);

/// A chord struck once, as a file ready to play.
Uint8List wavOfChord(
  List<int> midiNotes, {
  Duration duration = const Duration(milliseconds: 1600),
  Duration spacing = strumSpacing,
}) => wavOfTones([
  for (var index = 0; index < midiNotes.length; index++)
    ToneEvent(
      midi: midiNotes[index],
      start: spacing * index,
      duration: duration,
    ),
]);

/// Chords one after another, in one file.
///
/// One file rather than one a chord, because a progression is heard as its timing as
/// much as its chords, and asking a player to start four files in a row would put a
/// stumble between every one of them.
Uint8List wavOfSequence(
  List<List<int>> chords, {
  Duration each = const Duration(milliseconds: 1200),
}) => wavOfTones([
  for (var bar = 0; bar < chords.length; bar++)
    for (var index = 0; index < chords[bar].length; index++)
      ToneEvent(
        midi: chords[bar][index],
        start: each * bar + strumSpacing * index,
        duration: each,
      ),
]);

/// Renders notes to a WAV, summed where they overlap and then brought back under one.
Uint8List wavOfTones(
  List<ToneEvent> tones, {
  int sampleRate = defaultSampleRate,
}) {
  if (tones.isEmpty) {
    return wavOfSamples(const [], sampleRate: sampleRate);
  }

  final length = tones
      .map((tone) => _samples(tone.start + tone.duration, sampleRate))
      .reduce(max);
  final samples = Float64List(length);

  for (final tone in tones) {
    _render(samples, tone, sampleRate);
  }

  return wavOfSamples(_normalised(samples), sampleRate: sampleRate);
}

void _render(Float64List samples, ToneEvent tone, int sampleRate) {
  final frequency = frequencyOfMidi(tone.midi);
  final from = _samples(tone.start, sampleRate);
  final count = _samples(tone.duration, sampleRate);
  final attack = sampleRate ~/ 200; // Five milliseconds.

  for (var index = 0; index < count && from + index < samples.length; index++) {
    final seconds = index / sampleRate;
    final progress = index / count;
    // Struck, not faded in: the attack is short enough to be an edge and long
    // enough not to click.
    final envelope =
        (index < attack ? index / attack : 1.0) * exp(-3.5 * progress);

    var value = 0.0;
    for (var partial = 0; partial < _harmonics.length; partial++) {
      value +=
          _harmonics[partial] *
          exp(-partial * progress) *
          sin(2 * pi * frequency * (partial + 1) * seconds);
    }
    samples[from + index] += value * envelope;
  }
}

/// Brought to a peak just under full scale, so a chord of six notes is as loud as a
/// single note rather than six times past clipping.
List<double> _normalised(Float64List samples) {
  var peak = 0.0;
  for (final sample in samples) {
    peak = max(peak, sample.abs());
  }
  if (peak == 0) {
    return samples;
  }

  final gain = 0.89 / peak;
  return [for (final sample in samples) sample * gain];
}

int _samples(Duration duration, int sampleRate) =>
    duration.inMicroseconds * sampleRate ~/ Duration.microsecondsPerSecond;
