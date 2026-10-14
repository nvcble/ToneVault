import '../../../core/midi/midi_clock_timing.dart';

/// What a clock stream has actually done, as opposed to what it was asked
/// for - the two differ, and the difference is the point of measuring. Read
/// off a `MidiClockGenerator`.
class MidiClockReport {
  const MidiClockReport({
    required this.isRunning,
    required this.bpm,
    required this.pulsesSent,
    required this.droppedPulses,
    required this.elapsed,
    required this.worstLateness,
    required this.meanLateness,
    this.errorMessage,
  });

  final bool isRunning;
  final int bpm;

  /// Timing Clock messages the app handed to the transport since the stream
  /// started.
  ///
  /// Sent, not delivered: a USB MIDI write here is fire-and-forget, with no
  /// acknowledgement of any kind from the device, so nothing in this class
  /// can say a single one of them arrived.
  final int pulsesSent;

  /// Pulses whose moment passed while the app was not running - a scheduler
  /// that woke a whole interval or more late. Counted rather than fired off
  /// in a burst to catch up, because a burst would read on the wire as a
  /// sudden jump in tempo.
  final int droppedPulses;

  final Duration elapsed;

  /// The latest any one pulse went out against the moment it was due, and
  /// the average across all of them. Scheduling jitter, measured rather than
  /// claimed - see `MidiClockGenerator` on what Dart timers can and cannot
  /// promise.
  final Duration worstLateness;
  final Duration meanLateness;

  /// Why the stream stopped by itself, when it did.
  final String? errorMessage;

  double get expectedPulsesPerSecond => midiClockPulsesPerSecond(bpm);

  /// Null until the stream has run long enough to measure, which is what the
  /// first pulse or two is.
  double? get measuredPulsesPerSecond {
    final seconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    return seconds <= 0 ? null : pulsesSent / seconds;
  }
}
