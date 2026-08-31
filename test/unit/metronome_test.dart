import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/audio/click_synth.dart';
import 'package:tone_vault/core/audio/wav_writer.dart';
import 'package:tone_vault/core/enums/time_signature.dart';
import 'package:tone_vault/core/values/tempo_range.dart';
import 'package:tone_vault/features/metronome/data/metronome_settings.dart';
import 'package:tone_vault/features/metronome/data/tap_tempo.dart';

/// The bars the metronome counts with, and the tempo a player taps into them.
///
/// Both are arithmetic: the file is as long as the bar it counts, and a tap tempo is
/// the gaps between taps. A clock is handed in so a test can tap at exactly ninety.
void main() {
  group('a bar of clicks', () {
    test('is exactly as long as its beats, so the count stays in time', () {
      final bytes = wavOfBars(signature: TimeSignature.fourFour, bpm: 120);

      // Four beats of half a second, at two bytes a sample.
      expect(bytes.length, 44 + 2 * 2 * defaultSampleRate);
    });

    test('counts a compound signature in the unit it is written in', () {
      final six = wavOfBars(signature: TimeSignature.sixEight, bpm: 120);
      final three = wavOfBars(signature: TimeSignature.threeFour, bpm: 120);

      // Six eighth-note clicks, not two dotted-quarter ones: twice the bar of three.
      expect(_clicks(six, TimeSignature.sixEight.beats), 6);
      expect(six.length - 44, 2 * (three.length - 44));
    });

    test('accents the first beat, and only that one', () {
      final bytes = wavOfBars(signature: TimeSignature.fourFour, bpm: 120);
      final peaks = _peaks(bytes, TimeSignature.fourFour.beats);

      expect(peaks, hasLength(4));
      expect(peaks.first, greaterThan(0));
      // The accent is a different pitch rather than a different volume, so what says
      // it is there is that the click is not the same shape as the others.
      expect(peaks.skip(1).toSet(), hasLength(1));
      expect(peaks.first, isNot(peaks[1]));
    });

    test('and leaves them all the same when it is turned off', () {
      final bytes = wavOfBars(
        signature: TimeSignature.fourFour,
        bpm: 120,
        accentFirst: false,
      );

      expect(_peaks(bytes, TimeSignature.fourFour.beats).toSet(), hasLength(1));
    });

    test('has a click on every beat at both ends of the range', () {
      for (final bpm in const [minBpm, maxBpm]) {
        for (final signature in TimeSignature.values) {
          final bytes = wavOfBars(signature: signature, bpm: bpm);

          expect(
            _clicks(bytes, signature.beats),
            signature.beats,
            reason: '${signature.label} at $bpm',
          );
        }
      }
    });

    test('and a stretch of bars is that bar over again, accent and all', () {
      const signature = TimeSignature.threeFour;
      const bars = 3;
      final one = wavOfBars(signature: signature, bpm: 120);
      final stretch = wavOfBars(signature: signature, bpm: 120, bars: bars);
      final beats = signature.beats * bars;

      expect(stretch.length - 44, bars * (one.length - 44));
      expect(_clicks(stretch, beats), beats);

      // Each bar's downbeat is the accented one, so a stretch that is started again
      // does not move the accent off the beat it belongs on.
      final peaks = _peaks(stretch, beats);
      expect({peaks[0], peaks[3], peaks[6]}, hasLength(1));
      expect(peaks[0], isNot(peaks[1]));
    });
  });

  group('settings', () {
    test('a tempo off the end of the range is brought back inside it', () {
      const settings = MetronomeSettings();

      expect(settings.copyWith(bpm: 5).bpm, minBpm);
      expect(settings.copyWith(bpm: 5000).bpm, maxBpm);
      expect(settings.copyWith(volume: 2).volume, 1);
      expect(settings.copyWith(volume: -1).volume, 0);
    });

    test('and everything else is left as it was', () {
      const settings = MetronomeSettings();
      final faster = settings.copyWith(bpm: 140);

      expect(faster.signature, settings.signature);
      expect(faster.accentFirst, settings.accentFirst);
      expect(faster.volume, settings.volume);
    });

    test('a beat is as long as the tempo says', () {
      const settings = MetronomeSettings(bpm: 120);

      expect(settings.beat, const Duration(milliseconds: 500));
    });
  });

  group('tap tempo', () {
    late DateTime now;
    late TapTempo taps;

    setUp(() {
      now = DateTime(2026);
      taps = TapTempo(clock: () => now);
    });

    /// A tap [after] the one before it.
    int? tapAfter(Duration after) {
      now = now.add(after);
      return taps.tap();
    }

    test('says nothing on the first tap, because there is no gap yet', () {
      expect(taps.tap(), isNull);
    });

    test('takes the tempo from the gap between two taps', () {
      taps.tap();

      expect(tapAfter(const Duration(milliseconds: 500)), 120);
    });

    test('averages the gaps rather than taking the last one', () {
      taps.tap();
      tapAfter(const Duration(milliseconds: 500));
      tapAfter(const Duration(milliseconds: 500));

      // One late tap nudges the tempo instead of setting it.
      expect(tapAfter(const Duration(milliseconds: 620)), 111);
    });

    test('forgets a run that was left too long', () {
      taps.tap();
      tapAfter(const Duration(milliseconds: 500));

      expect(tapAfter(const Duration(seconds: 5)), isNull);
      // Counting from the tap that started again, not from the pause.
      expect(tapAfter(const Duration(milliseconds: 400)), 150);
    });

    test(
      'follows a player speeding up rather than averaging the whole run',
      () {
        taps.tap();
        for (var count = 0; count < 8; count++) {
          tapAfter(const Duration(seconds: 1));
        }

        for (var count = 0; count < 4; count++) {
          tapAfter(const Duration(milliseconds: 500));
        }
        // The slow taps have dropped out of the average altogether.
        expect(tapAfter(const Duration(milliseconds: 500)), 120);
      },
    );

    test('a tempo faster than the app counts is held at the top', () {
      taps.tap();

      expect(tapAfter(const Duration(milliseconds: 50)), maxBpm);
    });

    test('and being reset starts the run again', () {
      taps.tap();
      taps.reset();

      expect(tapAfter(const Duration(milliseconds: 500)), isNull);
    });
  });
}

/// How many of the [beats] have a click on them.
int _clicks(Uint8List bytes, int beats) =>
    _peaks(bytes, beats).where((peak) => peak > 1000).length;

/// The loudest sample of each beat, which is what its click is heard as.
///
/// The file is exactly its beats long, so a beat is one equal slice of it - and a beat
/// whose slice is silent had no click on it.
List<int> _peaks(Uint8List bytes, int beats) {
  final data = bytes.buffer.asByteData();
  final each = ((bytes.length - 44) ~/ 2) ~/ beats;

  return [
    for (var beat = 0; beat < beats; beat++)
      [
        for (var index = 0; index < each; index++)
          data.getInt16(44 + (beat * each + index) * 2, Endian.little).abs(),
      ].reduce((a, b) => a > b ? a : b),
  ];
}
