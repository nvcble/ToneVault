import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/midi/midi_clock_timing.dart';
import '../../../core/midi/midi_connection_state.dart';
import '../../../core/midi/midi_engine.dart';
import '../../../core/midi/midi_message.dart';
import '../../../core/values/tempo_range.dart';
import '../data/midi_clock_generator.dart';
import '../data/midi_clock_output_state.dart';
import '../data/tap_tempo.dart';

/// Where the clock starts before anyone has tapped or typed a tempo - MIDI's
/// own conventional default.
const int defaultMidiClockBpm = 120;

/// Drives a [MidiClockGenerator] and keeps the diagnostic's counters and log.
///
/// Holds no second opinion about tempo: tapping goes through the same
/// [TapTempo] the performance rail's button uses, and the BPM it produces is
/// the BPM the clock runs at.
class MidiClockController extends StateNotifier<MidiClockOutputState> {
  MidiClockController(
    this._engine, {
    required this._deviceName,
    DateTime Function()? now,
    int bpm = defaultMidiClockBpm,
  }) : _now = now ?? DateTime.now,
       super(MidiClockOutputState(bpm: bpm)) {
    _generator = MidiClockGenerator(
      send: _sendFromGenerator,
      bpm: bpm,
      now: _now,
      onChanged: _publish,
    );
    _connectionSubscription = _engine.connectionState.listen(
      _onConnectionState,
    );
    _lifecycle = AppLifecycleListener(onPause: _haltBackgrounded);
  }

  final MidiEngine _engine;
  final String Function() _deviceName;
  final DateTime Function() _now;
  final TapTempo _taps = TapTempo();

  late final MidiClockGenerator _generator;
  late final AppLifecycleListener _lifecycle;
  StreamSubscription<MidiConnectionState>? _connectionSubscription;
  Timer? _summaryTimer;

  /// Enough log to see a run's shape, and bounded so a long session cannot
  /// grow it without limit. Clock pulses are not logged at all - only the
  /// one-off messages, the failures and what the user did.
  static const int maxLogEntries = 60;

  /// How often the counters on screen are refreshed. Twice a second is
  /// readable and costs one rebuild; a rebuild per pulse would be 48 a
  /// second at 120 BPM.
  static const Duration summaryInterval = Duration(milliseconds: 500);

  /// Starts the stream at the tempo now showing, whatever the output toggle
  /// says - this is the diagnostic's own explicit action, and the toggle
  /// exists to stop *other* parts of the app putting clock on the wire.
  Future<void> start() async {
    if (_generator.isRunning) {
      return;
    }
    _generator.setBpm(state.bpm);
    await _generator.start();
    _summaryTimer = Timer.periodic(summaryInterval, (_) => _publish());
    _publish();
  }

  Future<void> stop() async {
    _summaryTimer?.cancel();
    _summaryTimer = null;
    await _generator.stop();
    _publish();
  }

  /// One Timing Clock byte on its own, to prove the port accepts it before
  /// starting a stream of them. Not counted in the stream's own figures.
  Future<void> sendTestPulse() => _send(
    const RealTimeMessage(MidiRealTime.timingClock),
    logged: true,
    detail: 'Single test pulse, outside any stream',
  );

  /// Sets the tempo, clamped to the range the rest of the app counts in.
  ///
  /// A running stream is re-aimed, not restarted - see
  /// [MidiClockGenerator.setBpm].
  void setBpm(int bpm) {
    final clamped = clampBpm(bpm);
    if (clamped == state.bpm) {
      return;
    }
    state = state.copyWith(bpm: clamped);
    _generator.setBpm(clamped);
    if (_generator.isRunning) {
      _append(
        type: 'Tempo change',
        detail:
            '$clamped BPM · '
            '${midiClockPulsesPerSecond(clamped).toStringAsFixed(1)} '
            'pulses/s expected',
      );
      _publish();
    }
  }

  void nudgeBpm(int by) => setBpm(state.bpm + by);

  /// A tap of the tempo. Two taps make a reading; one says nothing yet.
  void tap() {
    final bpm = _taps.tap(_now());
    if (bpm != null) {
      setBpm(bpm);
    }
  }

  /// Whether anything outside this panel may drive the clock. Turning it off
  /// stops a running stream, because a switch marked off that leaves MIDI
  /// going out is a lie.
  void setOutputEnabled(bool enabled) {
    state = state.copyWith(outputEnabled: enabled);
    if (!enabled && _generator.isRunning) {
      unawaited(stop());
    }
  }

  void clearLog() => state = state.copyWith(entries: const []);

  /// The generator's own send path. Pulses are sent unlogged - see
  /// [MidiEngine.send] - while Start and Stop are one-off messages worth a
  /// row each.
  Future<void> _sendFromGenerator(MidiMessage message) {
    final isPulse =
        message is RealTimeMessage && message.kind == MidiRealTime.timingClock;
    return _send(message, logged: !isPulse, detail: _detailFor(message));
  }

  Future<void> _send(
    MidiMessage message, {
    required bool logged,
    String? detail,
  }) async {
    try {
      await _engine.send(message, log: logged);
      if (logged) {
        _logMessage(message, detail: detail);
      }
    } catch (error) {
      // Always logged, pulse or not: the generator stops at the first
      // failure, so this cannot run away with the log.
      _logMessage(message, detail: error.toString(), isFailure: true);
      rethrow;
    }
  }

  String? _detailFor(MidiMessage message) {
    if (message is! RealTimeMessage) {
      return null;
    }
    return switch (message.kind) {
      MidiRealTime.start =>
        '${state.bpm} BPM · '
            '${midiClockPulsesPerSecond(state.bpm).toStringAsFixed(1)} '
            'pulses/s expected',
      MidiRealTime.stop =>
        '${_generator.report().pulsesSent} pulses sent in this run',
      MidiRealTime.timingClock => null,
    };
  }

  void _logMessage(
    MidiMessage message, {
    String? detail,
    bool isFailure = false,
  }) {
    _append(
      type: midiMessageTypeLabel(message),
      bytes: hexBytes(message.toBytes()),
      detail: detail,
      isFailure: isFailure,
    );
  }

  void _append({
    required String type,
    String? bytes,
    String? detail,
    bool isFailure = false,
  }) {
    final entry = MidiClockLogEntry(
      timestamp: _now(),
      type: type,
      device: _deviceName(),
      bytes: bytes,
      detail: detail,
      isFailure: isFailure,
    );
    state = state.copyWith(
      entries: [entry, ...state.entries.take(maxLogEntries - 1)],
    );
  }

  void _publish() {
    final report = _generator.report();
    if (!report.isRunning) {
      _summaryTimer?.cancel();
      _summaryTimer = null;
    }
    state = state.copyWith(report: report);
  }

  void _onConnectionState(MidiConnectionState connectionState) {
    if (connectionState == MidiConnectionState.connected ||
        !_generator.isRunning) {
      return;
    }
    _append(
      type: 'Connection lost',
      detail: 'Clock stopped. Any Stop message could not be delivered.',
    );
    unawaited(stop());
  }

  /// A backgrounded app has no business still sending clock: a stream the
  /// screen cannot show is one nobody can stop.
  void _haltBackgrounded() {
    if (!_generator.isRunning) {
      return;
    }
    _append(type: 'App paused', detail: 'Clock stopped.');
    unawaited(stop());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _connectionSubscription?.cancel();
    _summaryTimer?.cancel();
    _generator.dispose();
    super.dispose();
  }
}
