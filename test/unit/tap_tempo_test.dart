import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/values/tempo_range.dart';
import 'package:tone_vault/features/midi/data/tap_tempo.dart';

void main() {
  final start = DateTime(2026, 1, 1, 12);

  /// Taps [gaps] evenly spaced [gap] apart, starting at [start].
  int? tapEvenly(TapTempo tapTempo, Duration gap, int gaps) {
    int? bpm;
    for (var index = 0; index <= gaps; index++) {
      bpm = tapTempo.tap(start.add(gap * index));
    }
    return bpm;
  }

  group('TapTempo', () {
    test('says nothing from one tap, having no interval to measure', () {
      final tapTempo = TapTempo();

      expect(tapTempo.tap(start), isNull);
      expect(tapTempo.bpm, isNull);
    });

    test('two taps half a second apart read as 120 BPM', () {
      final tapTempo = TapTempo();

      tapTempo.tap(start);

      expect(tapTempo.tap(start.add(const Duration(milliseconds: 500))), 120);
    });

    test('averages uneven taps rather than following the latest gap', () {
      final tapTempo = TapTempo();

      // Four taps: 500ms, 400ms, 600ms. The last gap alone would say 100 BPM.
      tapTempo.tap(start);
      tapTempo.tap(start.add(const Duration(milliseconds: 500)));
      tapTempo.tap(start.add(const Duration(milliseconds: 900)));

      expect(tapTempo.tap(start.add(const Duration(milliseconds: 1500))), 120);
    });

    test('keeps only the last window of gaps, so a tempo can be changed', () {
      final tapTempo = TapTempo(window: 2);

      expect(
        tapEvenly(tapTempo, const Duration(milliseconds: 500), 2),
        120,
      );
      // Keeping the count means a new tempo arrives gradually - the old gaps
      // are still being averaged in until enough new ones push them out.
      expect(tapTempo.tap(start.add(const Duration(milliseconds: 1500))), 120);
      expect(tapTempo.tap(start.add(const Duration(milliseconds: 2500))), 80);
      // Two gaps at a second each, and nothing faster left in the window.
      expect(tapTempo.tap(start.add(const Duration(milliseconds: 3500))), 60);
    });

    test('a long pause starts a fresh count instead of a very slow tempo', () {
      final tapTempo = TapTempo();

      tapTempo.tap(start);
      final afterPause = tapTempo.tap(start.add(const Duration(seconds: 10)));

      expect(afterPause, isNull);
    });

    test('clamps to a tempo the app will actually count', () {
      final tapTempo = TapTempo();

      // 10ms apart is 6000 BPM; nothing playable is above [maxBpm].
      expect(tapEvenly(tapTempo, const Duration(milliseconds: 10), 4), maxBpm);
    });

    test('two taps the clock cannot separate say nothing', () {
      final tapTempo = TapTempo();

      tapTempo.tap(start);

      expect(tapTempo.tap(start), isNull);
    });

    test('reset drops the count so far', () {
      final tapTempo = TapTempo();

      tapEvenly(tapTempo, const Duration(milliseconds: 500), 3);
      tapTempo.reset();

      expect(tapTempo.bpm, isNull);
    });
  });
}
