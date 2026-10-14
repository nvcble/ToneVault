import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/midi_clock_timing.dart';

void main() {
  group('midiClockPulsesPerQuarterNote', () {
    test('is the 24 the MIDI specification fixes', () {
      expect(midiClockPulsesPerQuarterNote, 24);
    });
  });

  group('midiClockPulseInterval', () {
    test('matches the published figures for the usual tempos', () {
      // The four rows of the brief's own table, to the microsecond.
      expect(midiClockPulseInterval(60), const Duration(microseconds: 41667));
      expect(midiClockPulseInterval(90), const Duration(microseconds: 27778));
      expect(midiClockPulseInterval(120), const Duration(microseconds: 20833));
      expect(midiClockPulseInterval(140), const Duration(microseconds: 17857));
    });

    test('keeps the fraction a millisecond would throw away', () {
      // 20.8333 ms, not 21 ms: rounded up to whole milliseconds a 120 BPM
      // stream would run at 119.05 BPM.
      final interval = midiClockPulseInterval(120);
      expect(interval.inMilliseconds, 20);
      expect(interval.inMicroseconds, 20833);
    });

    test('is one 24th of a beat', () {
      for (final bpm in [40, 75, 120, 200, 300]) {
        final beat = midiClockPulseInterval(bpm) * midiClockPulsesPerQuarterNote;
        expect(
          (beat.inMicroseconds - Duration.microsecondsPerMinute / bpm).abs(),
          lessThan(midiClockPulsesPerQuarterNote),
          reason: 'a beat at $bpm BPM should be 24 pulses long',
        );
      }
    });

    test('refuses a tempo of zero or less rather than dividing by it', () {
      expect(() => midiClockPulseInterval(0), throwsArgumentError);
      expect(() => midiClockPulseInterval(-120), throwsArgumentError);
    });
  });

  group('midiClockElapsedAtPulse', () {
    test('counts from the first pulse', () {
      expect(
        midiClockElapsedAtPulse(120, 1),
        midiClockPulseInterval(120),
      );
      expect(
        midiClockElapsedAtPulse(120, 48),
        const Duration(seconds: 1),
      );
      expect(
        midiClockElapsedAtPulse(60, 24),
        const Duration(seconds: 1),
      );
    });

    test('does not accumulate the interval rounding error', () {
      // An hour of 140 BPM is 201,600 pulses. Adding the rounded interval
      // that many times drifts by nearly half a second; computing each
      // deadline from its pulse number cannot drift at all.
      const pulses = 201600;
      final accumulated = midiClockPulseInterval(140) * pulses;
      final computed = midiClockElapsedAtPulse(140, pulses);
      final exact = pulses * Duration.microsecondsPerMinute / (140 * 24);

      expect((computed.inMicroseconds - exact).abs(), lessThan(1));
      expect((accumulated.inMicroseconds - exact).abs(), greaterThan(1000));
    });

    test('refuses a tempo of zero or less', () {
      expect(() => midiClockElapsedAtPulse(0, 1), throwsArgumentError);
    });
  });

  group('midiClockPulsesPerSecond', () {
    test('matches the published figures', () {
      expect(midiClockPulsesPerSecond(60), 24);
      expect(midiClockPulsesPerSecond(90), 36);
      expect(midiClockPulsesPerSecond(120), 48);
      expect(midiClockPulsesPerSecond(140), 56);
    });

    test('keeps a fractional rate fractional', () {
      expect(midiClockPulsesPerSecond(101), closeTo(40.4, 0.0001));
    });

    test('refuses a tempo of zero or less', () {
      expect(() => midiClockPulsesPerSecond(0), throwsArgumentError);
    });
  });
}
