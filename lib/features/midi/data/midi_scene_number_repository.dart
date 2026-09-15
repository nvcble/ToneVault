import '../../../core/database/app_database.dart';
import '../../../core/database/daos/midi_scene_number_dao.dart';
import '../../../core/errors/app_failure.dart';

/// Which of a device's Pro Scene slots (1-3) a scene sends as.
///
/// A slot is unique within one patch: two scenes of the same patch both
/// claiming to be Scene 2 would leave "send scene 2" unable to say which one
/// was meant.
class MidiSceneNumberRepository {
  const MidiSceneNumberRepository(this._dao);

  final MidiSceneNumberDao _dao;

  Stream<MidiSceneNumber?> watchNumber(int sceneId) => _dao.watchNumber(sceneId);

  Future<void> setNumber({
    required int patchId,
    required int sceneId,
    required int sceneNumber,
  }) async {
    if (sceneNumber < 1 || sceneNumber > 3) {
      throw const AppFailure('A Pro Scene slot has to be 1, 2 or 3.');
    }

    final clash = await _dao.numbersInPatch(patchId: patchId, exceptSceneId: sceneId);
    if (clash.any((existing) => existing.sceneNumber == sceneNumber)) {
      throw AppFailure('Another scene in this patch is already Scene $sceneNumber.');
    }

    await guardFailure(
      () => _dao.upsertNumber(sceneId: sceneId, sceneNumber: sceneNumber, updatedAt: DateTime.now()),
      'Could not save that scene number.',
    );
  }

  Future<void> clearNumber(int sceneId) {
    return guardFailure(() => _dao.deleteNumber(sceneId), 'Could not clear that scene number.');
  }
}
