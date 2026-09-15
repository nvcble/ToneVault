import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/midi/midi_support_level.dart';
import 'package:tone_vault/core/midi/preset_transfer/imported_preset.dart';
import 'package:tone_vault/core/midi/preset_transfer/mock_nux_mg30_v5_preset_transfer_service.dart';
import 'package:tone_vault/core/midi/preset_transfer/nux_mg30_v5_preset_transfer_service.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_profile.dart';
import 'package:tone_vault/features/midi/data/preset_import_service.dart';

import '../support/repositories.dart';

const _profile = NuxMg30V5Profile();

/// Returns a fixed list, ignoring [onProgress] beyond a final call - a real
/// transfer service would call it as each preset arrives, but the tests here
/// only care what the finished list produces.
class _FakeTransferService implements NuxMg30V5PresetTransferService {
  const _FakeTransferService(this.presets);

  final List<ImportedPreset> presets;

  @override
  Future<List<ImportedPreset>> importAllPresets({
    void Function(int completed, int total)? onProgress,
  }) async {
    onProgress?.call(presets.length, presets.length);
    return presets;
  }
}

Future<PresetImportDecision> _alwaysOverwrite(ImportedPreset incoming, Patch existing) async =>
    PresetImportDecision.overwrite;

Future<PresetImportDecision> _alwaysSkip(ImportedPreset incoming, Patch existing) async =>
    PresetImportDecision.skip;

