import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/theme/app_theme.dart';
import 'package:tone_vault/core/midi/midi_endpoint.dart';
import 'package:tone_vault/core/midi/midi_engine.dart';
import 'package:tone_vault/core/midi/midi_message.dart';
import 'package:tone_vault/core/midi/midi_transport_type.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_profile.dart';
import 'package:tone_vault/features/midi/providers/midi_capture_controller.dart';
import 'package:tone_vault/features/midi/providers/midi_engine_providers.dart';
import 'package:tone_vault/features/midi/screens/midi_capture_log_screen.dart';
import 'package:tone_vault/features/midi/widgets/midi_log_tile.dart';

import '../support/fake_midi_transport.dart';

/// The capture log on its own page, which is where the bytes an MG-30 actually
/// sent are read - MIDI Diagnostics only starts and stops the capture.
void main() {
  const profile = NuxMg30V5Profile();
  const endpoint = MidiEndpoint(id: 'dev-1', name: 'MG-30', type: MidiTransportType.usb);

  late FakeMidiTransport transport;
  late ProviderContainer container;

  /// Built inside the test body, deliberately not in a `setUp`: that runs
  /// outside the fake-async zone the body runs in, so a stream created there
  /// delivers its events in the root zone and `pump` never sees them - an
  /// incoming message would silently never arrive.
  void prepare() {
    transport = FakeMidiTransport(endpoints: const [endpoint]);
    final engine = MidiEngine()
      ..attach(profile: profile, transportBuilder: () => transport);
    container = ProviderContainer(
      overrides: [midiEngineProvider.overrideWithValue(engine)],
    );
    addTearDown(() {
      container.dispose();
      engine.dispose();
    });
  }

  Future<void> pumpLog(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const MidiCaptureLogScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('says where to start a capture when none has run', (tester) async {
    prepare();

    await pumpLog(tester);

    expect(find.text('Nothing captured yet'), findsOneWidget);
    expect(find.textContaining('Start a capture on the Diagnostics screen'), findsOneWidget);
  });

  testWidgets('points at the device once a capture is open but silent', (tester) async {
    prepare();
    container.read(midiCaptureProvider.notifier).start();

    await pumpLog(tester);

    expect(find.textContaining('Capturing.'), findsOneWidget);
  });

  testWidgets('shows the raw bytes of what the device sent, newest first', (tester) async {
    prepare();
    container.read(midiCaptureProvider.notifier).start();
    // Through the transport rather than the controller, so this covers the whole
    // path a real reply takes: transport -> engine log -> capture.
    transport.receive(const SysExMessage(payload: [0x43, 0x58, 0x01]));
    transport.receive(const SysExMessage(payload: [0x43, 0x58, 0x02]));
    await pumpLog(tester);

    expect(find.byType(MidiLogTile), findsNWidgets(2));
    // Newest first: the reply to whatever was just tried is the row wanted.
    final tiles = tester.widgetList<MidiLogTile>(find.byType(MidiLogTile)).toList();
    expect((tiles.first.entry.message as SysExMessage).payload, [0x43, 0x58, 0x02]);
    expect(find.textContaining('F0 43 58 02 F7'), findsOneWidget);
  });
}
