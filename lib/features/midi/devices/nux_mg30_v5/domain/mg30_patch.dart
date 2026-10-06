import 'dart:typed_data';

import 'mg30_scene.dart';

/// One MG-30 V5 patch: the slot it lives in, its three Pro Scenes, and the user
/// IR it carries if it has one.
///
/// The patch has no name of its own - each scene carries the name, and the unit
/// keeps all three in step. [name] reads the first, which is what the Patch
/// Browser shows.
class Mg30Patch {
  const Mg30Patch({
    required this.slot,
    required this.scenes,
    required this.raw,
    this.userIrName,
  });

  /// 0-127, as the device numbers its slots. Bank and letter (01A..32D) are a
  /// presentation of this, not a second fact.
  final int slot;

  /// Always three, in Pro Scene order.
  final List<Mg30Scene> scenes;

  /// The whole patch record as stored, user IR included - kept so a patch can be
  /// written back byte-faithfully and re-decoded by a later decoder.
  final Uint8List raw;

  /// The name of the user IR this patch loads, or null when it uses a factory
  /// cabinet.
  final String? userIrName;

  String get name => scenes.first.name;

  bool get hasUserIr => userIrName != null;

  /// Whether the three scenes hold different sounds.
  ///
  /// False means the patch has the same sound in all three, which is how every
  /// patch of the first export read - not evidence that the device cannot do
  /// otherwise.
  bool get scenesDiffer =>
      scenes.any((scene) => !_sameBytes(scene.raw, scenes.first.raw));

  static bool _sameBytes(Uint8List a, Uint8List b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
