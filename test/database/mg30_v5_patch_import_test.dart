import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_profile.dart';
import 'package:tone_vault/features/midi/devices/nux_mg30_v5/protocol/mg30_v5_patch_file.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';

import '../support/mg30_v5_patch_fixture.dart';
import '../support/repositories.dart';

const _profile = NuxMg30V5Profile();

/// A patch read off an MG-30 becoming a patch of the library.
///
/// The point is that it becomes an *ordinary* one: three scenes, the unit's
/// blocks in each, the amp model on the block's own model control. Every screen
/// written for a patch then works on it, and nothing device-specific has to be
/// taught to the editor.
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

  Future<({int imported, List<String> failures})> importFixture({
    List<int> slots = const [0],
    List<int> ampModelCodes = const [16],
    List<String> names = const ['CT-RectoBeast'],
  }) {
    final file = mg30V5PatchFile([
      for (final slot in slots)
        mg30V5PatchRecord(
          slot: slot,
          sceneNames: names,
          ampModelCodes: ampModelCodes,
        ),
    ]);
    return mg30V5PatchLibraryImporter(
      database,
    ).import(unitId: unitId, patches: readMg30V5PatchFile(file));
  }

  test('a patch arrives as a patch, with its three scenes', () async {
    final summary = await importFixture();

    expect(summary.imported, 1);
    expect(summary.failures, isEmpty);

    final patch = (await database.patchDao.patchesOf(unitId)).single;
    expect(patch.name, 'CT-RectoBeast');

    final scenes = await database.patchDao.scenesOf(patch.id);
    expect(scenes.map((scene) => scene.name), [
      'Scene 1',
      'Scene 2',
      'Scene 3',
    ]);
    // Each scene holds the unit's whole chain, which is what a V5 patch runs.
    final blocks = await pedalRepository(database).componentPedals(unitId);
    for (final scene in scenes) {
      expect(
        await database.sceneDao.scenePedalsOf(scene.id),
        hasLength(blocks.length),
      );
    }
  });

  test('the slot becomes the program number the patch loads as', () async {
    await importFixture(slots: [0, 7, 42]);

    final numbered = await midiPatchProgramRepository(
      database,
    ).numberedPatches(unitId);
    expect(numbered.map((row) => row.programNumber), [0, 7, 42]);
  });

  test('each scene keeps its own amp model', () async {
    // What Pro Scene is for: DUAL RECT, BRIT 800, then the amp bypassed.
    await importFixture(ampModelCodes: [16, 12, 0]);

    final patch = (await database.patchDao.patchesOf(unitId)).single;
    final scenes = await database.patchDao.scenesOf(patch.id);

    final codes = <double>[];
    for (final scene in scenes) {
      final controls = await database.sceneDao.sceneControlsOf(scene.id);
      final model = controls.firstWhere(
        (owned) => owned.control.name == 'Amp model',
      );
      final values = await database.sceneDao.valuesOf(scene.id);
      codes.add(
        values.firstWhere((value) => value.controlId == model.control.id).value,
      );
    }
    expect(codes, [16, 12, 0]);
  });

  test('the exact bytes are kept beside the patch', () async {
    await importFixture();

    final patch = (await database.patchDao.patchesOf(unitId)).single;
    final payload = await database.mg30PatchPayloadDao.findByPatch(patch.id);

    // Kept whole, because the decoder reads three fields out of a scene today
    // and a later one will read more without the device being needed again.
    expect(payload!.slot, 0);
    expect(payload.source, 'quicktone_file');
    expect(payload.rawRecord, hasLength(9902));
  });

  test(
    're-importing a slot replaces that patch rather than doubling it',
    () async {
      await importFixture(names: ['First read']);
      await importFixture(names: ['Second read']);

      final patches = await database.patchDao.patchesOf(unitId);
      expect(patches, hasLength(1));
      expect(patches.single.name, 'Second read');
    },
  );

  test('two slots sharing a name both arrive, told apart by slot', () async {
    // The unit puts no uniqueness rule on its slot names; the library does. The
    // slot label the unit shows is what keeps both patches.
    final summary = await importFixture(slots: [0, 5], names: ['Lead']);

    expect(summary.imported, 2);
    expect(summary.failures, isEmpty);
    final patches = await database.patchDao.patchesOf(unitId);
    expect(
      patches.map((patch) => patch.name),
      containsAll(['Lead', 'Lead 02B']),
    );
  });

  test('a unit with no blocks is refused in words', () async {
    // A multi-effects pedal logged by hand has no blocks until the device is
    // linked, and a patch has nothing to use without them.
    final bare = await pedalRepository(database).createPedal(
      const PedalDraft(
        name: 'Unlinked unit',
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
      ),
    );

    await expectLater(
      mg30V5PatchLibraryImporter(database).import(
        unitId: bare,
        patches: readMg30V5PatchFile(
          mg30V5PatchFile([mg30V5PatchRecord(slot: 0)]),
        ),
      ),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.message,
          'message',
          contains('no blocks yet'),
        ),
      ),
    );
  });
}
