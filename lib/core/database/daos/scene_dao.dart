import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/pedal_controls_table.dart';
import '../tables/pedals_table.dart';
import '../tables/scene_pedals_table.dart';
import '../tables/scene_values_table.dart';
import '../tables/scenes_table.dart';
import 'pedal_control_dao.dart';

part 'scene_dao.g.dart';

/// Typed queries over what one scene uses and where its knobs sit.
///
/// `patches` and `scenes` themselves are `PatchDao`'s; this class answers the two
/// questions asked of a scene once it exists - which of the unit's pedals it
/// reaches for, and what their controls are set to.
///
/// Validation, timestamps and error translation belong to `SceneRepository` and
/// `SceneValueRepository`; this class only reads and writes rows.
@DriftAccessor(
  tables: [ScenePedals, SceneValues, Scenes, Pedals, PedalControls],
)
class SceneDao extends DatabaseAccessor<AppDatabase> with _$SceneDaoMixin {
  SceneDao(super.attachedDatabase);

  /// The pedals one scene uses, by name.
  ///
  /// Name order rather than an order of its own: a scene is a set of sounds
  /// switched on together, so there is no chain position to preserve.
  Stream<List<Pedal>> watchScenePedals(int sceneId) =>
      _pedalsIn(sceneId).watch().map(_pedals);

  Future<List<Pedal>> scenePedalsOf(int sceneId) async =>
      _pedals(await _pedalsIn(sceneId).get());

  JoinedSelectStatement<HasResultSet, dynamic> _pedalsIn(int sceneId) {
    return select(
        scenePedals,
      ).join([innerJoin(pedals, pedals.id.equalsExp(scenePedals.pedalId))])
      ..where(scenePedals.sceneId.equals(sceneId))
      ..orderBy([OrderingTerm.asc(pedals.name.collate(Collate.noCase))]);
  }

  List<Pedal> _pedals(List<TypedResult> rows) => [
    for (final row in rows) row.readTable(pedals),
  ];

  Future<int> addPedal({required int sceneId, required int pedalId}) {
    return into(
      scenePedals,
    ).insert(ScenePedalsCompanion.insert(sceneId: sceneId, pedalId: pedalId));
  }

  /// Returns whether the scene was using that pedal.
  Future<bool> removePedal({required int sceneId, required int pedalId}) async {
    final deletedRows =
        await (delete(scenePedals)..where(
              (row) =>
                  row.sceneId.equals(sceneId) & row.pedalId.equals(pedalId),
            ))
            .go();
    return deletedRows > 0;
  }

  /// Every control the scene can set, each with the pedal it is on.
  ///
  /// Only the controls of the pedals the scene actually uses, which is what makes
  /// a scene narrower than the unit: adding a pedal to the scene is what puts its
  /// knobs within reach.
  Stream<List<OwnedControl>> watchSceneControls(int sceneId) =>
      _controlsIn(sceneId).watch().map(_owned);

  Future<List<OwnedControl>> sceneControlsOf(int sceneId) async =>
      _owned(await _controlsIn(sceneId).get());

  /// [controlId] with its pedal, but only when [sceneId] may set it.
  ///
  /// Null covers both a control that is gone and one on a pedal the scene does
  /// not use; the caller cannot act differently on the two, so they read alike.
  Future<OwnedControl?> findSceneControl({
    required int sceneId,
    required int controlId,
  }) async {
    final query = _controlsIn(sceneId)
      ..where(pedalControls.id.equals(controlId));
    final row = await query.getSingleOrNull();
    return row == null ? null : _owned([row]).single;
  }

