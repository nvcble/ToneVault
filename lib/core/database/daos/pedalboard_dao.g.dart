// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedalboard_dao.dart';

// ignore_for_file: type=lint
mixin _$PedalboardDaoMixin on DatabaseAccessor<AppDatabase> {
  $PedalboardsTable get pedalboards => attachedDatabase.pedalboards;
  PedalboardDaoManager get managers => PedalboardDaoManager(this);
}

class PedalboardDaoManager {
  final _$PedalboardDaoMixin _db;
  PedalboardDaoManager(this._db);
  $$PedalboardsTableTableManager get pedalboards =>
      $$PedalboardsTableTableManager(_db.attachedDatabase, _db.pedalboards);
}
