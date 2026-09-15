import 'package:drift/native.dart';
import 'package:flutter/gestures.dart' show kDoubleTapTimeout;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/theme/app_theme.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/database_provider.dart';
import 'package:tone_vault/core/midi/midi_endpoint.dart';
import 'package:tone_vault/core/midi/midi_engine.dart';
import 'package:tone_vault/core/midi/midi_transport_type.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_profile.dart';
import 'package:tone_vault/features/midi/providers/midi_connection_controller.dart';
import 'package:tone_vault/features/midi/providers/midi_engine_providers.dart';
import 'package:tone_vault/features/midi/screens/midi_control_screen.dart';
import 'package:tone_vault/features/midi/widgets/patch_grid_tile.dart';

import '../support/fake_midi_transport.dart';

/// Patch selection is confirmed working, so this page no longer asks the user
/// to opt into it or warns that it is unverified - it either works because the
/// device is connected, or it doesn't because it isn't.
void main() {
  const profile = NuxMg30V5Profile();
  const endpoint = MidiEndpoint(id: 'dev-1', name: 'MG-30', type: MidiTransportType.usb);

  late AppDatabase database;
  late MidiEngine engine;
  late FakeMidiTransport transport;
  late ProviderContainer container;

  void prepare() {
    database = AppDatabase(NativeDatabase.memory());
    transport = FakeMidiTransport(endpoints: const [endpoint]);
    engine = MidiEngine()..attach(profile: profile, transportBuilder: () => transport);
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        midiEngineProvider.overrideWithValue(engine),
      ],
    );
    addTearDown(() async {
      container.dispose();
      engine.dispose();
      await database.close();
    });
  }

  Future<void> pumpControl(WidgetTester tester) async {
    // The patch grid alone is taller than the default test surface; without
    // this, Scenes never builds at all, being below the fold.
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const MidiControlScreen(profileId: 'nux_mg30_v5'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('has no toggle and no hardware-verification warning', (tester) async {
    prepare();

    await pumpControl(tester);

    expect(find.text('Enable experimental Program Change'), findsNothing);
    expect(find.textContaining('verification'), findsNothing);
  });

  testWidgets('there is no separate Load Patch section any more', (tester) async {
    prepare();

    await pumpControl(tester);

    expect(find.text('Load patch'), findsNothing);
  });

  testWidgets('a single tap on a patch tile only pre-selects it', (tester) async {
    prepare();
    await container.read(midiConnectionProvider(profile.id).notifier).connect();

    await pumpControl(tester);
    transport.sent.clear(); // drop the auto-selected default scene sent on connect
    await tester.tap(find.text('02'));
    await tester.pumpAndSettle(kDoubleTapTimeout);

    final tile = tester.widget<PatchGridTile>(find.widgetWithText(PatchGridTile, '02'));
    expect(tile.selected, isTrue);
    expect(tile.loaded, isFalse);
    expect(transport.sent, isEmpty);
  });

  testWidgets('a double tap on a patch tile loads it', (tester) async {
    prepare();
    await container.read(midiConnectionProvider(profile.id).notifier).connect();

    await pumpControl(tester);
    await tester.tap(find.text('02'));
    await tester.pump(kDoubleTapTimeout ~/ 2);
    await tester.tap(find.text('02'));
    await tester.pumpAndSettle();

    expect(transport.sent, isNotEmpty);
    expect(tester.widget<PatchGridTile>(find.widgetWithText(PatchGridTile, '02')).loaded, isTrue);
  });

  testWidgets('the selected patch name shows below the pager', (tester) async {
    prepare();

    await pumpControl(tester);

    expect(find.text('Patch 1'), findsNWidgets(2)); // the default tile, and this line

    await tester.tap(find.text('02'));
    await tester.pumpAndSettle(kDoubleTapTimeout);

    expect(find.text('Patch 2'), findsNWidgets(2));
  });

  testWidgets('sending a scene highlights it and only it', (tester) async {
    prepare();
    await container.read(midiConnectionProvider(profile.id).notifier).connect();

    await pumpControl(tester);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Scene 2'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Scene 2'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Scene 1'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Scene 3'), findsOneWidget);
  });

  testWidgets('scene 1 is selected on its own once the device connects', (tester) async {
    prepare();
    await container.read(midiConnectionProvider(profile.id).notifier).connect();

    await pumpControl(tester);

    expect(find.widgetWithText(FilledButton, 'Scene 1'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Scene 2'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Scene 3'), findsOneWidget);
  });

  testWidgets('loading a patch falls back to scene 1', (tester) async {
    prepare();
    await container.read(midiConnectionProvider(profile.id).notifier).connect();

    await pumpControl(tester);
    // Move off the default before proving a patch load brings it back.
    await tester.tap(find.widgetWithText(OutlinedButton, 'Scene 3'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Scene 3'), findsOneWidget);

    await tester.tap(find.text('01'));
    await tester.pump(kDoubleTapTimeout ~/ 2);
    await tester.tap(find.text('01'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Scene 1'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Scene 3'), findsOneWidget);
  });
}
