import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/midi_scene_numbers_table.dart';
import '../tables/scenes_table.dart';

part 'midi_scene_number_dao.g.dart';

/// Typed queries over `midi_scene_numbers`.
@DriftAccessor(tables: [MidiSceneNumbers, Scenes])
class MidiSceneNumberDao extends DatabaseAccessor<AppDatabase>
    with _$MidiSceneNumberDaoMixin {
  MidiSceneNumberDao(super.attachedDatabase);

  Stream<MidiSceneNumber?> watchNumber(int sceneId) {
    return (select(
      midiSceneNumbers,
    )..where((row) => row.sceneId.equals(sceneId))).watchSingleOrNull();
  }

  Future<MidiSceneNumber?> findNumber(int sceneId) {
    return (select(
      midiSceneNumbers,
    )..where((row) => row.sceneId.equals(sceneId))).getSingleOrNull();
  }

  /// The numbers already assigned to the other scenes of [patchId], for
  /// checking a clash before assigning one more.
  Future<List<MidiSceneNumber>> numbersInPatch({
    required int patchId,
    required int exceptSceneId,
  }) {
    return (select(midiSceneNumbers).join([
          innerJoin(scenes, scenes.id.equalsExp(midiSceneNumbers.sceneId)),
        ])..where(
          scenes.patchId.equals(patchId) &
              midiSceneNumbers.sceneId.equals(exceptSceneId).not(),
        ))
        .map((row) => row.readTable(midiSceneNumbers))
        .get();
  }

  /// Stores [sceneNumber] for [sceneId], replacing whatever was there before.
  Future<void> upsertNumber({
    required int sceneId,
    required int sceneNumber,
    required DateTime updatedAt,
  }) {
    return into(midiSceneNumbers).insert(
      MidiSceneNumbersCompanion.insert(
        sceneId: sceneId,
        sceneNumber: sceneNumber,
        updatedAt: updatedAt,
      ),
      onConflict: DoUpdate(
        (_) => MidiSceneNumbersCompanion(
          sceneNumber: Value(sceneNumber),
          updatedAt: Value(updatedAt),
        ),
        target: [midiSceneNumbers.sceneId],
      ),
    );
  }

  /// Returns whether a row existed to remove.
  Future<bool> deleteNumber(int sceneId) async {
    final deletedRows = await (delete(
      midiSceneNumbers,
    )..where((row) => row.sceneId.equals(sceneId))).go();
    return deletedRows > 0;
  }
}
