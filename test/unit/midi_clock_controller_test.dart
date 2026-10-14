import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/midi_connection_state.dart';
import 'package:tone_vault/core/midi/midi_engine.dart';
import 'package:tone_vault/core/midi/midi_message.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_profile.dart';
import 'package:tone_vault/features/midi/providers/midi_clock_controller.dart';

import '../support/fake_midi_transport.dart';

/// The controller on a clock the test owns, talking to a transport with no
/// hardware behind it.
class _Harness {
  _Harness(this._async, {bool connected = true}) {
    engine = MidiEngine()
      ..attach(
        profile: const NuxMg30V5Profile(),
        transportBuilder: () => transport,
      );
    if (connected) {
      transport.setState(MidiConnectionState.connected);
    }
    controller = MidiClockController(
      engine,
      deviceName: () => 'MG-30',
      now: () => _epoch.add(_async.elapsed),
    );
  }

  static final DateTime _epoch = DateTime.utc(2026, 5, 4);

  final FakeAsync _async;
  final FakeMidiTransport transport = FakeMidiTransport();
  late final MidiEngine engine;
  late final MidiClockController controller;

  List<MidiRealTime> get kinds => [
    for (final message in transport.sent)
      if (message is RealTimeMessage) message.kind,
  ];

  int get pulses =>
      kinds.where((kind) => kind == MidiRealTime.timingClock).length;

  void startNow() {
    controller.start();
    _async.flushMicrotasks();
  }

  void stopNow() {
    controller.stop();
    _async.flushMicrotasks();
  }

  void close() {
    controller.dispose();
    _async.flushMicrotasks();
    engine.dispose();
  }
}

