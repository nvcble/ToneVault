import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/patch_dao.dart';
import '../../../core/errors/app_failure.dart';
import 'patch_draft.dart';
import 'patch_validator.dart';

/// The scenes inside one patch.
///
/// The same shape as [PatchRepository] one level down, and separate from it for
/// the same reason a configuration's values are separate from the configuration:
/// naming a scene and filling it in are different edits.
///
/// Which of the unit's pedals a scene uses is `ScenePedalRepository`'s, and where
/// their controls sit is `SceneValueRepository`'s. Nothing here writes history,
/// for the reason given on [PatchRepository].
class SceneRepository {
  SceneRepository(this._dao, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final PatchDao _dao;

  /// Injectable so tests can assert on exact timestamps.
  final DateTime Function() _clock;

  Stream<List<Scene>> watchScenes(int patchId) => _dao.watchScenes(patchId);

  Stream<Scene?> watchScene(int sceneId) => _dao.watchScene(sceneId);

  Future<int> createScene(int patchId, SceneDraft draft) async {
    final scene = _validated(draft);
    await _requirePatch(patchId);
    await _ensureNameIsFree(patchId, scene.name);
    final now = _clock();

    return guardFailure(
      () => _dao.insertScene(
        ScenesCompanion.insert(
          patchId: patchId,
          name: scene.name,
          notes: Value(scene.notes),
          createdAt: now,
          updatedAt: now,
        ),
      ),
      'Could not save this scene.',
    );
  }

  /// Renames a scene and rewrites its notes. The pedals it uses and the positions
  /// it holds are untouched: those are saved one at a time.
  Future<void> updateScene(int sceneId, SceneDraft draft) async {
    final scene = _validated(draft);
    final existing = await _require(sceneId);
    await _ensureNameIsFree(existing.patchId, scene.name, exceptId: sceneId);

    await guardFailure(
      () => _dao.updateScene(
        sceneId,
        ScenesCompanion(
          name: Value(scene.name),
          notes: Value(scene.notes),
          updatedAt: Value(_clock()),
        ),
      ),
      'Could not update this scene.',
    );
  }

  /// The pedals it used and the positions it held go with it: both tables
  /// reference scenes with ON DELETE CASCADE. The pedals themselves belong to the
  /// unit and stay in the vault.
  Future<void> deleteScene(int sceneId) async {
    await _require(sceneId);

    await guardFailure(
      () => _dao.deleteScene(sceneId),
      'Could not delete this scene.',
    );
  }

  SceneDraft _validated(SceneDraft draft) {
    final normalized = draft.normalized();
    final problem = PatchValidator.sceneDraft(normalized);
    if (problem != null) {
      throw AppFailure(problem);
    }
    return normalized;
  }

  Future<Scene> _require(int sceneId) async {
    final scene = await _dao.findScene(sceneId);
    if (scene == null) {
      throw const AppFailure('That scene no longer exists.');
    }
    return scene;
  }

  /// Checked before the insert so a patch deleted behind an open form reads as
  /// itself rather than as a foreign key complaint.
  Future<void> _requirePatch(int patchId) async {
    if (await _dao.findPatch(patchId) == null) {
      throw const AppFailure('That patch no longer exists.');
    }
  }

  /// Within one patch, not one unit: two patches may each have a "Verse", and it
  /// is only inside a patch that the name has to pick out one sound.
  Future<void> _ensureNameIsFree(
    int patchId,
    String name, {
    int? exceptId,
  }) async {
    final existing = await _dao.scenesOf(patchId);
    final clash = existing.any(
      (scene) =>
          scene.id != exceptId &&
          scene.name.toLowerCase() == name.toLowerCase(),
    );

    if (clash) {
      throw AppFailure('This patch already has a scene called "$name".');
    }
  }
}
