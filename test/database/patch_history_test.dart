import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/change_log_dao.dart';
import 'package:tone_vault/core/enums/change_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/patches/data/patch_draft.dart';
import 'package:tone_vault/features/patches/data/patch_repository.dart';
import 'package:tone_vault/features/patches/data/scene_repository.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import '../support/broken_change_log.dart';
import '../support/repositories.dart';

/// What naming, renaming and losing a patch or a scene leaves in the history.
///
/// The patches themselves are `patch_test.dart`; the positions inside a scene are
/// `scene_setting_test.dart`. Everything here is filed under the unit, because the
/// unit is the pedal whose timeline the user reads.
void main() {
  late AppDatabase database;
  late PatchRepository patches;
  late SceneRepository scenes;
  late int unitId;
  final now = DateTime.utc(2026, 8, 20, 10);

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

  Future<List<ChangeLog>> history() => database.changeLogDao.entriesOf(unitId);

  Future<List<ChangeLog>> entriesOfType(ChangeType type) async =>
      (await history()).where((entry) => entry.changeType == type).toList();

  Future<int> addPatch([String name = 'Worship Clean']) =>
      patches.createPatch(unitId, PatchDraft(name: name));

  test('a new patch is recorded under the unit that holds it', () async {
    await addPatch();

    final created = (await entriesOfType(ChangeType.patchCreated)).single;
    expect(created.pedalId, unitId);
    expect(created.configurationName, 'Worship Clean');
    // A patch has no `configurations` row, so there is nothing to point at: the
    // name is what carries the entry.
    expect(created.configurationId, isNull);
    expect(created.createdAt, now);
  });

  test('renaming a patch records what it was called before', () async {
    final patchId = await addPatch();

    await patches.updatePatch(patchId, const PatchDraft(name: 'Sunday Clean'));

    final renamed = (await entriesOfType(ChangeType.patchRenamed)).single;
    expect(renamed.oldText, 'Worship Clean');
    expect(renamed.newText, 'Sunday Clean');
    expect(renamed.configurationName, 'Sunday Clean');
  });

  test('rewriting only the notes is not a rename', () async {
    final patchId = await addPatch();

    await patches.updatePatch(
      patchId,
      const PatchDraft(name: 'Worship Clean', notes: 'Both services'),
    );

    // Nothing was renamed, and an entry saying otherwise would bury the renames
    // that did happen.
    expect(await entriesOfType(ChangeType.patchRenamed), isEmpty);
  });

  test('a deleted patch keeps its name in the entry', () async {
    final patchId = await addPatch();

    await patches.deletePatch(patchId);

    final deleted = (await entriesOfType(ChangeType.patchDeleted)).single;
    expect(deleted.configurationName, 'Worship Clean');
    expect(deleted.pedalId, unitId);
  });

  test('the scenes a deleted patch took with it are not listed', () async {
    final patchId = await addPatch();
    await scenes.createScene(patchId, const SceneDraft(name: 'Verse'));
    await scenes.createScene(patchId, const SceneDraft(name: 'Chorus'));

    await patches.deletePatch(patchId);

    // The patch going is the event. A page of "Verse deleted, Chorus deleted"
    // under it would only hide it.
    expect(await entriesOfType(ChangeType.sceneDeleted), isEmpty);
  });

  test('a scene is recorded by its patch and its own name', () async {
    final patchId = await addPatch();

    final sceneId = await scenes.createScene(
      patchId,
      const SceneDraft(name: 'Verse'),
    );
    await scenes.updateScene(sceneId, const SceneDraft(name: 'Chorus'));
    await scenes.deleteScene(sceneId);

    // Two patches may each have a "Verse", so the patch is part of the name on
    // both sides of the rename.
    expect(
      (await entriesOfType(ChangeType.sceneCreated)).single.configurationName,
      'Worship Clean · Verse',
    );
    final renamed = (await entriesOfType(ChangeType.sceneRenamed)).single;
    expect(renamed.oldText, 'Worship Clean · Verse');
    expect(renamed.newText, 'Worship Clean · Chorus');
    expect(
      (await entriesOfType(ChangeType.sceneDeleted)).single.configurationName,
      'Worship Clean · Chorus',
    );
  });

  test('rewriting only a scene\'s notes is not a rename either', () async {
    final patchId = await addPatch();
    final sceneId = await scenes.createScene(
      patchId,
      const SceneDraft(name: 'Verse'),
    );

    await scenes.updateScene(
      sceneId,
      const SceneDraft(name: 'Verse', notes: 'Capo 2'),
    );

    expect(await entriesOfType(ChangeType.sceneRenamed), isEmpty);
  });

  test('a name that is refused leaves the history alone', () async {
    await addPatch();
    final before = (await history()).length;

    await expectLater(
      patches.createPatch(unitId, const PatchDraft(name: 'worship clean')),
      throwsA(isA<AppFailure>()),
    );

    expect(await history(), hasLength(before));
  });

  test('a patch that cannot be recorded is not created either', () async {
    final unrecordable = patchRepository(
      database,
      changeLog: BrokenChangeLog(ChangeLogDao(database)),
    );

    await expectLater(
      unrecordable.createPatch(unitId, const PatchDraft(name: 'Worship Clean')),
      throwsA(isA<AppFailure>()),
    );

    // The insert and the entry share one transaction, so a patch nobody can
    // account for is never left behind.
    expect(await patches.watchPatches(unitId).first, isEmpty);
    expect(await history(), isEmpty);
  });

  test('a scene that cannot be recorded is not created either', () async {
    final patchId = await addPatch();
    final unrecordable = sceneRepository(
      database,
      changeLog: BrokenChangeLog(ChangeLogDao(database)),
    );

    await expectLater(
      unrecordable.createScene(patchId, const SceneDraft(name: 'Verse')),
      throwsA(isA<AppFailure>()),
    );

    expect(await database.patchDao.scenesOf(patchId), isEmpty);
  });
}
