import 'dart:typed_data';

import '../../../../../core/errors/app_failure.dart';
import '../domain/mg30_patch.dart';
import 'mg30_v5_patch_layout.dart';
import 'mg30_v5_scene_decoder.dart';

/// Reads a `.mg30patch` file - what QuickTone writes when it exports one patch
/// or a whole backup - into [Mg30Patch]es.
///
/// This is the one path into the app that needs no hardware and no unverified
/// protocol: the file layout is established byte for byte, so a patch library
/// imported this way is as trustworthy as the device's own export.
///
/// The decode is strict. A file that is not a whole number of records, or whose
/// slots do not read as slots, is refused in words rather than half-imported.
List<Mg30Patch> readMg30V5PatchFile(Uint8List bytes) {
  final count = Mg30V5PatchRecord.patchCount(bytes.length);
  if (count == null) {
    throw AppFailure(
      'This is not an MG-30 patch file: ${bytes.length} bytes is not a whole '
      'number of ${Mg30V5PatchRecord.size}-byte patches.',
    );
  }

  return [
    for (var index = 0; index < count; index++)
      _readRecord(bytes, index * Mg30V5PatchRecord.size, index),
  ];
}

Mg30Patch _readRecord(Uint8List bytes, int start, int index) {
  final record = Uint8List.sublistView(
    bytes,
    start,
    start + Mg30V5PatchRecord.size,
  );
  final slot = record[Mg30V5PatchRecord.slotOffset];
  if (slot > 127) {
    throw AppFailure(
      'Patch ${index + 1} of this file reads slot $slot, which the MG-30 does '
      'not have - the file is damaged or is not a V5 export.',
    );
  }

  return Mg30Patch(
    slot: slot,
    scenes: [
      for (var scene = 0; scene < Mg30V5PatchRecord.sceneCount; scene++)
        decodeMg30V5Scene(_sceneBytes(record, scene)),
    ],
    userIrName: _userIrName(record),
    raw: Uint8List.fromList(record),
  );
}

Uint8List _sceneBytes(Uint8List record, int scene) {
  final start =
      Mg30V5PatchRecord.firstSceneOffset + scene * Mg30V5SceneLayout.size;
  return Uint8List.sublistView(record, start, start + Mg30V5SceneLayout.size);
}

/// Null when the patch loads a factory cabinet, which is what the flag says.
String? _userIrName(Uint8List record) {
  if (record[Mg30V5PatchRecord.userIrFlagOffset] == 0) {
    return null;
  }
  final codes = <int>[];
  for (var i = 0; i < Mg30V5PatchRecord.userIrNameLength; i++) {
    final code = record[Mg30V5PatchRecord.userIrNameOffset + i];
    if (code == 0) {
      break;
    }
    codes.add(code);
  }
  final name = String.fromCharCodes(codes).trim();
  return name.isEmpty ? null : name;
}
