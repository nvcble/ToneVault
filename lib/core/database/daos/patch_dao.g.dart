// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_dao.dart';

// ignore_for_file: type=lint
mixin _$PatchDaoMixin on DatabaseAccessor<AppDatabase> {
  $PedalsTable get pedals => attachedDatabase.pedals;
  $PatchesTable get patches => attachedDatabase.patches;
  $ScenesTable get scenes => attachedDatabase.scenes;
  PatchDaoManager get managers => PatchDaoManager(this);
}

class PatchDaoManager {
  final _$PatchDaoMixin _db;
  PatchDaoManager(this._db);
  $$PedalsTableTableManager get pedals =>
      $$PedalsTableTableManager(_db.attachedDatabase, _db.pedals);
  $$PatchesTableTableManager get patches =>
      $$PatchesTableTableManager(_db.attachedDatabase, _db.patches);
  $$ScenesTableTableManager get scenes =>
      $$ScenesTableTableManager(_db.attachedDatabase, _db.scenes);
}