void main() {
  late AppDatabase database;
  late int unitId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    unitId = await midiDeviceLinkRepository(database).createLinkedGear(_profile);
  });

  tearDown(() => database.close());

  test('imports a preset into a patch, scene and matching scene values', () async {
    const preset = ImportedPreset(
      programNumber: 5,
      name: 'Worship Lead',
      confidence: MidiSupportLevel.unknown,
      blocks: [
        ImportedBlock(label: 'Amp', modelNumber: 12, parameters: {'Amp Knob 1': 70}),
      ],
    );
    final service = presetImportService(database, const _FakeTransferService([preset]));

    final summary = await service.importPresets(
      unitId: unitId,
      presets: [preset],
      resolveDuplicate: _alwaysSkip,
    );

    expect(summary.imported, 1);
    expect(summary.overwritten, 0);
    expect(summary.skipped, 0);
    expect(summary.failures, isEmpty);

    final numbered = await midiPatchProgramRepository(database).watchNumberedPatches(unitId).first;
    expect(numbered, hasLength(1));
    expect(numbered.single.patch.name, 'Worship Lead');
    expect(numbered.single.programNumber, 5);

    final scenes = await sceneRepository(database).watchScenes(numbered.single.patch.id).first;
    expect(scenes.single.name, 'Imported');

    final blocks = await pedalRepository(database).watchComponentPedals(unitId).first;
    final ampBlock = blocks.firstWhere((pedal) => pedal.name == 'Amp');
    final scenePedals = await scenePedalRepository(database).watchScenePedals(scenes.single.id).first;
    expect(scenePedals.map((pedal) => pedal.id), contains(ampBlock.id));

    final controls = await controlRepository(database).watchControls(ampBlock.id).first;
    final modelControl = controls.firstWhere((control) => control.name == 'Amp model');
    final knobControl = controls.firstWhere((control) => control.name == 'Amp Knob 1');
    final values = await sceneValueRepository(database).watchValues(scenes.single.id).first;
    expect(
      values.firstWhere((value) => value.controlId == modelControl.id).value,
      12,
    );
    expect(
      values.firstWhere((value) => value.controlId == knobControl.id).value,
      70,
    );
  });

  test('silently skips a block that is not one of this profile\'s seeded pedals', () async {
    const preset = ImportedPreset(
      programNumber: 1,
      name: 'Odd Preset',
      confidence: MidiSupportLevel.unknown,
      blocks: [ImportedBlock(label: 'Not A Real Block', parameters: {'X': 1})],
    );
    final service = presetImportService(database, const _FakeTransferService([preset]));

    final summary = await service.importPresets(
      unitId: unitId,
      presets: [preset],
      resolveDuplicate: _alwaysSkip,
    );

    expect(summary.imported, 1);
    expect(summary.failures, isEmpty);
  });

  test('a duplicate program number, skipped, leaves the existing patch untouched', () async {
    const first = ImportedPreset(programNumber: 1, name: 'First', confidence: MidiSupportLevel.unknown);
    final service = presetImportService(database, const _FakeTransferService([first]));
    await service.importPresets(unitId: unitId, presets: [first], resolveDuplicate: _alwaysSkip);

    const again = ImportedPreset(programNumber: 1, name: 'Replacement', confidence: MidiSupportLevel.unknown);
    final summary = await service.importPresets(
      unitId: unitId,
      presets: [again],
      resolveDuplicate: _alwaysSkip,
    );

    expect(summary.imported, 0);
    expect(summary.overwritten, 0);
    expect(summary.skipped, 1);
    expect(summary.failures, isEmpty);
    final numbered = await midiPatchProgramRepository(database).watchNumberedPatches(unitId).first;
    expect(numbered.single.patch.name, 'First');
  });

  test('a duplicate program number, overwritten, replaces the existing patch', () async {
    const first = ImportedPreset(programNumber: 1, name: 'First', confidence: MidiSupportLevel.unknown);
    final service = presetImportService(database, const _FakeTransferService([first]));
    await service.importPresets(unitId: unitId, presets: [first], resolveDuplicate: _alwaysSkip);

    const again = ImportedPreset(programNumber: 1, name: 'Replacement', confidence: MidiSupportLevel.unknown);
    final summary = await service.importPresets(
      unitId: unitId,
      presets: [again],
      resolveDuplicate: _alwaysOverwrite,
    );

    expect(summary.imported, 0);
    expect(summary.overwritten, 1);
    expect(summary.skipped, 0);
    expect(summary.failures, isEmpty);
    final numbered = await midiPatchProgramRepository(database).watchNumberedPatches(unitId).first;
    expect(numbered, hasLength(1));
    expect(numbered.single.patch.name, 'Replacement');
  });

  test('a preset that fails to import is recorded as a failure, not thrown', () async {
    const first = ImportedPreset(programNumber: 1, name: 'Same Name', confidence: MidiSupportLevel.unknown);
    const second = ImportedPreset(programNumber: 2, name: 'Same Name', confidence: MidiSupportLevel.unknown);
    final service = presetImportService(database, const _FakeTransferService([first, second]));

    final summary = await service.importPresets(
      unitId: unitId,
      presets: [first, second],
      resolveDuplicate: _alwaysSkip,
    );

    expect(summary.imported, 1);
    expect(summary.failures, hasLength(1));
    expect(summary.failures.single.programNumber, 2);
  });

  test('countOverwrites counts by program number, not by name', () async {
    const first = ImportedPreset(programNumber: 1, name: 'Existing', confidence: MidiSupportLevel.unknown);
    final service = presetImportService(database, const _FakeTransferService([first]));
    await service.importPresets(unitId: unitId, presets: [first], resolveDuplicate: _alwaysSkip);

    const incoming = [
      ImportedPreset(programNumber: 1, name: 'Different Name', confidence: MidiSupportLevel.unknown),
      ImportedPreset(programNumber: 2, name: 'New Slot', confidence: MidiSupportLevel.unknown),
    ];

    expect(await service.countOverwrites(unitId, incoming), 1);
  });

  test('countOverwrites is 0 and nothing changes before importPresets runs', () async {
    const first = ImportedPreset(programNumber: 1, name: 'Existing', confidence: MidiSupportLevel.unknown);
    final service = presetImportService(database, const _FakeTransferService([first]));

    expect(await service.countOverwrites(unitId, [first]), 0);
    final numbered = await midiPatchProgramRepository(database).numberedPatches(unitId);
    expect(numbered, isEmpty);
  });

  test('fetchPresets reports progress as MockNuxMg30V5PresetTransferService reads each preset', () async {
    final service = presetImportService(
      database,
      const MockNuxMg30V5PresetTransferService(delay: Duration.zero),
    );
    final progressTicks = <int>[];

    final presets = await service.fetchPresets(onProgress: (completed, total) => progressTicks.add(completed));

    expect(presets, hasLength(3));
    expect(progressTicks, [1, 2, 3]);
  });
}
