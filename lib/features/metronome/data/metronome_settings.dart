import '../../../core/enums/time_signature.dart';
import '../../../core/values/tempo_range.dart';

/// What the metronome is counting: how fast, in what, and how loud.
///
/// Held in memory and not written down. A tempo is set for the thing being played right
/// now, and an exercise that wants ninety in 4/4 says so itself - a remembered tempo
/// from yesterday would only be something to notice and change.
class MetronomeSettings {
  const MetronomeSettings({
    this.bpm = 90,
    this.signature = TimeSignature.fourFour,
    this.accentFirst = true,
    this.volume = 0.8,
  });

  /// Ninety, four four, first beat accented: a tempo somebody can play at straight
  /// away, in the meter most things are in.
  final int bpm;
  final TimeSignature signature;

  /// Whether the first beat of the bar is the strong one. Turned off for practising
  /// against a flat pulse, where the bar line is the player's job to feel.
  final bool accentFirst;

  /// Nought to one, as the player handed to the audio device.
  final double volume;

  MetronomeSettings copyWith({
    int? bpm,
    TimeSignature? signature,
    bool? accentFirst,
    double? volume,
  }) => MetronomeSettings(
    // Clamped here rather than by every caller: a dial being dragged and a tap tempo
    // being worked out both arrive with numbers that can be off the end.
    bpm: bpm == null ? this.bpm : clampBpm(bpm),
    signature: signature ?? this.signature,
    accentFirst: accentFirst ?? this.accentFirst,
    volume: volume == null ? this.volume : volume.clamp(0.0, 1.0),
  );

  /// How long one beat lasts, which is what the beat lights are timed off.
  Duration get beat => signature.clickInterval(bpm);
}