void main() {
  // The controller stops the clock when the app is backgrounded, which means
  // an `AppLifecycleListener`, which means a binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MidiClockController tempo', () {
    test('takes its tempo from the same tap engine the rail uses', () {
      fakeAsync((async) {
        final harness = _Harness(async);

        harness.controller.tap();
        expect(harness.controller.state.bpm, defaultMidiClockBpm);

        // 600 ms between taps is 100 BPM.
        async.elapse(const Duration(milliseconds: 600));
        harness.controller.tap();

        expect(harness.controller.state.bpm, 100);

        harness.close();
      });
    });

    test('clamps a tempo outside the range the app counts', () {
      fakeAsync((async) {
        final harness = _Harness(async);

        harness.controller.setBpm(0);
        expect(harness.controller.state.bpm, 30);

        harness.controller.setBpm(9999);
        expect(harness.controller.state.bpm, 300);

        harness.close();
      });
    });

    test('nudges by whole beats', () {
      fakeAsync((async) {
        final harness = _Harness(async);

        harness.controller.nudgeBpm(-5);
        expect(harness.controller.state.bpm, defaultMidiClockBpm - 5);

        harness.close();
      });
    });

    test('a tempo change while running re-aims the stream and is logged', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.startNow();
        async.elapse(const Duration(seconds: 1));

        harness.controller.setBpm(60);
        async.elapse(const Duration(seconds: 1));

        expect(harness.pulses, 48 + 24);
        expect(
          kindsOf(harness.kinds, MidiRealTime.start),
          1,
          reason: 'no second Start',
        );
        expect(
          harness.controller.state.entries.first.type,
          'Tempo change',
        );
        expect(
          harness.controller.state.entries.first.detail,
          contains('60 BPM'),
        );

        harness.close();
      });
    });
  });

  group('MidiClockController transport controls', () {
    test('start logs the Start message, its byte and the output', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.startNow();

        final entry = harness.controller.state.entries.single;
        expect(entry.type, 'Start');
        expect(entry.bytes, 'FA');
        expect(entry.device, 'MG-30');
        expect(entry.detail, contains('120 BPM · 48.0 pulses/s expected'));
        expect(entry.isFailure, isFalse);

        harness.close();
      });
    });

    test('stop logs Stop with what the run managed to send', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.startNow();
        async.elapse(const Duration(seconds: 1));
        harness.stopNow();

        final entry = harness.controller.state.entries.first;
        expect(entry.type, 'Stop');
        expect(entry.bytes, 'FC');
        expect(entry.detail, contains('48 pulses sent'));
        expect(harness.controller.state.isRunning, isFalse);

        harness.close();
      });
    });

    test('the test pulse is logged but kept out of the stream figures', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.controller.sendTestPulse();
        async.flushMicrotasks();

        final entry = harness.controller.state.entries.single;
        expect(entry.type, 'Timing Clock');
        expect(entry.bytes, 'F8');
        expect(entry.detail, contains('outside any stream'));
        expect(
          harness.controller.state.report,
          isNull,
          reason: 'no stream has been started',
        );

        harness.close();
      });
    });

    test('publishes counters periodically, not per pulse', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.startNow();
        async.elapse(const Duration(seconds: 2));

        // Sampled twice a second, so what is on screen can be up to one
        // interval - 24 pulses at this tempo - behind the stream. That is
        // the trade for not rebuilding the panel 48 times a second.
        final lag =
            48 * MidiClockController.summaryInterval.inMilliseconds ~/ 1000;
        final report = harness.controller.state.report;
        expect(report, isNotNull);
        expect(report!.isRunning, isTrue);
        expect(report.pulsesSent, inInclusiveRange(96 - lag, 96));
        expect(report.expectedPulsesPerSecond, 48);
        expect(report.measuredPulsesPerSecond, closeTo(48, 1));

        harness.close();
      });
    });

    test('keeps clock pulses out of the engine log, but not Start and Stop', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.startNow();
        async.elapse(const Duration(seconds: 1));
        harness.stopNow();

        final logged = [
          for (final entry in harness.engine.history)
            midiMessageTypeLabel(entry.message),
        ];
        expect(logged, ['Start', 'Stop']);
        expect(
          harness.pulses,
          48,
          reason: 'the pulses went out, they were just not logged',
        );

        harness.close();
      });
    });
  });

  group('MidiClockController safety', () {
    test('output is off until it is turned on', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        expect(harness.controller.state.outputEnabled, isFalse);
        harness.close();
      });
    });

    test('turning output off stops a running stream', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.controller.setOutputEnabled(true);
        harness.startNow();
        async.elapse(const Duration(milliseconds: 500));

        harness.controller.setOutputEnabled(false);
        async.flushMicrotasks();

        expect(harness.controller.state.isRunning, isFalse);
        final pulses = harness.pulses;
        async.elapse(const Duration(seconds: 1));
        expect(harness.pulses, pulses);

        harness.close();
      });
    });

    test('losing the connection stops the clock and says so', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.startNow();
        async.elapse(const Duration(milliseconds: 500));
        final pulses = harness.pulses;

        harness.transport.setState(MidiConnectionState.disconnected);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));

        expect(harness.controller.state.isRunning, isFalse);
        expect(harness.pulses, pulses, reason: 'no pulse after the unplug');
        expect(
          harness.controller.state.entries.any(
            (entry) => entry.type == 'Connection lost',
          ),
          isTrue,
        );

        harness.close();
      });
    });

    test('a write that fails is logged as a failure and stops the run', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.startNow();
        async.elapse(const Duration(milliseconds: 500));
        final pulses = harness.pulses;

        harness.transport.failSend = true;
        async.elapse(const Duration(seconds: 1));

        expect(harness.controller.state.isRunning, isFalse);
        expect(harness.pulses, pulses);

        final failure = harness.controller.state.entries.first;
        expect(failure.isFailure, isTrue);
        expect(failure.type, 'Timing Clock');
        expect(failure.detail, contains('MIDI write failed'));
        expect(
          harness.controller.state.report?.errorMessage,
          contains('MIDI write failed'),
        );

        harness.close();
      });
    });

    test('a Start that cannot be sent is reported rather than swallowed', () {
      fakeAsync((async) {
        final harness = _Harness(async, connected: false);

        Object? caught;
        harness.controller.start().catchError((Object error) {
          caught = error;
        });
        async.flushMicrotasks();

        expect(caught, isA<StateError>());
        expect(harness.controller.state.isRunning, isFalse);
        expect(harness.controller.state.entries.single.isFailure, isTrue);

        async.elapse(const Duration(seconds: 1));
        expect(harness.pulses, 0, reason: 'nothing was ever scheduled');

        harness.close();
      });
    });

    test('clearing the log leaves the counters alone', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.startNow();
        async.elapse(const Duration(seconds: 1));
        // Stopping publishes the run's final figures, rather than whatever
        // the periodic sample last caught.
        harness.stopNow();

        harness.controller.clearLog();

        expect(harness.controller.state.entries, isEmpty);
        expect(harness.controller.state.report?.pulsesSent, 48);

        harness.close();
      });
    });

    test('dispose stops the stream and leaves no timer behind', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.startNow();
        async.elapse(const Duration(milliseconds: 500));
        final pulses = harness.pulses;

        harness.controller.dispose();
        async.flushMicrotasks();

        expect(harness.kinds.last, MidiRealTime.stop);
        async.elapse(const Duration(seconds: 1));
        expect(harness.pulses, pulses);

        harness.engine.dispose();
      });
    });
  });
}

int kindsOf(List<MidiRealTime> kinds, MidiRealTime wanted) =>
    kinds.where((kind) => kind == wanted).length;
