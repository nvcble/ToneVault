import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/midi/midi_support_level.dart';
import 'package:tone_vault/features/midi/data/captured_nux_mg30_v5_preset_transfer_service.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';

import '../support/repositories.dart';

/// A valid 218-byte "get preset data" reply for [programNumber], with a
/// packed name of "AB" at the name offset.
Uint8List _validCapture(int programNumber) {
  final bytes = List<int>.filled(218, 0);
  bytes[1] = 0x43;
  bytes[2] = 0x58;
  bytes[3] = 0x70;
  bytes[4] = 0x0B;
  bytes[5] = 0x02;
  bytes[6] = programNumber;
  bytes[165] = 0x41; // 'A'
  bytes[166] = 1;
  bytes[167] = 4; // 'B'
  return Uint8List.fromList(bytes);
}

void main() {
  late AppDatabase database;
  late int unitId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    unitId = await pedalRepository(database).createPedal(
      const PedalDraft(
        name: 'NUX MG-30 (V5)',
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
      ),
    );
  });

  tearDown(() => database.close());

  test('decodes every saved capture into an ImportedPreset', () async {
    final captures = midiPresetCaptureRepository(database);
    await captures.saveCapture(
      pedalId: unitId,
      deviceProfileId: 'nux_mg30_v5',
      programNumber: 5,
      rawSysEx: _validCapture(5),
    );
    final service = CapturedNuxMg30V5PresetTransferService(captures, unitId);

    final presets = await service.importAllPresets();

    expect(presets, hasLength(1));
    expect(presets.single.programNumber, 5);
    expect(presets.single.name, 'AB');
    expect(presets.single.confidence, MidiSupportLevel.needsHardwareVerification);
  });

  test('skips a capture that does not decode instead of throwing', () async {
    final captures = midiPresetCaptureRepository(database);
    await captures.saveCapture(
      pedalId: unitId,
      deviceProfileId: 'nux_mg30_v5',
      programNumber: 1,
      rawSysEx: Uint8List.fromList([0x00, 0x01]), // too short to be a real dump
    );
    await captures.saveCapture(
      pedalId: unitId,
      deviceProfileId: 'nux_mg30_v5',
      programNumber: 2,
      rawSysEx: _validCapture(2),
    );
    final service = CapturedNuxMg30V5PresetTransferService(captures, unitId);

    final presets = await service.importAllPresets();

    expect(presets.map((p) => p.programNumber), [2]);
  });

  test('reports progress across every stored capture, decodable or not', () async {
    final captures = midiPresetCaptureRepository(database);
    await captures.saveCapture(
      pedalId: unitId,
      deviceProfileId: 'nux_mg30_v5',
      programNumber: 1,
      rawSysEx: Uint8List.fromList([0x00]),
    );
    await captures.saveCapture(
      pedalId: unitId,
      deviceProfileId: 'nux_mg30_v5',
      programNumber: 2,
      rawSysEx: _validCapture(2),
    );
    final service = CapturedNuxMg30V5PresetTransferService(captures, unitId);
    final progress = <(int, int)>[];

    await service.importAllPresets(onProgress: (completed, total) => progress.add((completed, total)));

    expect(progress, [(1, 2), (2, 2)]);
  });
}
