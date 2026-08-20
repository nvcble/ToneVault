import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/patch_dao.dart';
import '../../../core/database/daos/scene_dao.dart';
import '../../../core/errors/app_failure.dart';
import '../../controls/data/control_copy_name.dart';
import '../../history/data/change_entry.dart';
import '../../history/data/change_log_repository.dart';
import 'patch_validator.dart';

/// Copying a scene: its details, the pedals it uses, and where their controls sit.
///
/// This is how a set list is actually written - a chorus is the verse with one
/// pedal louder - so the copy carries everything the scene held rather than only
/// its name. The pedals are pointed at, not copied: they belong to the unit, and
/// both scenes reach for the same gear.
///
/// Its own class rather than another method on `SceneRepository`, because it is the
/// one operation that reaches into both halves of a scene: the row itself, which is
/// [PatchDao]'s, and what it holds, which is [SceneDao]'s.
class SceneDuplicator {
  SceneDuplicator(
    this._dao,
    this._sceneDao,
    this._changeLog, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final PatchDao _dao;
  final SceneDao _sceneDao;
  final ChangeLogRepository _changeLog;

  /// Injectable so tests can assert on exact timestamps.
  final DateTime Function() _clock;

  /// Copies [sceneId] into the same patch and returns the new scene's id.
  ///
  /// The copy is named "Verse copy", by the same rule a copied control is: the
  /// user asked for another scene like this one, not to name it first, and it can
  /// be renamed like any other scene afterwards.
  ///
  /// Recorded as a scene arriving, because that is what it is. The copy is read
  /// back inside the transaction so the entry names the row that was written.
  Future<int> duplicate(int sceneId) async {
    final source = await _require(sceneId);
    final patch = await _requirePatch(source.patchId);
    final scenes = await _dao.scenesOf(source.patchId);
    final name = copyNameFor(
      source.name,
      taken: [for (final scene in scenes) scene.name],
      maxLength: PatchValidator.nameMaxLength,
    );

    final pedals = await _sceneDao.scenePedalsOf(sceneId);
    final values = await _sceneDao.valuesOf(sceneId);
    final now = _clock();

    return guardFailure(
      () => _dao.transaction(() async {
        final copyId = await _dao.insertScene(
          ScenesCompanion.insert(
            patchId: source.patchId,
            name: name,
            notes: Value(source.notes),
            createdAt: now,
            updatedAt: now,
          ),
        );

        for (final pedal in pedals) {
          await _sceneDao.addPedal(sceneId: copyId, pedalId: pedal.id);
        }
        // Written after the pedals: a position is only reachable through the
        // pedal the control is on.
        for (final value in values) {
          await _sceneDao.upsertValue(
            sceneId: copyId,
            controlId: value.controlId,
            value: value.value,
            updatedAt: now,
          );
        }

        final copy = await _dao.findScene(copyId);
        await _changeLog.record(
          ChangeEntry.sceneCreated(patch: patch, scene: copy!),
        );

        return copyId;
      }),
      'Could not duplicate this scene.',
    );
  }

  Future<Scene> _require(int sceneId) async {
    final scene = await _dao.findScene(sceneId);
    if (scene == null) {
      throw const AppFailure('That scene no longer exists.');
    }
    return scene;
  }

  /// Read for its name, which is half of what the history entry says.
  Future<Patch> _requirePatch(int patchId) async {
    final patch = await _dao.findPatch(patchId);
    if (patch == null) {
      throw const AppFailure('That patch no longer exists.');
    }
    return patch;
  }
}
