import '../enums/time_signature.dart';

/// Something that can keep time.
///
/// An interface for the same reason the tone player is one: the screen decides what the
/// tempo is and a test reads back what it was asked to count, without a sound device or
/// a real second passing.
///
/// [start] is also how a change of tempo, signature or accent is made - it replaces
/// whatever is counting rather than adding to it, so there is no way to end up with two
/// bars running over each other.
abstract interface class Metronome {
  Future<void> start({
    required TimeSignature signature,
    required int bpm,
    required bool accentFirst,
    required double volume,
  });

  Future<void> stop();

  /// Changed on its own, without restarting the count, so dragging the volume does
  /// not put the beat back to the top of the bar.
  Future<void> setVolume(double volume);

  Future<void> dispose();
}
