import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/patch_dao.dart';
import '../../../core/errors/app_failure.dart';
import 'patch_draft.dart';
import 'patch_validator.dart';

/// The patches of one multi-effects unit.
///
/// Owns what the database cannot express on its own: validation, createdAt and
/// updatedAt bookkeeping, and turning driver exceptions into [AppFailure]s whose
/// message can be shown to the user as-is.
///
/// The scenes inside a patch are `SceneRepository`'s, and the positions inside a
/// scene are `SceneValueRepository`'s.
///
/// Nothing here writes history. A patch is a container the user names and
/// renames; what a rig actually sounded like is in the positions its scenes hold,
/// and those are logged. Recording the containers too would need six new change
/// types for entries nobody looks back at.
class PatchRepository {
  PatchRepository(this._dao, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final PatchDao _dao;

  /// Injectable so tests can assert on exact timestamps.
  final DateTime Function() _clock;

  Stream<List<Patch>> watchPatches(int pedalId) => _dao.watchPatches(pedalId);

  Stream<Patch?> watchPatch(int patchId) => _dao.watchPatch(patchId);

  Future<int> createPatch(int pedalId, PatchDraft draft) async {
    final patch = _validated(draft);
    await _ensureNameIsFree(pedalId, patch.name);
    final now = _clock();

    return guardFailure(
      () => _dao.insertPatch(
        PatchesCompanion.insert(
          pedalId: pedalId,
          name: patch.name,
          notes: Value(patch.notes),
          createdAt: now,
          updatedAt: now,
        ),
      ),
      'Could not save this patch.',
    );
  }

  /// Renames a patch and rewrites its notes. Its scenes are untouched.
  Future<void> updatePatch(int patchId, PatchDraft draft) async {
    final patch = _validated(draft);
    final existing = await _require(patchId);
    await _ensureNameIsFree(existing.pedalId, patch.name, exceptId: patchId);

    await guardFailure(
      () => _dao.updatePatch(
        patchId,
        PatchesCompanion(
          name: Value(patch.name),
          notes: Value(patch.notes),
          updatedAt: Value(_clock()),
        ),
      ),
      'Could not update this patch.',
    );
  }

  /// The scenes go with it, and their pedals and positions with them: `scenes`
  /// references patches with ON DELETE CASCADE, and everything under a scene
  /// cascades from there. Asking the user first is the UI's job, since it is the
  /// only place that knows they meant it.
  ///
  /// The pedals themselves are never touched. A scene only ever pointed at pedals
  /// the unit owns, and those stay in the vault.
  Future<void> deletePatch(int patchId) async {
    await _require(patchId);

    await guardFailure(
      () => _dao.deletePatch(patchId),
      'Could not delete this patch.',
    );
  }

  PatchDraft _validated(PatchDraft draft) {
    final normalized = draft.normalized();
    final problem = PatchValidator.patchDraft(normalized);
    if (problem != null) {
      throw AppFailure(problem);
    }
    return normalized;
  }

  Future<Patch> _require(int patchId) async {
    final patch = await _dao.findPatch(patchId);
    if (patch == null) {
      throw const AppFailure('That patch no longer exists.');
    }
    return patch;
  }

  /// The `{pedalId, name}` unique key would catch a repeat, but only exactly:
  /// "Clean" and "clean" on one unit are equally ambiguous, and a checked name
  /// gives the user the name in the message.
  Future<void> _ensureNameIsFree(
    int pedalId,
    String name, {
    int? exceptId,
  }) async {
    final existing = await _dao.patchesOf(pedalId);
    final clash = existing.any(
      (patch) =>
          patch.id != exceptId &&
          patch.name.toLowerCase() == name.toLowerCase(),
    );

    if (clash) {
      throw AppFailure('This unit already has a patch called "$name".');
    }
  }
}