  /// The scene's pedals by name, and within each the order the user arranged its
  /// controls, so a scene reads down the same way every time.
  JoinedSelectStatement<HasResultSet, dynamic> _controlsIn(int sceneId) {
    return select(scenePedals).join([
        innerJoin(pedals, pedals.id.equalsExp(scenePedals.pedalId)),
        innerJoin(
          pedalControls,
          pedalControls.pedalId.equalsExp(scenePedals.pedalId),
        ),
      ])
      ..where(scenePedals.sceneId.equals(sceneId))
      ..orderBy([
        OrderingTerm.asc(pedals.name.collate(Collate.noCase)),
        OrderingTerm.asc(pedalControls.displayOrder),
        OrderingTerm.asc(pedalControls.name.collate(Collate.noCase)),
      ]);
  }

  List<OwnedControl> _owned(List<TypedResult> rows) => [
    for (final row in rows)
      (owner: row.readTable(pedals), control: row.readTable(pedalControls)),
  ];

  /// Unordered: a scene's values are read alongside its controls, which already
  /// carry the order.
  Stream<List<SceneValue>> watchValues(int sceneId) {
    return (select(
      sceneValues,
    )..where((row) => row.sceneId.equals(sceneId))).watch();
  }

  Future<List<SceneValue>> valuesOf(int sceneId) {
    return (select(
      sceneValues,
    )..where((row) => row.sceneId.equals(sceneId))).get();
  }

  /// Where one control sits in one scene, or null if it was never set.
  Future<double?> findValue({
    required int sceneId,
    required int controlId,
  }) async {
    final row =
        await (select(sceneValues)..where(
              (row) =>
                  row.sceneId.equals(sceneId) & row.controlId.equals(controlId),
            ))
            .getSingleOrNull();
    return row?.value;
  }

  /// Stores where one control sits, replacing whatever was there before.
  ///
  /// The `{sceneId, controlId}` unique key is what makes this an upsert rather
  /// than a second row for the same knob, and the scene's timestamp moves in the
  /// same transaction so a saved value never leaves it looking untouched.
  Future<void> upsertValue({
    required int sceneId,
    required int controlId,
    required double value,
    required DateTime updatedAt,
  }) {
    return transaction(() async {
      await into(sceneValues).insert(
        SceneValuesCompanion.insert(
          sceneId: sceneId,
          controlId: controlId,
          value: value,
        ),
        onConflict: DoUpdate(
          (_) => SceneValuesCompanion(value: Value(value)),
          target: [sceneValues.sceneId, sceneValues.controlId],
        ),
      );

      await touchScene(sceneId, updatedAt);
    });
  }

  /// Returns whether the control had a stored value to remove.
  Future<bool> deleteValue({
    required int sceneId,
    required int controlId,
    required DateTime updatedAt,
  }) {
    return transaction(() async {
      final deletedRows =
          await (delete(sceneValues)..where(
                (row) =>
                    row.sceneId.equals(sceneId) &
                    row.controlId.equals(controlId),
              ))
              .go();

      if (deletedRows > 0) {
        await touchScene(sceneId, updatedAt);
      }
      return deletedRows > 0;
    });
  }

  /// Drops the positions a scene held for every control on one pedal.
  ///
  /// Called when the pedal is taken out of the scene: the rows would otherwise
  /// sit there unreachable and come back the moment it was added again, showing
  /// positions the user thought they had discarded.
  Future<int> deleteValuesOfPedal({
    required int sceneId,
    required int pedalId,
  }) {
    final controlsOnPedal = selectOnly(pedalControls)
      ..addColumns([pedalControls.id])
      ..where(pedalControls.pedalId.equals(pedalId));

    return (delete(sceneValues)..where(
          (row) =>
              row.sceneId.equals(sceneId) &
              row.controlId.isInQuery(controlsOnPedal),
        ))
        .go();
  }

  /// Moves a scene's own timestamp, so an edit to what it holds shows on it.
  ///
  /// Public because `SceneRepository` changes a scene's pedals through this DAO
  /// and has the same reason to mark it touched.
  Future<void> touchScene(int sceneId, DateTime updatedAt) async {
    await (update(scenes)..where((row) => row.id.equals(sceneId))).write(
      ScenesCompanion(updatedAt: Value(updatedAt)),
    );
  }
}
