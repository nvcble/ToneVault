import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_block.dart';
import 'package:tone_vault/features/midi/devices/nux_mg30_v5/protocol/mg30_v5_patch_file.dart';
import 'package:tone_vault/features/midi/devices/nux_mg30_v5/protocol/mg30_v5_patch_layout.dart';

import '../support/mg30_v5_patch_fixture.dart';

/// What the app reads out of a QuickTone `.mg30patch` export.
///
/// The layout is established byte for byte against a real export of a V5.0.2
/// unit (see `docs/nux_mg30_v5_patch_format.md`), so these tests are about the
/// decoder honouring it - and refusing anything that is not it, rather than
/// half-importing a file it does not understand.
void main() {
  test('a patch carries three complete scenes, not one and two masks', () {
    final patches = readMg30V5PatchFile(
      mg30V5PatchFile([mg30V5PatchRecord(slot: 0)]),
    );

    final patch = patches.single;
    expect(patch.slot, 0);
    expect(patch.scenes, hasLength(3));
    expect(patch.name, 'CT-RectoBeast');
    expect(patch.raw, hasLength(Mg30V5PatchRecord.size));
  });

  test('each scene keeps its own amp model and reads its catalog name', () {
    // What Pro Scene is for: three sounds in one patch. 16 is DUAL RECT and 12
    // is BRIT 800 in the model catalog read out of NUX's own editor.
    final patches = readMg30V5PatchFile(
      mg30V5PatchFile([
        mg30V5PatchRecord(slot: 3, ampModelCodes: [16, 12, 0]),
      ]),
    );

    final scenes = patches.single.scenes;
    expect(scenes.map((scene) => scene.ampModelCode), [16, 12, 0]);
    expect(scenes.map((scene) => scene.ampModelName), [
      'DUAL RECT',
      'BRIT 800',
      null,
    ]);
    // Code 0 is bypass, which QuickTone lists ahead of model 1 for every block.
    expect(scenes.last.isAmpBypassed, isTrue);
    expect(patches.single.scenesDiffer, isTrue);
  });

  test('the signal chain reads as the blocks it names, in order', () {
    final patch = readMg30V5PatchFile(
      mg30V5PatchFile([mg30V5PatchRecord(slot: 1)]),
    ).single;

    expect(patch.scenes.first.chainOrder, [
      NuxMg30Block.noiseGate,
      NuxMg30Block.wah,
      NuxMg30Block.compressor,
      NuxMg30Block.effect,
      NuxMg30Block.amp,
      NuxMg30Block.ir,
      NuxMg30Block.eq,
      NuxMg30Block.sendReturn,
      NuxMg30Block.modulation,
      NuxMg30Block.delay,
      NuxMg30Block.reverb,
      NuxMg30Block.volume,
    ]);
  });

  test('a user IR is reported by name, a factory cabinet as none', () {
    final file = mg30V5PatchFile([
      mg30V5PatchRecord(slot: 0, userIrName: 'CHPBOGIE212'),
      mg30V5PatchRecord(slot: 1),
    ]);

    final patches = readMg30V5PatchFile(file);
    expect(patches.first.userIrName, 'CHPBOGIE212');
    expect(patches.first.hasUserIr, isTrue);
    expect(patches.last.userIrName, isNull);
  });

  test('a whole library reads back in slot order', () {
    final file = mg30V5PatchFile([
      for (var slot = 0; slot < 8; slot++)
        mg30V5PatchRecord(slot: slot, sceneNames: ['Patch $slot']),
    ]);

    final patches = readMg30V5PatchFile(file);
    expect(patches.map((patch) => patch.slot), [0, 1, 2, 3, 4, 5, 6, 7]);
    expect(patches.last.name, 'Patch 7');
  });

  group('refuses what it does not understand, in words', () {
    test('a file that is not a whole number of patches', () {
      expect(
        () => readMg30V5PatchFile(Uint8List(Mg30V5PatchRecord.size + 7)),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.message,
            'message',
            contains('not a whole number'),
          ),
        ),
      );
    });

    test('a chain that does not name each block exactly once', () {
      // A truncated download, or another device's file: the bytes are the right
      // length and still not a V5 scene.
      final record = mg30V5PatchRecord(
        slot: 0,
        chainOrder: const [0, 0, 1, 2, 3, 9, 4, 10, 6, 7, 8, 11],
      );

      expect(
        () => readMg30V5PatchFile(mg30V5PatchFile([record])),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.message,
            'message',
            contains('exactly once'),
          ),
        ),
      );
    });

    test('a slot number the MG-30 does not have', () {
      final record = mg30V5PatchRecord(slot: 0);
      record[Mg30V5PatchRecord.slotOffset] = 200;

      expect(
        () => readMg30V5PatchFile(mg30V5PatchFile([record])),
        throwsA(isA<AppFailure>()),
      );
    });
  });
}
