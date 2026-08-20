import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/patch_dao.dart';
import '../../../core/errors/app_failure.dart';
import '../../history/data/change_entry.dart';
import '../../history/data/change_log_repository.dart';
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
/// A patch coming, going or being renamed is recorded in the same transaction as
/// the change itself, so the history cannot end up claiming something that did
/// not happen. Its notes are not: those are the user's own scratch pad, rewritten
/// as often as they like.
class PatchRepository {
  PatchRepository(this._dao, this._changeLog, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final PatchDao _dao;
  final ChangeLogRepository _changeLog;

  /// Injectable so tests can assert on exact timestamps.
  final DateTime Function() _clock;

  Stream<List<Patch>> watchPatches(int pedalId) => _dao.watchPatches(pedalId);

  Stream<Patch?> watchPatch(int patchId) => _dao.watchPatch(patchId);

  Future<int> createPatch(int pedalId, PatchDraft draft) async {
    final patch = _validated(draft);
    await _ensureNameIsFree(pedalId, patch.name);
    final now = _clock();

    return guardFailure(
      () => _dao.transaction(() async {
        final patchId = await _dao.insertPatch(
          PatchesCompanion.insert(
            pedalId: pedalId,
            name: patch.name,
            notes: Value(patch.notes),
            createdAt: now,
            updatedAt: now,
          ),
        );

        // Read back rather than rebuilt from the draft, so the entry names the
        // row that was actually written. Inside the transaction it is there.
        final inserted = await _dao.findPatch(patchId);
        await _changeLog.record(ChangeEntry.patchCreated(inserted!));

        return patchId;
      }),
      'Could not save this patch.',
    );
  }

  /// Renames a patch and rewrites its notes. Its scenes are untouched.
  ///
  /// Only a new name is history: an entry saying "Clean renamed to Clean" every
  /// time the notes are tidied would bury the renames that did happen.
  Future<void> updatePatch(int patchId, PatchDraft draft) async {
    final patch = _validated(draft);
    final existing = await _require(patchId);
    await _ensureNameIsFree(existing.pedalId, patch.name, exceptId: patchId);

    await guardFailure(
      () => _dao.transaction(() async {
        await _dao.updatePatch(
          patchId,
          PatchesCompanion(
            name: Value(patch.name),
            notes: Value(patch.notes),
            updatedAt: Value(_clock()),
          ),
        );

        if (patch.name == existing.name) {
          return;
        }
        final renamed = await _dao.findPatch(patchId);
        await _changeLog.record(
          ChangeEntry.patchRenamed(
            patch: renamed!,
            previousName: existing.name,
          ),
        );
      }),
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
  ///
  /// The patch is read before it goes, because its name is the only thing that
  /// will still make the history entry readable afterwards. The scenes it took
  /// with it get no entries of their own: the patch going is the event, and a page
  /// of "Verse deleted, Chorus deleted" underneath it would only hide it.
  Future<void> deletePatch(int patchId) async {
    final existing = await _require(patchId);

    await guardFailure(
      () => _dao.transaction(() async {
        await _dao.deletePatch(patchId);
        await _changeLog.record(ChangeEntry.patchDeleted(existing));
      }),
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
