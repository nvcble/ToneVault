// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scene_dao.dart';

// ignore_for_file: type=lint
mixin _$SceneDaoMixin on DatabaseAccessor<AppDatabase> {
  $PedalsTable get pedals => attachedDatabase.pedals;
  $PatchesTable get patches => attachedDatabase.patches;
  $ScenesTable get scenes => attachedDatabase.scenes;
  $ScenePedalsTable get scenePedals => attachedDatabase.scenePedals;
  $PedalControlsTable get pedalControls => attachedDatabase.pedalControls;
  $SceneValuesTable get sceneValues => attachedDatabase.sceneValues;
  SceneDaoManager get managers => SceneDaoManager(this);
}

class SceneDaoManager {
  final _$SceneDaoMixin _db;
  SceneDaoManager(this._db);
  $$PedalsTableTableManager get pedals =>
      $$PedalsTableTableManager(_db.attachedDatabase, _db.pedals);
  $$PatchesTableTableManager get patches =>
      $$PatchesTableTableManager(_db.attachedDatabase, _db.patches);
  $$ScenesTableTableManager get scenes =>
      $$ScenesTableTableManager(_db.attachedDatabase, _db.scenes);
  $$ScenePedalsTableTableManager get scenePedals =>
      $$ScenePedalsTableTableManager(_db.attachedDatabase, _db.scenePedals);
  $$PedalControlsTableTableManager get pedalControls =>
      $$PedalControlsTableTableManager(_db.attachedDatabase, _db.pedalControls);
  $$SceneValuesTableTableManager get sceneValues =>
      $$SceneValuesTableTableManager(_db.attachedDatabase, _db.sceneValues);
}
