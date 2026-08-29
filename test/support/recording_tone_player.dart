import 'package:tone_vault/core/audio/tone_player.dart';
import 'package:tone_vault/core/errors/app_failure.dart';

/// A speaker a test can read back.
///
/// Records the notes it was asked for rather than sounding them, so a test can assert
/// that the chord on screen is the chord that was played without a sound device or a
/// plugin in the way. Set [failure] to stand for a device that cannot play at all.
class RecordingTonePlayer implements TonePlayer {
  RecordingTonePlayer({this.failure});

  AppFailure? failure;

  /// What was played, in the order it was asked for. A chord is one entry.
  final List<List<int>> played = <List<int>>[];

  int stops = 0;
  int disposals = 0;

  @override
  Future<void> playChord(List<int> midiNotes) => _record([midiNotes]);

  @override
  Future<void> playNotes(List<int> midiNotes) => _record([midiNotes]);

  @override
  Future<void> playSequence(List<List<int>> chords) => _record(chords);

  @override
  Future<void> stop() async => stops++;

  @override
  Future<void> dispose() async => disposals++;

  Future<void> _record(List<List<int>> bars) async {
    final refusal = failure;
    if (refusal != null) {
      throw refusal;
    }
    played.addAll(bars);
  }
}
