import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/theme/app_theme.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/database_provider.dart';
import 'package:tone_vault/core/midi/midi_endpoint.dart';
import 'package:tone_vault/core/midi/midi_engine.dart';
import 'package:tone_vault/core/midi/midi_transport_type.dart';
import 'package:tone_vault/core/midi/profiles/hotone_ampero_mini/hotone_ampero_mini_profile.dart';
import 'package:tone_vault/features/midi/hotone_ampero_mini/screens/hotone_ampero_mini_patch_list_screen.dart';
import 'package:tone_vault/features/midi/providers/midi_engine_providers.dart';

import '../support/fake_midi_transport.dart';

void main() {
  testWidgets('Read pedal names opens a sheet with a Start button', (
    tester,
  ) async {
    const profile = HotoneAmperoMiniProfile();
    const endpoint = MidiEndpoint(
      id: 'dev-1',
      name: 'Ampero Mini',
      type: MidiTransportType.usb,
    );
    final database = AppDatabase(NativeDatabase.memory());
    final transport = FakeMidiTransport(endpoints: const [endpoint]);
    final engine = MidiEngine()
      ..attach(profile: profile, transportBuilder: () => transport);
    final container = ProviderContainer(
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
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const HotoneAmperoMiniPatchListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Read pedal names'));
    await tester.pumpAndSettle();

    expect(find.text('Read names from pedal'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });
}
