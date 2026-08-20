import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/patch_dao.dart';
import '../../../core/errors/app_failure.dart';
import '../../history/data/change_entry.dart';
import '../../history/data/change_log_repository.dart';
import 'patch_draft.dart';
import 'patch_validator.dart';

/// The scenes inside one patch.
///
/// The same shape as [PatchRepository] one level down, and separate from it for
/// the same reason a configuration's values are separate from the configuration:
/// naming a scene and filling it in are different edits.
///
/// Which of the unit's pedals a scene uses is `ScenePedalRepository`'s, and where
/// their controls sit is `SceneValueRepository`'s. A scene coming, going or being
/// renamed is recorded the way a patch's is, for the reason given on
/// [PatchRepository]; each entry is named by its patch and itself together, since
/// two patches may each have a "Verse".
class SceneRepository {
  SceneRepository(this._dao, this._changeLog, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final PatchDao _dao;
  final ChangeLogRepository _changeLog;

  /// Injectable so tests can assert on exact timestamps.
  final DateTime Function() _clock;

  Stream<List<Scene>> watchScenes(int patchId) => _dao.watchScenes(patchId);

  Stream<Scene?> watchScene(int sceneId) => _dao.watchScene(sceneId);

  /// Every scene on one unit, whichever patch it is in, each with its patch.
  ///
  /// For the places a scene is chosen from outside the patch screens: a rig
  /// snapshot asks which scene the unit was on, and the two-level walk down to it
  /// would be two questions for one answer.
  Stream<List<PatchScene>> watchUnitScenes(int pedalId) =>
      _dao.watchUnitScenes(pedalId);

  Future<int> createScene(int patchId, SceneDraft draft) async {
    final scene = _validated(draft);
    final patch = await _requirePatch(patchId);
    await _ensureNameIsFree(patchId, scene.name);
    final now = _clock();

    return guardFailure(
      () => _dao.transaction(() async {
        final sceneId = await _dao.insertScene(
          ScenesCompanion.insert(
            patchId: patchId,
            name: scene.name,
            notes: Value(scene.notes),
            createdAt: now,
            updatedAt: now,
          ),
        );

        // Read back rather than rebuilt from the draft, so the entry names the
        // row that was actually written. Inside the transaction it is there.
        final inserted = await _dao.findScene(sceneId);
        await _changeLog.record(
          ChangeEntry.sceneCreated(patch: patch, scene: inserted!),
        );

        return sceneId;
      }),
      'Could not save this scene.',
    );
  }

  /// Renames a scene and rewrites its notes. The pedals it uses and the positions
  /// it holds are untouched: those are saved one at a time.
  ///
  /// Only a new name is history, as with a patch: notes are the user's own scratch
  /// pad.
  Future<void> updateScene(int sceneId, SceneDraft draft) async {
    final scene = _validated(draft);
    final existing = await _require(sceneId);
    await _ensureNameIsFree(existing.patchId, scene.name, exceptId: sceneId);
    final renaming = scene.name != existing.name;
    final patch = renaming ? await _requirePatch(existing.patchId) : null;

    await guardFailure(
      () => _dao.transaction(() async {
        await _dao.updateScene(
          sceneId,
          ScenesCompanion(
            name: Value(scene.name),
            notes: Value(scene.notes),
            updatedAt: Value(_clock()),
          ),
        );

        if (patch == null) {
          return;
        }
        final renamed = await _dao.findScene(sceneId);
        await _changeLog.record(
          ChangeEntry.sceneRenamed(
            patch: patch,
            scene: renamed!,
            previousName: existing.name,
          ),
        );
      }),
      'Could not update this scene.',
    );
  }

  /// The pedals it used and the positions it held go with it: both tables
  /// reference scenes with ON DELETE CASCADE. The pedals themselves belong to the
  /// unit and stay in the vault.
  ///
  /// The scene is read before it goes, because its name is the only thing that
  /// will still make the history entry readable afterwards.
  Future<void> deleteScene(int sceneId) async {
    final existing = await _require(sceneId);
    final patch = await _requirePatch(existing.patchId);

    await guardFailure(
      () => _dao.transaction(() async {
        await _dao.deleteScene(sceneId);
        await _changeLog.record(
          ChangeEntry.sceneDeleted(patch: patch, scene: existing),
        );
      }),
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
  /// itself rather than as a foreign key complaint. Returned because the history
  /// entry needs the patch's name as well as its existence.
  Future<Patch> _requirePatch(int patchId) async {
    final patch = await _dao.findPatch(patchId);
    if (patch == null) {
      throw const AppFailure('That patch no longer exists.');
    }
    return patch;
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
