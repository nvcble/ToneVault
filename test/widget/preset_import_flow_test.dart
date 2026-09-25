import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/midi/midi_support_level.dart';
import 'package:tone_vault/core/midi/preset_transfer/imported_preset.dart';
import 'package:tone_vault/core/midi/preset_transfer/nux_mg30_v5_preset_transfer_service.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_profile.dart';
import 'package:tone_vault/features/midi/data/preset_import_service.dart';
import 'package:tone_vault/features/midi/widgets/preset_import_flow.dart';
import 'package:tone_vault/features/patches/data/patch_draft.dart';

import '../support/repositories.dart';

const _profile = NuxMg30V5Profile();

class _FakeTransferService implements NuxMg30V5PresetTransferService {
  const _FakeTransferService(this.presets);

  final List<ImportedPreset> presets;

  @override
  Future<List<ImportedPreset>> importAllPresets({
    void Function(int completed, int total)? onProgress,
  }) async => presets;
}

/// One dialog for the whole batch, not one per conflicting patch - see the
/// MIDI module brief's duplicate-handling requirement.
void main() {
  late AppDatabase database;
  late int unitId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    unitId = await midiDeviceLinkRepository(
      database,
    ).createLinkedGear(_profile);
  });

  tearDown(() => database.close());

  Future<void> pumpFlow(
    WidgetTester tester,
    PresetImportService service,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PresetImportFlow(unitId: unitId, service: service),
        ),
      ),
    );
    await tester.tap(find.text('Scan Device for Presets'));
    await tester.pumpAndSettle();
  }

  testWidgets('Cancel All leaves the library exactly as it was', (
    tester,
  ) async {
    final patchId = await patchRepository(
      database,
    ).createPatch(unitId, const PatchDraft(name: 'Old Lead'));
    await midiPatchProgramRepository(
      database,
    ).setNumber(patchId: patchId, programNumber: 1);
    const presets = [
      ImportedPreset(
        programNumber: 1,
        name: 'New Lead',
        confidence: MidiSupportLevel.unknown,
      ),
      ImportedPreset(
        programNumber: 2,
        name: 'New Clean',
        confidence: MidiSupportLevel.unknown,
      ),
    ];
    final service = presetImportService(
      database,
      const _FakeTransferService(presets),
    );
    await pumpFlow(tester, service);

    await tester.tap(find.text('Import 2 presets'));
    await tester.pumpAndSettle();
    expect(find.text('Overwrite All (1)'), findsOneWidget);

    await tester.tap(find.text('Cancel All'));
    await tester.pumpAndSettle();

    // Back on the review list, nothing imported.
    expect(find.text('Import 2 presets'), findsOneWidget);
    final numbered = await midiPatchProgramRepository(
      database,
    ).numberedPatches(unitId);
    expect(numbered.single.patch.name, 'Old Lead');
  });

  testWidgets('Overwrite All replaces every conflict without asking again', (
    tester,
  ) async {
    final patchId = await patchRepository(
      database,
    ).createPatch(unitId, const PatchDraft(name: 'Old Lead'));
    await midiPatchProgramRepository(
      database,
    ).setNumber(patchId: patchId, programNumber: 1);
    const presets = [
      ImportedPreset(
        programNumber: 1,
        name: 'New Lead',
        confidence: MidiSupportLevel.unknown,
      ),
      ImportedPreset(
        programNumber: 2,
        name: 'New Clean',
        confidence: MidiSupportLevel.unknown,
      ),
    ];
    final service = presetImportService(
      database,
      const _FakeTransferService(presets),
    );
    await pumpFlow(tester, service);

    await tester.tap(find.text('Import 2 presets'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Overwrite All (1)'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Imported 1, overwritten 1, skipped 0.'),
      findsOneWidget,
    );
    final numbered = await midiPatchProgramRepository(
      database,
    ).numberedPatches(unitId);
    expect(
      numbered.map((row) => row.patch.name),
      containsAll(['New Lead', 'New Clean']),
    );
  });

  testWidgets('no dialog at all when nothing would be overwritten', (
    tester,
  ) async {
    const presets = [
      ImportedPreset(
        programNumber: 1,
        name: 'New Lead',
        confidence: MidiSupportLevel.unknown,
      ),
    ];
    final service = presetImportService(
      database,
      const _FakeTransferService(presets),
    );
    await pumpFlow(tester, service);

    await tester.tap(find.text('Import 1 presets'));
    await tester.pumpAndSettle();

    expect(find.text('Import Presets'), findsNothing);
    expect(
      find.textContaining('Imported 1, overwritten 0, skipped 0.'),
      findsOneWidget,
    );
  });
}
