import '../../../core/database/app_database.dart';
import '../../../core/database/daos/midi_patch_program_number_dao.dart';
import '../../../core/errors/app_failure.dart';

/// Which Program Change number a patch loads as, on the device it belongs to.
class MidiPatchProgramRepository {
  const MidiPatchProgramRepository(this._dao);

  final MidiPatchProgramNumberDao _dao;

  Stream<MidiPatchProgramNumber?> watchNumber(int patchId) =>
      _dao.watchNumber(patchId);

  /// The numbered patches of one unit, in the order Live Control cycles
  /// through them.
  Stream<List<NumberedPatch>> watchNumberedPatches(int pedalId) =>
      _dao.watchNumberedPatches(pedalId);

  /// A one-off read of [watchNumberedPatches], for a computation that just
  /// needs the current numbers rather than to keep watching them.
  Future<List<NumberedPatch>> numberedPatches(int pedalId) =>
      _dao.numberedPatches(pedalId);

  Future<void> setNumber({
    required int patchId,
    required int programNumber,
  }) async {
    // 0-127, not 1-128: a program number is the Program Change value sent on
    // the wire, and the device's first slot is 0. The old range rejected slot
    // 0 outright, so importing the very first preset off a unit always failed.
    if (programNumber < 0 || programNumber > 127) {
      throw const AppFailure('A patch number has to be between 0 and 127.');
    }

    return guardFailure(
      () => _dao.upsertNumber(
        patchId: patchId,
        programNumber: programNumber,
        updatedAt: DateTime.now(),
      ),
      'Could not save that patch number.',
    );
  }

  Future<void> clearNumber(int patchId) {
    return guardFailure(
      () => _dao.deleteNumber(patchId),
      'Could not clear that patch number.',
    );
  }
}
