import 'dart:async';

import '../../../core/midi/midi_clock_timing.dart';
import '../../../core/midi/midi_message.dart';
import 'midi_clock_report.dart';

/// How a generator puts a message on the wire. A function rather than the
/// engine itself, so the scheduler can be tested against a list.
typedef MidiClockSend = Future<void> Function(MidiMessage message);

/// Sends a MIDI Clock stream: Start, then a Timing Clock every
/// `60 / (bpm * 24)` of a second, then Stop.
///
/// **This is a synchronisation stream, not a command.** Nothing here sets a
/// device's tempo; a device that follows MIDI Clock derives one from the
/// pulse rate, and a device that does not simply ignores every byte of it.
///
/// **No hard real-time timing is claimed.** Pulses are scheduled with
/// ordinary Dart timers on the UI isolate, so a garbage collection or a busy
/// frame will make one late - and at 120 BPM the gap aimed at is 20.8 ms,
/// barely over one frame. Rather than pretend otherwise: each pulse is aimed
/// at an absolute deadline computed from its pulse number (see
/// [midiClockElapsedAtPulse]), so lateness cannot accumulate, and every
/// pulse's lateness is measured into [MidiClockReport].
class MidiClockGenerator {
  MidiClockGenerator({
    required this._send,
    required this._bpm,
    DateTime Function()? now,
    this._onChanged,
  }) : _now = now ?? DateTime.now;

  final MidiClockSend _send;

  /// Injectable only so a test can measure drift on a clock it controls.
  final DateTime Function() _now;

  /// Fired when the stream starts, stops or fails - never per pulse, which
  /// is the whole reason a listener can afford to rebuild on it.
  final void Function()? _onChanged;

  int _bpm;
  bool _running = false;
  Timer? _timer;

  /// When the current phase began, and how many pulses have gone out since.
  ///
  /// Re-anchored on a tempo change and after a late wake-up, so a deadline is
  /// always measured from a point the stream actually hit rather than from a
  /// start that may be minutes and several tempos ago.
  DateTime _anchoredAt = DateTime.fromMicrosecondsSinceEpoch(0);
  int _pulsesSinceAnchor = 0;

  /// Bumped every time a pulse is scheduled, so a pulse that comes back from
  /// its send can tell whether it is still the current one - see [_pulse].
  int _generation = 0;

  DateTime? _startedAt;
  int _pulsesSent = 0;
  int _droppedPulses = 0;
  int _latenessSamples = 0;
  int _totalLatenessMicros = 0;
  int _worstLatenessMicros = 0;
  String? _errorMessage;

  int get bpm => _bpm;
  bool get isRunning => _running;

  /// Starts the stream, sending Start (0xFA) once before the first pulse.
  ///
  /// A no-op when it is already running, so pressing Start twice cannot
  /// leave two timers sending into the same port. Rethrows a failed Start:
  /// nothing has been scheduled at that point, and the caller is the one
  /// with a user to tell.
  Future<void> start() async {
    if (_running) {
      return;
    }
    _requireUsableTempo();
    _resetCounters();
    try {
      await _send(const RealTimeMessage(MidiRealTime.start));
    } catch (error) {
      _errorMessage = error.toString();
      _onChanged?.call();
      rethrow;
    }

    _running = true;
    _startedAt = _now();
    _anchor();
    _onChanged?.call();
    _schedule();
  }

  /// Stops the stream and sends Stop (0xFC).
  ///
  /// The timer is cancelled before anything is sent, so a port that has gone
  /// away still ends the stream rather than leaving it running because the
  /// goodbye could not be delivered.
  Future<void> stop() async {
    if (!_running) {
      return;
    }
    _timer?.cancel();
    _timer = null;
    _running = false;
    try {
      await _send(const RealTimeMessage(MidiRealTime.stop));
    } catch (error) {
      _errorMessage = error.toString();
    }
    _onChanged?.call();
  }

