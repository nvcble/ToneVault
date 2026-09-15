import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tone_vault/app/router/routes.dart';
import 'package:tone_vault/app/theme/app_theme.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/database_provider.dart';
import 'package:tone_vault/core/midi/midi_endpoint.dart';
import 'package:tone_vault/core/midi/midi_engine.dart';
import 'package:tone_vault/core/midi/midi_transport_type.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_profile.dart';
import 'package:tone_vault/features/midi/providers/midi_engine_providers.dart';
import 'package:tone_vault/features/midi/routes/midi_routes.dart';
import 'package:tone_vault/features/midi/screens/midi_diagnostics_screen.dart';
import 'package:tone_vault/features/midi/widgets/midi_log_tile.dart';

import '../support/fake_midi_transport.dart';
import '../support/screen_harness.dart';

/// The MIDI screens under the app's own theme.
///
/// Worth pumping rather than unit-testing the controllers alone: the theme
/// gives every FilledButton an infinite minimum width, and a Row cannot
/// satisfy that. Laying one out throws during layout, which aborts the frame
/// and leaves the screen blank - not a red error box, because
/// `ErrorWidget.builder` only catches build failures. That is exactly how
/// Diagnostics failed on a real device while every unit test passed.
void main() {
  const profile = NuxMg30V5Profile();
  const endpoint = MidiEndpoint(id: 'dev-1', name: 'MG-30', type: MidiTransportType.usb);

  late AppDatabase database;
  late MidiEngine engine;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    engine = MidiEngine();
    // Pre-attached, so the connection controller's own attach call is the
    // no-op branch and never builds a real UsbMidiTransport.
    engine.attach(
      profile: profile,
      transportBuilder: () => FakeMidiTransport(endpoints: const [endpoint]),
    );
  });

  tearDown(() async {
    engine.dispose();
    await database.close();
  });

  /// A surface tall enough to hold the whole screen at once.
  ///
  /// The body is a lazy ListView, so on a phone-sized surface the panels below
  /// the fold are never built - and an unbuilt panel cannot throw during
  /// layout, which is the entire class of bug these tests exist to catch.
  void useTallSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1000, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> pumpDiagnostics(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          midiEngineProvider.overrideWithValue(engine),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const MidiDiagnosticsScreen(profileId: 'nux_mg30_v5'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  screenTest('lays out every panel for a NUX MG-30 V5 without throwing', (tester) async {
    useTallSurface(tester);

    await pumpDiagnostics(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('MIDI Diagnostics'), findsOneWidget);
  });

  screenTest('shows every panel the brief asks for', (tester) async {
    useTallSurface(tester);

    await pumpDiagnostics(tester);

    for (final section in const [
      'Connection',
      'MIDI Capture',
      'Manual Probe',
      'Preset Import (Milestone 1)',
      // The experimental read is only offered for the profile it was written
      // for, and must say so rather than reading as verified support.
      'Read One Preset (Experimental)',
    ]) {
      expect(find.text(section), findsOneWidget, reason: '$section should be on the screen');
    }
  });

  screenTest('links to the capture log rather than listing bytes inline', (tester) async {
    useTallSurface(tester);

    await pumpDiagnostics(tester);

    // The rows themselves belong on MidiCaptureLogScreen: a few seconds of real
    // traffic is enough of them to bury every control below this one.
    expect(find.text('View Capture Log'), findsOneWidget);
    expect(find.text('Nothing captured yet.'), findsOneWidget);
    expect(find.byType(MidiLogTile), findsNothing);
  });

  screenTest('opens the capture log page when that row is tapped', (tester) async {
    useTallSurface(tester);
    // Through the real router, so a path built by Routes and the segment the
    // route is registered under have to actually agree.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          midiEngineProvider.overrideWithValue(engine),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark(),
          routerConfig: GoRouter(
            initialLocation: Routes.midiDiagnostics('nux_mg30_v5'),
            routes: midiRoutes(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('View Capture Log'));
    await tester.pumpAndSettle();

    expect(find.text('Capture Log'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  screenTest('offers Connect while disconnected and reports the detected device', (tester) async {
    await pumpDiagnostics(tester);

    expect(find.text('Connect'), findsOneWidget);
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // Connected now, so the button has done its job and stepped aside.
    expect(find.text('Connect'), findsNothing);
  });
}
