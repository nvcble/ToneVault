import '../../../core/values/tempo_range.dart';

/// A tempo taken from the player tapping it.
///
/// The gaps between the taps are averaged rather than the last one being taken, because
/// a hand is not exact and one late tap should nudge the tempo rather than set it. Four
/// gaps is enough to steady it and few enough that speeding up while tapping is
/// followed rather than argued with.
///
/// Tapping stops meaning anything if it is left too long, so a gap over [forgetAfter]
/// starts the count again instead of averaging in a pause.
class TapTempo {
  TapTempo({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  static const Duration forgetAfter = Duration(seconds: 2);

  /// How many gaps are averaged, which is one more tap than that.
  static const int remembered = 4;

  final DateTime Function() _clock;
  final List<DateTime> _taps = [];

  /// Records a tap and gives back the tempo it makes, or null where there is not one
  /// yet - the first tap of a run has no gap in front of it to measure.
  int? tap() {
    final now = _clock();
    if (_taps.isNotEmpty && now.difference(_taps.last) > forgetAfter) {
      _taps.clear();
    }

    _taps.add(now);
    if (_taps.length > remembered + 1) {
      _taps.removeAt(0);
    }
    if (_taps.length < 2) {
      return null;
    }

    final span = _taps.last.difference(_taps.first) ~/ (_taps.length - 1);
    if (span.inMicroseconds <= 0) {
      // Two taps the clock cannot tell apart. Nothing to divide by, and the fastest
      // tempo there is is the honest answer to being tapped that quickly.
      return maxBpm;
    }
    return clampBpm(
      (Duration.microsecondsPerMinute / span.inMicroseconds).round(),
    );
  }

  /// Forgotten deliberately, for when the screen is left or the tempo is set some
  /// other way and the half-finished run of taps would be wrong to carry on from.
  void reset() => _taps.clear();
}
