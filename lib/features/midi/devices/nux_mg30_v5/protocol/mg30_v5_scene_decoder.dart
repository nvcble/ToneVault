import 'dart:typed_data';

import '../../../../../core/errors/app_failure.dart';
import '../../../../../core/midi/profiles/nux_mg30_v5/nux_mg30_v5_block.dart';
import '../domain/mg30_scene.dart';
import 'mg30_v5_patch_layout.dart';

/// Turns one 142-byte MG-30 V5 scene into a [Mg30Scene].
///
/// Reads only the fields `Mg30V5SceneLayout` marks verified and keeps the rest
/// of the bytes whole. A field that cannot be read is reported rather than
/// guessed: a chain order that is not a permutation of the twelve blocks means
/// these bytes are not a V5 scene, and saying so beats inventing a chain.
Mg30Scene decodeMg30V5Scene(Uint8List bytes) {
  if (bytes.length != Mg30V5SceneLayout.size) {
    throw AppFailure(
      'This is not an MG-30 V5 scene: expected '
      '${Mg30V5SceneLayout.size} bytes and got ${bytes.length}.',
    );
  }

  return Mg30Scene(
    name: _name(bytes),
    ampModelCode: bytes[Mg30V5SceneLayout.ampModelOffset],
    chainOrder: _chainOrder(bytes),
    raw: Uint8List.fromList(bytes),
  );
}

/// ASCII up to the first NUL, trimmed - the unit pads the field with spaces as
/// readily as with zeros.
String _name(Uint8List bytes) {
  final codes = <int>[];
  for (var i = 0; i < Mg30V5SceneLayout.nameLength; i++) {
    final code = bytes[Mg30V5SceneLayout.nameOffset + i];
    if (code == 0) {
      break;
    }
    codes.add(code);
  }
  return String.fromCharCodes(codes).trim();
}

/// The twelve blocks in signal order.
///
/// Each byte is an index into [NuxMg30Block], whose declaration order is the one
/// the V5 MIDI chart lists the blocks in.
List<NuxMg30Block> _chainOrder(Uint8List bytes) {
  final blocks = NuxMg30Block.values;
  final order = <NuxMg30Block>[];
  final seen = <int>{};

  for (var position = 0; position < Mg30V5SceneLayout.chainOrderLength; position++) {
    final index = bytes[Mg30V5SceneLayout.chainOrderOffset + position];
    if (index >= blocks.length || !seen.add(index)) {
      throw AppFailure(
        'The signal chain in this scene does not name each of the '
        '${blocks.length} blocks exactly once, so these bytes are not an '
        'MG-30 V5 scene.',
      );
    }
    order.add(blocks[index]);
  }
  return order;
}
