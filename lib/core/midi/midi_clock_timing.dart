// The arithmetic of a MIDI Clock stream, with no scheduler and no transport
// anywhere near it - see `MidiClockGenerator` for the thing that actually
// sends pulses, and `MidiRealTime.timingClock` for the byte.
//
// Pure functions on purpose: the rate a clock should run at is arithmetic,
// and it is worth being able to test it without a timer or a MIDI port in
// the way.

/// MIDI's own resolution for a clock stream, fixed by the specification: 24
/// Timing Clock pulses to the quarter note. Not a number this app chose, and
/// not one a device can negotiate.
const int midiClockPulsesPerQuarterNote = 24;

/// How long one pulse of a [bpm] clock lasts.
///
/// Microseconds rather than milliseconds because the millisecond is too
/// coarse to hold the answer: 120 BPM wants 20.8333 ms, and a stream rounded
/// up to 21 ms runs 0.8% slow - a device following it would sit a little
/// under 119 BPM and drift a whole beat behind every two minutes.
///
/// Throws [ArgumentError] on a tempo of zero or less, which has no interval
/// at all rather than an infinite one.
Duration midiClockPulseInterval(int bpm) {
  _requirePositive(bpm);
  return Duration(
    microseconds:
        (Duration.microsecondsPerMinute / (bpm * midiClockPulsesPerQuarterNote))
            .round(),
  );
}

/// How long after the first pulse the [pulse]th pulse of a [bpm] clock is
/// due, counting the first pulse as 1.
///
/// What a scheduler should aim at, in place of adding [midiClockPulseInterval]
/// to a running total: that interval is rounded to the microsecond, so
/// accumulating it accumulates its rounding error as well, while this is
/// computed from the pulse number each time and so cannot drift at all.
Duration midiClockElapsedAtPulse(int bpm, int pulse) {
  _requirePositive(bpm);
  return Duration(
    microseconds:
        (pulse *
                Duration.microsecondsPerMinute /
                (bpm * midiClockPulsesPerQuarterNote))
            .round(),
  );
}

/// The pulse rate a [bpm] clock is meant to run at - 48 a second at 120 BPM.
///
/// A double because the real answer usually is one: 90 BPM is 36 pulses a
/// second exactly, but 100 BPM is 40 and 110 is 44, while 130 is 52 and 125
/// is exactly 50. Rounding here would make the diagnostic's "expected" figure
/// disagree with the interval it actually schedules.
double midiClockPulsesPerSecond(int bpm) {
  _requirePositive(bpm);
  return bpm * midiClockPulsesPerQuarterNote / 60;
}

void _requirePositive(int bpm) {
  if (bpm <= 0) {
    throw ArgumentError.value(bpm, 'bpm', 'A clock needs a tempo above zero.');
  }
}
