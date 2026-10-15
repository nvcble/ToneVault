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
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_profile.dart';
import 'package:tone_vault/features/midi/providers/midi_engine_providers.dart';
import 'package:tone_vault/features/midi/screens/live_control_screen.dart';
import 'package:tone_vault/features/patches/data/patch_draft.dart';

import '../support/fake_midi_transport.dart';
import '../support/repositories.dart';

/// Live Control held both ways up.
///
/// The device control page it is opened from is locked landscape, so this one
/// is laid out on a height half what it was built for: it has to give way
/// rather than overflow, which in a test is an exception rather than a striped
/// screen.
void main() {
  const profile = NuxMg30V5Profile();
  const endpoint = MidiEndpoint(
    id: 'dev-1',
    name: 'MG-30',
    type: MidiTransportType.usb,
  );

  late AppDatabase database;
  late MidiEngine engine;
  late ProviderContainer container;

  /// One container for the test, torn down with the database it reads - a
  /// `ProviderScope` inside the tree disposes its own on the first frame and
  /// leaves drift's stream teardown pending behind it.
  void prepare() {
    database = AppDatabase(NativeDatabase.memory());
    // Pre-attached: the screen watches the connection, and a real transport
    // would leave its scan timer running past the end of the test.
    engine = MidiEngine()
      ..attach(
        profile: profile,
        transportBuilder: () => FakeMidiTransport(endpoints: const [endpoint]),
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
  }

  Future<void> seedUnit() async {
    final unitId = await midiDeviceLinkRepository(
      database,
    ).createLinkedGear(profile);
    final patchId = await patchRepository(
      database,
    ).createPatch(unitId, PatchDraft(name: 'Ambient'));
    await midiPatchProgramRepository(
      database,
    ).setNumber(patchId: patchId, programNumber: 7);
  }

  Future<void> pumpLiveControl(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const LiveControlScreen(profileId: 'nux_mg30_v5'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('fits a phone held sideways, scenes and steps and all', (
    tester,
  ) async {
    prepare();
    await seedUnit();

    await pumpLiveControl(tester, const Size(800, 360));

    expect(find.text('Scene 1'), findsOneWidget);
    expect(find.text('Previous patch'), findsOneWidget);
    expect(find.text('Next patch'), findsOneWidget);
  });

  testWidgets('and a phone held upright', (tester) async {
    prepare();
    await seedUnit();

    await pumpLiveControl(tester, const Size(400, 800));

    expect(find.text('Scene 1'), findsOneWidget);
    expect(find.text('Next patch'), findsOneWidget);
  });
}
