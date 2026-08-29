import 'package:tone_vault/core/audio/metronome.dart';
import 'package:tone_vault/core/enums/time_signature.dart';
import 'package:tone_vault/core/errors/app_failure.dart';

/// One bar the metronome was asked to count.
class CountedBar {
  const CountedBar({
    required this.signature,
    required this.bpm,
    required this.accentFirst,
    required this.volume,
  });

  final TimeSignature signature;
  final int bpm;
  final bool accentFirst;
  final double volume;

  @override
  String toString() =>
      '${signature.label} at $bpm'
      '${accentFirst ? ' accented' : ''} at ${volume.toStringAsFixed(2)}';
}

/// A metronome a test can read back rather than hear.
///
/// Records every bar it was told to count, in order, which is what says whether a
/// change of tempo reached the sound or only the screen. Set [failure] to stand for a
/// device that will not play.
class RecordingMetronome implements Metronome {
  RecordingMetronome({this.failure});

  AppFailure? failure;

  final List<CountedBar> counted = <CountedBar>[];
  final List<double> volumes = <double>[];

  int stops = 0;
  int disposals = 0;

  CountedBar? get last => counted.isEmpty ? null : counted.last;

  @override
  Future<void> start({
    required TimeSignature signature,
    required int bpm,
    required bool accentFirst,
    required double volume,
  }) async {
    final refusal = failure;
    if (refusal != null) {
      throw refusal;
    }
    counted.add(
      CountedBar(
        signature: signature,
        bpm: bpm,
        accentFirst: accentFirst,
        volume: volume,
      ),
    );
  }

  @override
  Future<void> stop() async => stops++;

  @override
  Future<void> setVolume(double volume) async => volumes.add(volume);

  @override
  Future<void> dispose() async => disposals++;
}