  /// Changes tempo, taking effect from the next pulse.
  ///
  /// The running stream is re-aimed rather than restarted: no second timer,
  /// no second Start, and no gap in the pulse train, because a device
  /// following the clock would hear a restart as the beat going back to one.
  void setBpm(int bpm) {
    if (bpm == _bpm) {
      return;
    }
    final previous = _bpm;
    _bpm = bpm;
    try {
      _requireUsableTempo();
    } catch (_) {
      _bpm = previous;
      rethrow;
    }
    if (!_running) {
      return;
    }
    _timer?.cancel();
    _anchor();
    _schedule();
  }

  MidiClockReport report() => MidiClockReport(
    isRunning: _running,
    bpm: _bpm,
    pulsesSent: _pulsesSent,
    droppedPulses: _droppedPulses,
    elapsed: _startedAt == null
        ? Duration.zero
        : _now().difference(_startedAt!),
    worstLateness: Duration(microseconds: _worstLatenessMicros),
    meanLateness: Duration(
      microseconds: _latenessSamples == 0
          ? 0
          : _totalLatenessMicros ~/ _latenessSamples,
    ),
    errorMessage: _errorMessage,
  );

  /// Checked before Start goes out and before a tempo change is accepted,
  /// rather than at the next pulse: a stream that announced itself and then
  /// threw would leave the device told to run with nothing following it.
  void _requireUsableTempo() => midiClockPulseInterval(_bpm);

  void _anchor() {
    _anchoredAt = _now();
    _pulsesSinceAnchor = 0;
  }

  void _schedule() {
    final due = midiClockElapsedAtPulse(_bpm, _pulsesSinceAnchor + 1);
    final delay = due - _now().difference(_anchoredAt);
    final generation = ++_generation;
    _timer = Timer(
      delay.isNegative ? Duration.zero : delay,
      () => _pulse(generation),
    );
  }

  /// A pulse awaits its send, and a tempo change during that await re-aims
  /// the stream and schedules the next pulse itself. Without this, the
  /// awaiting pulse would then schedule a second one and the port would be
  /// fed by two trains at once - the duplicate scheduler this class exists
  /// to make impossible.
  Future<void> _pulse(int generation) async {
    final due = midiClockElapsedAtPulse(_bpm, _pulsesSinceAnchor + 1);
    final lateness = _now().difference(_anchoredAt) - due;
    _pulsesSinceAnchor++;
    _recordLateness(lateness);

    try {
      await _send(const RealTimeMessage(MidiRealTime.timingClock));
      _pulsesSent++;
    } catch (error) {
      _failWith(error);
      return;
    }

    // Stopped, or re-aimed, while that send was in flight: whoever did it
    // owns the schedule now.
    if (!_running || generation != _generation) {
      return;
    }

    final interval = midiClockPulseInterval(_bpm);
    if (lateness >= interval) {
      _droppedPulses += lateness.inMicroseconds ~/ interval.inMicroseconds;
      _anchor();
    }
    _schedule();
  }

  void _recordLateness(Duration lateness) {
    final micros = lateness.inMicroseconds.abs();
    _latenessSamples++;
    _totalLatenessMicros += micros;
    if (micros > _worstLatenessMicros) {
      _worstLatenessMicros = micros;
    }
  }

  /// A send that failed ends the stream there and then. A clock whose pulses
  /// are not getting out is not a slow clock, it is a stopped one, and
  /// carrying on would fill the log with the same failure 48 times a second.
  void _failWith(Object error) {
    _timer?.cancel();
    _timer = null;
    _running = false;
    _errorMessage = error.toString();
    _onChanged?.call();
  }

  void _resetCounters() {
    _pulsesSent = 0;
    _droppedPulses = 0;
    _latenessSamples = 0;
    _totalLatenessMicros = 0;
    _worstLatenessMicros = 0;
    _errorMessage = null;
    _startedAt = null;
  }

  /// Cancels the timer, and says goodbye if the stream was running. The Stop
  /// is not awaited: the timer, which is the thing that would otherwise keep
  /// sending, is already cancelled by the time it goes out.
  void dispose() {
    final wasRunning = _running;
    _timer?.cancel();
    _timer = null;
    _running = false;
    if (wasRunning) {
      unawaited(
        _send(const RealTimeMessage(MidiRealTime.stop)).catchError((_) {}),
      );
    }
  }
}
