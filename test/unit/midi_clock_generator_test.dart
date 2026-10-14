import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/midi_message.dart';
import 'package:tone_vault/features/midi/data/midi_clock_generator.dart';

/// A generator wired to a list instead of a port, on time the test controls.
///
/// Real pulses are 20 ms apart; waiting for them would make every assertion
/// here a race, so [FakeAsync] runs the clock instead.
class _Harness {
  _Harness(this._async, {int bpm = 120}) {
    generator = MidiClockGenerator(
      send: (message) async {
        if (failSends) {
          throw StateError('The port has gone away.');
        }
        if (holdNextPulse && _isPulse(message)) {
          holdNextPulse = false;
          held = Completer<void>();
          await held!.future;
        }
        sent.add(message);
      },
      bpm: bpm,
      // [stall] is what the app being descheduled looks like from inside:
      // the wall clock has moved on further than the timer that just fired
      // would suggest.
      now: () => _epoch.add(_async.elapsed + stall),
      onChanged: () => changes++,
    );
  }

  static final DateTime _epoch = DateTime.utc(2026, 5, 4);

  final FakeAsync _async;
  final List<MidiMessage> sent = [];

  Duration stall = Duration.zero;
  bool failSends = false;
  int changes = 0;

  /// Makes the next pulse's send hang until [held] is completed - a write
  /// that is genuinely still in flight, which is the only way to get at what
  /// happens when the tempo changes underneath one.
  bool holdNextPulse = false;
  Completer<void>? held;

  late final MidiClockGenerator generator;

  List<MidiRealTime> get kinds => [
    for (final message in sent) (message as RealTimeMessage).kind,
  ];

  int get pulses =>
      kinds.where((kind) => kind == MidiRealTime.timingClock).length;

  int get starts => kinds.where((kind) => kind == MidiRealTime.start).length;

  static bool _isPulse(MidiMessage message) =>
      message is RealTimeMessage && message.kind == MidiRealTime.timingClock;

  /// Starts the stream and lets the Start message get out, without waiting
  /// on wall-clock time.
  void startNow() {
    generator.start();
    _async.flushMicrotasks();
  }
}

