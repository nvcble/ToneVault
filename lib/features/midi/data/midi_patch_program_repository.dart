import '../../../core/database/app_database.dart';
import '../../../core/database/daos/midi_patch_program_number_dao.dart';
import '../../../core/errors/app_failure.dart';

/// Which Program Change number a patch loads as, on the device it belongs to.
class MidiPatchProgramRepository {
  const MidiPatchProgramRepository(this._dao);

  final MidiPatchProgramNumberDao _dao;

  Stream<MidiPatchProgramNumber?> watchNumber(int patchId) => _dao.watchNumber(patchId);

  /// The numbered patches of one unit, in the order Live Control cycles
  /// through them.
  Stream<List<NumberedPatch>> watchNumberedPatches(int pedalId) =>
      _dao.watchNumberedPatches(pedalId);

  Future<void> setNumber({required int patchId, required int programNumber}) async {
    if (programNumber < 1 || programNumber > 128) {
      throw const AppFailure('A patch number has to be between 1 and 128.');
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
    return guardFailure(() => _dao.deleteNumber(patchId), 'Could not clear that patch number.');
  }
}
