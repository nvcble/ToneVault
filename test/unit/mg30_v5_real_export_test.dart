import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/features/midi/devices/nux_mg30_v5/protocol/mg30_v5_patch_file.dart';

/// Runs the decoder over a real QuickTone export, when one is to hand.
///
/// Skipped unless `MG30_EXPORT` points at a `.mg30patch` file, so this is not a
/// test that only passes on one machine - but it is the one that reads actual
/// device data, which no fixture can stand in for:
///
/// ```
/// MG30_EXPORT=/path/to/MG30AllPatch.mg30patch flutter test \
///   test/unit/mg30_v5_real_export_test.dart
/// ```
void main() {
  final path = Platform.environment['MG30_EXPORT'];

  test('every patch of a real export decodes', () {
    final patches = readMg30V5PatchFile(File(path!).readAsBytesSync());

    expect(patches, hasLength(128));
    // Slots are consecutive and the file holds the whole unit.
    expect(patches.map((patch) => patch.slot), List.generate(128, (i) => i));
    // A name and a twelve-block chain out of every single patch: the two fields
    // that say the record stride and the scene stride are right.
    expect(patches.every((patch) => patch.name.isNotEmpty), isTrue);
    expect(
      patches.every(
        (patch) => patch.scenes.every((scene) => scene.chainOrder.length == 12),
      ),
      isTrue,
    );
    // Amp models land inside the catalog read out of QuickTone, or read as
    // bypass - never as a code with no model behind it.
    expect(
      patches.every(
        (patch) => patch.scenes.every(
          (scene) => scene.isAmpBypassed || scene.ampModelName != null,
        ),
      ),
      isTrue,
    );

    // ignore: avoid_print
    print(
      'decoded ${patches.length} patches; '
      '${patches.where((p) => p.hasUserIr).length} carry a user IR; '
      '${patches.where((p) => p.scenesDiffer).length} have differing scenes',
    );
  }, skip: path == null ? 'Set MG30_EXPORT to a .mg30patch file' : null);
}
