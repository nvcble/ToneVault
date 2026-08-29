import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/patches_table.dart';
import '../tables/scenes_table.dart';

part 'patch_dao.g.dart';

/// One scene with the patch it sits in.
///
/// Carried together because a scene is only named by the two of them: two patches
/// on one unit may each have a "Verse", so a bare scene cannot say which sound it
/// is.
typedef PatchScene = ({Patch patch, Scene scene});

/// Typed queries over `patches` and the `scenes` inside them.
///
/// Both live here because they are the same two-level shape read together: a
/// patch is never listed without asking what scenes it holds. What a scene uses
/// and where its knobs sit is `SceneDao`'s.
///
/// Validation, timestamps and error translation belong to `PatchRepository`;
/// this class only reads and writes rows.
@DriftAccessor(tables: [Patches, Scenes])
class PatchDao extends DatabaseAccessor<AppDatabase> with _$PatchDaoMixin {
  PatchDao(super.attachedDatabase);

  /// One unit's patches by name, case-insensitively - SQLite's default collation
  /// would sort "clean" after "Worship".
  Stream<List<Patch>> watchPatches(int pedalId) {
    return (select(patches)
          ..where((row) => row.pedalId.equals(pedalId))
          ..orderBy([
            (row) => OrderingTerm.asc(row.name.collate(Collate.noCase)),
          ]))
        .watch();
  }

  Future<List<Patch>> patchesOf(int pedalId) {
    return (select(patches)..where((row) => row.pedalId.equals(pedalId))).get();
  }

  Stream<Patch?> watchPatch(int patchId) {
    return (select(
      patches,
    )..where((row) => row.id.equals(patchId))).watchSingleOrNull();
  }

  Future<Patch?> findPatch(int patchId) {
    return (select(
      patches,
    )..where((row) => row.id.equals(patchId))).getSingleOrNull();
  }

  Future<int> insertPatch(PatchesCompanion patch) =>
      into(patches).insert(patch);

  /// Returns whether a row matched [patchId].
  Future<bool> updatePatch(int patchId, PatchesCompanion changes) async {
    final changedRows = await (update(
      patches,
    )..where((row) => row.id.equals(patchId))).write(changes);
    return changedRows > 0;
  }

  Future<bool> deletePatch(int patchId) async {
    final deletedRows = await (delete(
      patches,
    )..where((row) => row.id.equals(patchId))).go();
    return deletedRows > 0;
  }

  /// One patch's scenes by name, ordered as its patches are.
  Stream<List<Scene>> watchScenes(int patchId) {
    return (select(scenes)
          ..where((row) => row.patchId.equals(patchId))
          ..orderBy([
            (row) => OrderingTerm.asc(row.name.collate(Collate.noCase)),
          ]))
        .watch();
  }

  Future<List<Scene>> scenesOf(int patchId) {
    return (select(scenes)..where((row) => row.patchId.equals(patchId))).get();
  }

  Stream<Scene?> watchScene(int sceneId) {
    return (select(
      scenes,
    )..where((row) => row.id.equals(sceneId))).watchSingleOrNull();
  }

  Future<Scene?> findScene(int sceneId) {
    return (select(
      scenes,
    )..where((row) => row.id.equals(sceneId))).getSingleOrNull();
  }

  Future<int> insertScene(ScenesCompanion scene) => into(scenes).insert(scene);

  /// Returns whether a row matched [sceneId].
  Future<bool> updateScene(int sceneId, ScenesCompanion changes) async {
    final changedRows = await (update(
      scenes,
    )..where((row) => row.id.equals(sceneId))).write(changes);
    return changedRows > 0;
  }

  Future<bool> deleteScene(int sceneId) async {
    final deletedRows = await (delete(
      scenes,
    )..where((row) => row.id.equals(sceneId))).go();
    return deletedRows > 0;
  }

  /// Every scene on one unit, whichever patch it is in.
  ///
  /// The unit's sounds as one flat list, which is how they are chosen from
  /// outside the patch screens: what is being asked is which scene the unit is
  /// on, not which patch and then which scene.
  Stream<List<PatchScene>> watchUnitScenes(int pedalId) =>
      _scenesOn(pedalId).watch().map(_patchScenes);

  /// [sceneId] with its patch, but only when that patch is on [pedalId].
  ///
  /// Null covers both a scene that is gone and one belonging to another unit; a
  /// caller cannot act differently on the two, so they read alike.
  Future<PatchScene?> findUnitScene({
    required int pedalId,
    required int sceneId,
  }) async {
    final query = _scenesOn(pedalId)..where(scenes.id.equals(sceneId));
    final row = await query.getSingleOrNull();
    return row == null ? null : _patchScenes([row]).single;
  }

  /// By patch and then by scene, case-insensitively, so the flat list reads down
  /// in the same order as the two screens it comes from.
  JoinedSelectStatement<HasResultSet, dynamic> _scenesOn(int pedalId) {
    return select(
        scenes,
      ).join([innerJoin(patches, patches.id.equalsExp(scenes.patchId))])
      ..where(patches.pedalId.equals(pedalId))
      ..orderBy([
        OrderingTerm.asc(patches.name.collate(Collate.noCase)),
        OrderingTerm.asc(scenes.name.collate(Collate.noCase)),
      ]);
  }

  List<PatchScene> _patchScenes(List<TypedResult> rows) => [
    for (final row in rows)
      (patch: row.readTable(patches), scene: row.readTable(scenes)),
  ];
}
