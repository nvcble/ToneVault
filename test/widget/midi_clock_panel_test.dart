import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/theme/app_theme.dart';
import 'package:tone_vault/core/midi/midi_endpoint.dart';
import 'package:tone_vault/core/midi/midi_engine.dart';
import 'package:tone_vault/core/midi/midi_message.dart';
import 'package:tone_vault/core/midi/midi_transport_type.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_profile.dart';
import 'package:tone_vault/features/midi/providers/midi_clock_controller.dart';
import 'package:tone_vault/features/midi/providers/midi_clock_providers.dart';
import 'package:tone_vault/features/midi/providers/midi_connection_controller.dart';
import 'package:tone_vault/features/midi/providers/midi_engine_providers.dart';
import 'package:tone_vault/features/midi/widgets/midi_clock_panel.dart';

import '../support/fake_midi_transport.dart';

void main() {
  const profile = NuxMg30V5Profile();
  const endpoint = MidiEndpoint(
    id: 'dev-1',
    name: 'MG-30',
    type: MidiTransportType.usb,
  );

  late MidiEngine engine;
  late FakeMidiTransport transport;
  late ProviderContainer container;

  /// The test binding's own clock, assigned in [pumpPanel].
  ///
  /// The clock has to be the one `tester.pump` advances, or the two disagree:
  /// the scheduler would be aiming at deadlines on one clock while its timers
  /// fired on another. It is also what makes tapping a tempo testable at all
  /// - two taps a real millisecond apart read as 300 BPM.
  late DateTime Function() testNow;

  void prepare() {
    transport = FakeMidiTransport(endpoints: const [endpoint]);
    engine = MidiEngine()
      ..attach(profile: profile, transportBuilder: () => transport);
    container = ProviderContainer(
      overrides: [
        midiEngineProvider.overrideWithValue(engine),
        midiClockProvider(profile.id).overrideWith(
          (ref) => MidiClockController(
            engine,
            deviceName: () => endpoint.name,
            now: () => testNow(),
          ),
        ),
      ],
    );
    addTearDown(() {
      container.dispose();
      engine.dispose();
    });
  }

  Future<void> pumpPanel(WidgetTester tester) async {
    testNow = () => tester.binding.clock.now();
    // The panel is taller than the default test surface, and an overflow
    // should fail this test rather than only stripe it.
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(
            body: MidiClockPanel(profileId: 'nux_mg30_v5'),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> connect() =>
      container.read(midiConnectionProvider(profile.id).notifier).connect();

  List<MidiRealTime> kinds() => [
    for (final message in transport.sent)
      if (message is RealTimeMessage) message.kind,
  ];

  int pulses() =>
      kinds().where((kind) => kind == MidiRealTime.timingClock).length;

  testWidgets('offers nothing to press until the device is connected', (
    tester,
  ) async {
    prepare();
    await pumpPanel(tester);

    expect(find.text('MIDI Clock Test'), findsOne);
    expect(find.text('Output: no device connected'), findsOne);
    expect(
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Start Clock')).onPressed,
      isNull,
    );
    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Send Test Pulse'),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('names the output it will send to once connected', (
    tester,
  ) async {
    prepare();
    await pumpPanel(tester);
    await connect();
    await tester.pump();

    expect(find.text('Output: MG-30'), findsOne);
    expect(
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Start Clock')).onPressed,
      isNotNull,
    );
  });

  testWidgets('Start sends FA and then a pulse train, Stop ends it', (
    tester,
  ) async {
    prepare();
    await pumpPanel(tester);
    await connect();
    await tester.pump();

    await tester.tap(find.text('Start Clock'));
    await tester.pump();
    expect(kinds().first, MidiRealTime.start);

    // A second of 120 BPM is 48 pulses. The scheduler is aiming at the same
    // clock `pump` advances, so this is exact rather than approximate.
    await tester.pump(const Duration(seconds: 1));
    expect(pulses(), 48);
    expect(find.textContaining('pulse'), findsWidgets);

    await tester.tap(find.text('Stop Clock'));
    await tester.pump();
    expect(kinds().last, MidiRealTime.stop);

    // Nothing left scheduled: another second produces nothing, and the test
    // would fail on a pending timer if the periodic summary were still on.
    await tester.pump(const Duration(seconds: 1));
    expect(pulses(), 48);
  });

  testWidgets('a test pulse is one byte, logged on its own', (tester) async {
    prepare();
    await pumpPanel(tester);
    await connect();
    await tester.pump();

    await tester.tap(find.text('Send Test Pulse'));
    await tester.pump();

    expect(transport.sent.single.toBytes(), [0xF8]);
    expect(find.textContaining('F8'), findsWidgets);
    expect(find.textContaining('outside any stream'), findsOne);
  });

  testWidgets('tapping and nudging move the tempo the clock will run at', (
    tester,
  ) async {
    prepare();
    await pumpPanel(tester);

    // Twice over: the headline reading and the field you can type into
    // always show the same tempo, whichever way it was set.
    expect(find.text('120'), findsNWidgets(2));

    await tester.tap(find.text('+5'));
    await tester.pump();
    expect(find.text('125'), findsNWidgets(2));

    await tester.tap(find.text('-5'));
    await tester.pump();
    expect(find.text('120'), findsNWidgets(2));

    // Two taps 750 ms apart is 80 BPM.
    await tester.tap(find.text('Tap tempo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));
    await tester.tap(find.text('Tap tempo'));
    await tester.pump();

    expect(find.text('80'), findsNWidgets(2));
    expect(
      transport.sent,
      isEmpty,
      reason: 'tapping a tempo is not itself a reason to send anything',
    );
  });

  testWidgets('says that a send is attempted, never confirmed', (tester) async {
    prepare();
    await pumpPanel(tester);
    await connect();
    await tester.pump();

    await tester.tap(find.text('Start Clock'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Stop Clock'));
    await tester.pump();

    expect(
      find.textContaining('attempted; USB MIDI confirms no delivery'),
      findsOne,
    );
    expect(find.textContaining('watch the unit'), findsOne);
  });

  testWidgets('clearing the log leaves the counters on screen', (tester) async {
    prepare();
    await pumpPanel(tester);
    await connect();
    await tester.pump();

    await tester.tap(find.text('Send Test Pulse'));
    await tester.pump();
    expect(find.text('Nothing sent yet.'), findsNothing);

    await tester.tap(find.text('Clear log'));
    await tester.pump();

    expect(find.text('Nothing sent yet.'), findsOne);
    expect(find.text('Not started. Nothing has been sent.'), findsOne);
  });
}
