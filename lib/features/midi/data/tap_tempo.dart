import '../../../core/values/tempo_range.dart';

/// Turns a run of taps into a tempo.
///
/// The average across the last [window] gaps rather than only the newest one:
/// nobody taps evenly, and following the latest gap alone makes the reading
/// jump about while the player is still settling into the pulse. A gap longer
/// than [restartAfter] starts a fresh count instead of reading as a very slow
/// tempo, which is also what stops the tap before a coffee break from
/// averaging into the one after it.
///
/// Pure Dart on purpose - what it does is arithmetic on timestamps, and that
/// is worth testing without a widget or a MIDI port in the way.
class TapTempo {
  TapTempo({this.window = 4, this.restartAfter = const Duration(seconds: 2)});

  /// How many gaps between taps are averaged - so [window] + 1 taps.
  final int window;

  final Duration restartAfter;

  final List<DateTime> _taps = [];

  /// The tempo the taps so far imply, clamped to what the app will count, or
  /// null until there are two taps to measure a gap between.
  int? get bpm {
    if (_taps.length < 2) {
      return null;
    }
    final span = _taps.last.difference(_taps.first).inMicroseconds;
    // Two taps the clock cannot separate say nothing about tempo.
    if (span <= 0) {
      return null;
    }
    final gaps = _taps.length - 1;
    return clampBpm(
      (gaps * 60 * Duration.microsecondsPerSecond / span).round(),
    );
  }

  /// Records a tap at [at] and returns [bpm] as it stands after it.
  int? tap(DateTime at) {
    if (_taps.isNotEmpty && at.difference(_taps.last) > restartAfter) {
      _taps.clear();
    }
    _taps.add(at);
    if (_taps.length > window + 1) {
      _taps.removeAt(0);
    }
    return bpm;
  }

  void reset() => _taps.clear();
}
