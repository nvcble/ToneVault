import '../../../core/database/app_database.dart';
import '../../../core/database/daos/midi_patch_program_number_dao.dart';
import '../../../core/database/daos/midi_patch_recent_dao.dart';

/// When a patch was last successfully loaded, for the Patch Browser's
/// "Recently Used" section.
class MidiPatchRecentRepository {
  const MidiPatchRecentRepository(this._dao);

  final MidiPatchRecentDao _dao;

  Stream<List<MidiPatchRecent>> watchRecents() => _dao.watchRecents();

  Future<void> recordUsed(int patchId, {DateTime Function()? clock}) =>
      _dao.recordUsed(patchId, clock: clock);
}

/// [recents] cross-referenced against [numberedPatches], newest first, for
/// one unit at a time.
///
/// A pure function rather than a query: recents are stored app-wide with no
/// join to a unit, and the caller already has the unit's numbered patches in
/// hand from `numberedPatchesProvider`, so there is nothing a database join
/// would do here that a lookup does not.
List<NumberedPatch> recentNumberedPatches(
  List<NumberedPatch> numberedPatches, {
  required List<MidiPatchRecent> recents,
}) {
  final byPatchId = {for (final patch in numberedPatches) patch.patch.id: patch};

  return [
    for (final recent in recents)
      if (byPatchId[recent.patchId] != null) byPatchId[recent.patchId]!,
  ];
}
