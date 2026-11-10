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
import 'package:tone_vault/features/midi/hotone_ampero_mini/providers/hotone_ampero_mini_data_providers.dart';
import 'package:tone_vault/features/midi/hotone_ampero_mini/screens/hotone_ampero_mini_patch_list_screen.dart';
import 'package:tone_vault/features/midi/providers/midi_engine_providers.dart';

import '../support/fake_midi_transport.dart';

void main() {
  const profile = HotoneAmperoMiniProfile();
  late AppDatabase database;
  late ProviderContainer container;

  Future<void> pump(WidgetTester tester) async {
    database = AppDatabase(NativeDatabase.memory());
    final engine = MidiEngine()
      ..attach(
        profile: profile,
        transportBuilder: () => FakeMidiTransport(
          endpoints: const [
            MidiEndpoint(
              id: 'dev-1',
              name: 'Ampero Mini',
              type: MidiTransportType.usb,
            ),
          ],
        ),
      );
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
  }

  testWidgets('starring a slot stores it and fills the star', (tester) async {
    await pump(tester);

    await tester.tap(find.byTooltip('Add to favorites').first);
    // The write and the stream that reports it each need the real clock and a
    // frame in turn, so alternate until both have had theirs.
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }

    expect(find.byTooltip('Remove from favorites'), findsOneWidget);
    final stored = await tester.runAsync(
      () => container
          .read(hotoneAmperoMiniFavoriteRepositoryProvider)
          .watchFavoriteNumbers()
          .first,
    );
    expect(stored, [0]);
  });

  testWidgets('the favorites filter lists only starred slots', (tester) async {
    await pump(tester);
    final repository = container.read(
      hotoneAmperoMiniFavoriteRepositoryProvider,
    );
    await tester.runAsync(() => repository.setFavorite(4, isFavorite: true));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Show favorites only'));
    await tester.pumpAndSettle();

    expect(find.text('P02-2'), findsOneWidget);
    expect(find.text('P01-1'), findsNothing);
  });

  testWidgets('with no favorites the filter says so', (tester) async {
    await pump(tester);

    await tester.tap(find.byTooltip('Show favorites only'));
    await tester.pumpAndSettle();

    expect(find.text('No favorites yet'), findsOneWidget);
  });
}
