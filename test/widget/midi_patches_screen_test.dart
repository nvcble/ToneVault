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
import 'package:tone_vault/features/midi/screens/midi_patches_screen.dart';
import 'package:tone_vault/features/midi/widgets/midi_patch_list_tile.dart';
import 'package:tone_vault/features/patches/data/patch_draft.dart';

import '../support/fake_midi_transport.dart';
import '../support/repositories.dart';
import '../support/screen_harness.dart';

/// The Patches list under the app's own theme.
///
/// The order the rows come out in is the point: the A-Z / 0-127 switch is what
/// the user picks between, and only a pumped screen shows which one the list
/// actually followed.
void main() {
  const profile = NuxMg30V5Profile();

  const endpoint = MidiEndpoint(
    id: 'dev-1',
    name: 'MG-30',
    type: MidiTransportType.usb,
  );

  late AppDatabase database;
  late MidiEngine engine;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    engine = MidiEngine();
    // Pre-attached: the screen watches the connection, and a real transport
    // would leave its scan timer running past the end of the test.
    engine.attach(
      profile: profile,
      transportBuilder: () => FakeMidiTransport(endpoints: const [endpoint]),
    );
  });

  tearDown(() async {
    engine.dispose();
    await database.close();
  });

  /// A unit with three patches, numbered so that name order and number order
  /// disagree - otherwise either sort would pass the test.
  Future<void> seedUnit() async {
    final unitId = await midiDeviceLinkRepository(
      database,
    ).createLinkedGear(profile);
    final patches = patchRepository(database);
    final numbers = midiPatchProgramRepository(database);
    for (final (name, number) in const [
      ('Zeta', 0),
      ('Ambient', 7),
      ('Mid', 127),
    ]) {
      final patchId = await patches.createPatch(unitId, PatchDraft(name: name));
      await numbers.setNumber(patchId: patchId, programNumber: number);
    }
  }

  Future<void> pumpPatches(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          midiEngineProvider.overrideWithValue(engine),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const MidiPatchesScreen(profileId: 'nux_mg30_v5'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The rows in the order the list is showing them, each as name and number.
  ///
  /// Read off the row widgets rather than the text on screen: a number field
  /// carries its own placeholder Text, which reading every Text would mistake
  /// for another patch.
  List<(String, int?)> rowsInOrder(WidgetTester tester) {
    return tester
        .widgetList<MidiPatchListTile>(find.byType(MidiPatchListTile))
        .map((row) => (row.name, row.programNumber))
        .toList();
  }

  screenTest('starts in A-Z order', (tester) async {
    await seedUnit();

    await pumpPatches(tester);

    expect(tester.takeException(), isNull);
    expect(rowsInOrder(tester), [('Ambient', 7), ('Mid', 127), ('Zeta', 0)]);
  });

  screenTest('switching to 0-127 puts them in slot order', (tester) async {
    await seedUnit();
    await pumpPatches(tester);

    await tester.tap(find.text('0-127'));
    await tester.pumpAndSettle();

    // Zeta holds slot 0, the device's first - which the old 1-128 numbering
    // could not store at all.
    expect(rowsInOrder(tester), [('Zeta', 0), ('Ambient', 7), ('Mid', 127)]);
  });

  screenTest('offers the link prompt when the unit is not gear yet', (
    tester,
  ) async {
    await pumpPatches(tester);

    expect(find.text('Add ${profile.displayName} as gear'), findsOneWidget);
  });
}