void main() {
  group('MidiClockGenerator', () {
    test('announces itself with Start before any pulse', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.startNow();

        expect(harness.kinds, [MidiRealTime.start]);
        expect(harness.sent.single.toBytes(), [0xFA]);

        harness.generator.dispose();
      });
    });

    test('sends 24 pulses to the quarter note at the target tempo', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.startNow();
        async.elapse(const Duration(seconds: 1));

        // 120 BPM is two beats a second, so 48 pulses.
        expect(harness.pulses, 48);
        expect(
          harness.sent.last.toBytes(),
          [0xF8],
          reason: 'a pulse is the single byte 0xF8',
        );

        harness.generator.dispose();
      });
    });

    test('runs 60 and 140 BPM at their published rates', () {
      for (final (bpm, expected) in const [(60, 24), (140, 56)]) {
        fakeAsync((async) {
          final harness = _Harness(async, bpm: bpm);
          harness.startNow();
          async.elapse(const Duration(seconds: 1));

          expect(harness.pulses, expected, reason: 'at $bpm BPM');

          harness.generator.dispose();
        });
      }
    });

    test('stop ends the stream and sends Stop', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.startNow();
        async.elapse(const Duration(milliseconds: 500));
        expect(harness.pulses, 24);

        harness.generator.stop();
        async.flushMicrotasks();

        expect(harness.kinds.last, MidiRealTime.stop);
        expect(harness.sent.last.toBytes(), [0xFC]);
        expect(harness.generator.isRunning, isFalse);

        async.elapse(const Duration(seconds: 1));
        expect(harness.pulses, 24, reason: 'nothing more after Stop');
      });
    });

    test('pressing Start twice does not leave two streams running', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.startNow();
        harness.startNow();
        async.elapse(const Duration(seconds: 1));

        expect(harness.starts, 1);
        expect(harness.pulses, 48, reason: 'one stream, not two');

        harness.generator.dispose();
      });
    });

    test('a tempo change re-aims the stream rather than restarting it', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.startNow();
        async.elapse(const Duration(seconds: 1));

        harness.generator.setBpm(60);
        async.elapse(const Duration(seconds: 1));

        expect(harness.pulses, 48 + 24);
        expect(
          harness.starts,
          1,
          reason: 'a second Start would send the device back to beat one',
        );

        harness.generator.dispose();
      });
    });

    test('a tempo change during a send in flight leaves one stream', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.startNow();

        harness.holdNextPulse = true;
        async.elapse(const Duration(milliseconds: 21));
        expect(harness.pulses, 0, reason: 'that write has not come back yet');

        harness.generator.setBpm(60);
        harness.held!.complete();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 1));

        // The held pulse, then a second of 60 BPM. Two streams would have
        // put out roughly twice that.
        expect(harness.pulses, 1 + 24);

        harness.generator.dispose();
      });
    });

    test('a tempo change while stopped takes effect at the next start', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.generator.setBpm(60);
        harness.startNow();
        async.elapse(const Duration(seconds: 1));

        expect(harness.pulses, 24);

        harness.generator.dispose();
      });
    });

    test('refuses a tempo it cannot divide by, keeping the old one', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.startNow();

        expect(() => harness.generator.setBpm(0), throwsArgumentError);
        expect(harness.generator.bpm, 120);

        async.elapse(const Duration(seconds: 1));
        expect(harness.pulses, 48, reason: 'still running at the old tempo');

        harness.generator.dispose();
      });
    });

    test('a failed send stops the stream and reports why', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.startNow();
        async.elapse(const Duration(milliseconds: 500));
        final before = harness.pulses;

        harness.failSends = true;
        async.elapse(const Duration(seconds: 1));

        expect(harness.generator.isRunning, isFalse);
        expect(harness.pulses, before, reason: 'no pulse got out after it');

        final report = harness.generator.report();
        expect(report.errorMessage, contains('port has gone away'));
        expect(report.isRunning, isFalse);
      });
    });

    test('counts the pulses a stall swallowed instead of bursting', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.startNow();

        // The app wakes 100 ms late, which is nearly five pulses at 120 BPM.
        harness.stall = const Duration(milliseconds: 100);
        async.elapse(const Duration(milliseconds: 21));

        final stalled = harness.generator.report();
        expect(harness.pulses, 1, reason: 'one pulse, not a catch-up burst');
        expect(stalled.droppedPulses, 4);
        expect(stalled.worstLateness, const Duration(milliseconds: 100));

        // Re-anchored, so the next second runs at the right rate again
        // rather than trying to make the lost time up.
        async.elapse(const Duration(seconds: 1));
        expect(harness.generator.report().droppedPulses, 4);
        expect(harness.pulses, 49);

        harness.generator.dispose();
      });
    });

    test('measures the rate it actually achieved', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.startNow();
        async.elapse(const Duration(seconds: 2));

        final report = harness.generator.report();
        expect(report.expectedPulsesPerSecond, 48);
        expect(report.measuredPulsesPerSecond, closeTo(48, 0.5));
        expect(report.meanLateness, Duration.zero);
        expect(report.pulsesSent, 96);
      });
    });

    test('starting again resets the previous run figures', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.startNow();
        async.elapse(const Duration(seconds: 1));
        harness.generator.stop();
        async.flushMicrotasks();

        harness.startNow();
        expect(harness.generator.report().pulsesSent, 0);

        harness.generator.dispose();
      });
    });

    test('tells its listener when it starts and stops, never per pulse', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.startNow();
        async.elapse(const Duration(seconds: 1));
        harness.generator.stop();
        async.flushMicrotasks();

        expect(
          harness.changes,
          2,
          reason: '48 pulses went out between those two',
        );
      });
    });

    test('dispose cancels the stream and says goodbye to the device', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.startNow();
        async.elapse(const Duration(milliseconds: 100));
        final pulses = harness.pulses;

        harness.generator.dispose();
        async.flushMicrotasks();

        expect(harness.kinds.last, MidiRealTime.stop);
        async.elapse(const Duration(seconds: 1));
        expect(harness.pulses, pulses, reason: 'no timer left behind');
      });
    });

    test('dispose of a stream that never started sends nothing', () {
      fakeAsync((async) {
        final harness = _Harness(async);
        harness.generator.dispose();
        async.flushMicrotasks();

        expect(harness.sent, isEmpty);
      });
    });
  });
}
