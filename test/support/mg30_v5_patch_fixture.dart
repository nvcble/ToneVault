import 'dart:typed_data';

import 'package:tone_vault/features/midi/devices/nux_mg30_v5/protocol/mg30_v5_patch_layout.dart';

/// A patch record laid out the way QuickTone's export does - spelled out here
/// rather than read from a real file, so the tests describe the format on
/// purpose and run on any machine.
///
/// [chainOrder] defaults to the order one real export used for slot 0:
/// gate, wah, compressor, effect, amp, cabinet, EQ, loop, modulation, delay,
/// reverb, volume.
Uint8List mg30V5PatchRecord({
  required int slot,
  List<String> sceneNames = const ['CT-RectoBeast'],
  List<int> ampModelCodes = const [16],
  List<int> chainOrder = const [5, 0, 1, 2, 3, 9, 4, 10, 6, 7, 8, 11],
  String? userIrName,
}) {
  final record = Uint8List(Mg30V5PatchRecord.size);
  record[Mg30V5PatchRecord.slotOffset] = slot;

  for (var scene = 0; scene < Mg30V5PatchRecord.sceneCount; scene++) {
    final start =
        Mg30V5PatchRecord.firstSceneOffset + scene * Mg30V5SceneLayout.size;
    record[start + Mg30V5SceneLayout.ampModelOffset] =
        ampModelCodes[scene % ampModelCodes.length];
    for (var i = 0; i < chainOrder.length; i++) {
      record[start + Mg30V5SceneLayout.chainOrderOffset + i] = chainOrder[i];
    }
    final name = sceneNames[scene % sceneNames.length];
    record.setRange(
      start + Mg30V5SceneLayout.nameOffset,
      start + Mg30V5SceneLayout.nameOffset + name.length,
      name.codeUnits,
    );
  }

  if (userIrName != null) {
    record[Mg30V5PatchRecord.userIrFlagOffset] = 1;
    record.setRange(
      Mg30V5PatchRecord.userIrNameOffset,
      Mg30V5PatchRecord.userIrNameOffset + userIrName.length,
      userIrName.codeUnits,
    );
  }
  return record;
}

/// Several records back to back, which is what a whole-library export is.
Uint8List mg30V5PatchFile(List<Uint8List> records) {
  final file = Uint8List(records.length * Mg30V5PatchRecord.size);
  for (var i = 0; i < records.length; i++) {
    file.setRange(i * Mg30V5PatchRecord.size, (i + 1) * Mg30V5PatchRecord.size,
        records[i]);
  }
  return file;
}
