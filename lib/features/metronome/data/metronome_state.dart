import 'metronome_settings.dart';

/// The metronome as it stands: what it is set to, whether it is counting, and anything
/// that went wrong the last time it was asked to.
class MetronomeState {
  const MetronomeState({
    this.settings = const MetronomeSettings(),
    this.playing = false,
    this.failure,
  });

  final MetronomeSettings settings;
  final bool playing;

  /// What the sound device refused with, where it did. Null on every other state, so
  /// a screen listening for it hears about each failure once.
  final Object? failure;
}
