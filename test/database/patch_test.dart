import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/patches/data/patch_draft.dart';
import 'package:tone_vault/features/patches/data/patch_repository.dart';
import 'package:tone_vault/features/patches/data/scene_repository.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import '../support/repositories.dart';

/// The patches of a multi-effects unit and the scenes inside them.
///
/// One patch is what the unit is switched to; its scenes are the sounds within
/// it. What a scene uses and where its knobs sit is `scene_pedal_test.dart` and
/// `scene_setting_test.dart`.
void main() {
  late AppDatabase database;
  late PatchRepository patches;
  late SceneRepository scenes;
  late int unitId;
  final now = DateTime.utc(2026, 8, 20, 10);

  /// A refusal the user can read, rather than a raw driver exception.
  Matcher failsWith(String message) => throwsA(
    isA<AppFailure>().having((failure) => failure.message, 'message', message),
  );

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    patches = patchRepository(database, clock: () => now);
    scenes = sceneRepository(database, clock: () => now);

    unitId = await pedalRepository(database).createPedal(
      const PedalDraft(
        name: 'Valeton GP-200',
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
      ),
    );
  });

  tearDown(() => database.close());

  test('a patch is stored under the unit it is on', () async {
    final patchId = await patches.createPatch(
      unitId,
      const PatchDraft(name: '  Worship Clean ', notes: '  Second service  '),
    );

    final patch = await database.patchDao.findPatch(patchId);
    expect(patch!.pedalId, unitId);
    expect(patch.name, 'Worship Clean');
    expect(patch.notes, 'Second service');
    expect(patch.createdAt, now);
    expect(patch.updatedAt, now);
  });

  test('patches read back in name order, whatever their case', () async {
    for (final name in ['worship clean', 'Ambient', 'Lead']) {
      await patches.createPatch(unitId, PatchDraft(name: name));
    }

    final listed = await patches.watchPatches(unitId).first;
    expect(listed.map((patch) => patch.name), [
      'Ambient',
      'Lead',
      'worship clean',
    ]);
  });

  test('a unit cannot have two patches of the same name', () async {
    await patches.createPatch(unitId, const PatchDraft(name: 'Worship Clean'));

    // Checked case-insensitively: two patches the user cannot tell apart are two
    // patches they will pick the wrong one of.
    expect(
      () =>
          patches.createPatch(unitId, const PatchDraft(name: 'worship clean')),
      failsWith('This unit already has a patch called "worship clean".'),
    );
  });

  test('a patch may be renamed to what it is already called', () async {
    final patchId = await patches.createPatch(
      unitId,
      const PatchDraft(name: 'Worship Clean'),
    );

    // Its own name does not clash with itself, or rewriting only the notes would
    // be impossible.
    await patches.updatePatch(
      patchId,
      const PatchDraft(name: 'Worship Clean', notes: 'Both services'),
    );

    final patch = await database.patchDao.findPatch(patchId);
    expect(patch!.notes, 'Both services');
  });

  test('a scene is stored under the patch it is a sound of', () async {
    final patchId = await patches.createPatch(
      unitId,
      const PatchDraft(name: 'Worship Clean'),
    );

    final sceneId = await scenes.createScene(
      patchId,
      const SceneDraft(name: 'Verse'),
    );

    final scene = await database.patchDao.findScene(sceneId);
    expect(scene!.patchId, patchId);
    expect(scene.name, 'Verse');
    expect(scene.notes, isNull);
  });

  test('two patches may each have a scene of the same name', () async {
    final clean = await patches.createPatch(
      unitId,
      const PatchDraft(name: 'Worship Clean'),
    );
    final lead = await patches.createPatch(
      unitId,
      const PatchDraft(name: 'Worship Lead'),
    );

    await scenes.createScene(clean, const SceneDraft(name: 'Verse'));
    await scenes.createScene(lead, const SceneDraft(name: 'Verse'));

    // The names only have to pick out one sound within a patch, which is why the
    // unique key is on the patch rather than on the unit.
    expect(await scenes.watchScenes(clean).first, hasLength(1));
    expect(await scenes.watchScenes(lead).first, hasLength(1));
  });

  test('one patch cannot have two scenes of the same name', () async {
    final patchId = await patches.createPatch(
      unitId,
      const PatchDraft(name: 'Worship Clean'),
    );
    await scenes.createScene(patchId, const SceneDraft(name: 'Verse'));

    expect(
      () => scenes.createScene(patchId, const SceneDraft(name: 'verse')),
      failsWith('This patch already has a scene called "verse".'),
    );
  });

  test('deleting a patch takes its scenes with it', () async {
    final patchId = await patches.createPatch(
      unitId,
      const PatchDraft(name: 'Worship Clean'),
    );
    await scenes.createScene(patchId, const SceneDraft(name: 'Verse'));

    await patches.deletePatch(patchId);

    // `scenes` cascades from `patches`: a sound has no meaning apart from the
    // patch it is a sound of.
    expect(await database.patchDao.scenesOf(patchId), isEmpty);
    expect(await patches.watchPatches(unitId).first, isEmpty);
  });

  test('a unit with a patch on it cannot be deleted', () async {
    await patches.createPatch(unitId, const PatchDraft(name: 'Worship Clean'));

    // `patches` references `pedals` with ON DELETE RESTRICT, the same rule that
    // keeps a pedal with configurations: gear is retired, not erased.
    expect(
      () => pedalRepository(database).deletePedal(unitId),
      throwsA(isA<AppFailure>()),
    );
  });

  test('a scene of a patch that is gone is refused, in words', () async {
    final patchId = await patches.createPatch(
      unitId,
      const PatchDraft(name: 'Worship Clean'),
    );
    await patches.deletePatch(patchId);

    expect(
      () => scenes.createScene(patchId, const SceneDraft(name: 'Verse')),
      failsWith('That patch no longer exists.'),
    );
  });

  test('editing something already deleted says so plainly', () async {
    expect(
      () => patches.updatePatch(404, const PatchDraft(name: 'Worship Clean')),
      failsWith('That patch no longer exists.'),
    );
    expect(
      () => scenes.deleteScene(404),
      failsWith('That scene no longer exists.'),
    );
  });

  test('a blank name is refused before anything is written', () async {
    expect(
      () => patches.createPatch(unitId, const PatchDraft(name: '   ')),
      failsWith('Enter a patch name.'),
    );
    expect(await patches.watchPatches(unitId).first, isEmpty);
  });
}
