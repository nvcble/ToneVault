import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_profile.dart';
import 'package:tone_vault/features/midi/data/captured_nux_mg30_v5_preset_transfer_service.dart';
import 'package:tone_vault/features/midi/data/preset_import_service.dart';

import '../support/repositories.dart';

const _profile = NuxMg30V5Profile();

/// A 222-byte preset reply named "A", which is what a physical MG-30 V5 sends.
///
/// Only the slot number and the name decode out of this length: the block bytes
/// sit at offsets confirmed on v4.0.3 alone, so the decoder reports that whole
/// region unsupported rather than guessing - see `NuxMg30V5PresetLayout`. On V5
/// the name starts on the encoded half of a character pair, so 'A' is `1, 2`.
Uint8List _v5Capture(int programNumber) {
  final bytes = List<int>.filled(222, 0);
  bytes[1] = 0x43;
  bytes[2] = 0x58;
  bytes[3] = 0x70;
  bytes[4] = 0x0B;
  bytes[5] = 0x02;
  bytes[6] = programNumber;
  bytes[167] = 1;
  bytes[168] = 2;
  return Uint8List.fromList(bytes);
}

/// What an imported patch holds when the dump could not say which blocks it
/// used.
///
/// The patch and its scene were written either way; what used to be missing was
/// the chain inside the scene, which left the user a patch with nothing in it to
/// manage.
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

  test('an imported patch holds the unit\'s whole chain', () async {
    final captures = midiPresetCaptureRepository(database);
    await captures.saveCapture(
      pedalId: unitId,
      deviceProfileId: _profile.id,
      programNumber: 7,
      rawSysEx: _v5Capture(7),
    );
    final transfer = CapturedNuxMg30V5PresetTransferService(captures, unitId);
    final presets = await transfer.importAllPresets();

    // The premise: nothing in this dump names a block.
    expect(presets.single.blocks, isEmpty);

    final summary = await presetImportService(database, transfer).importPresets(
      unitId: unitId,
      presets: presets,
      resolveDuplicate: (incoming, existing) async =>
          PresetImportDecision.overwrite,
    );
    expect(summary.imported, 1);

    final patch = (await database.patchDao.patchesOf(unitId)).single;
    final scene = (await database.patchDao.scenesOf(patch.id)).single;
    final blocks = await pedalRepository(database).componentPedals(unitId);

    // Every block of the unit, with the knobs of each one to set, so the user
    // can dial the patch they imported in rather than finding it empty.
    final inScene = await database.sceneDao.scenePedalsOf(scene.id);
    expect(inScene.map((pedal) => pedal.name), blocks.map((one) => one.name));
    expect(
      await scenePedalRepository(database).watchSceneControls(scene.id).first,
      isNotEmpty,
    );
  });
}
