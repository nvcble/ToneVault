// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedal_dao.dart';

// ignore_for_file: type=lint
mixin _$PedalDaoMixin on DatabaseAccessor<AppDatabase> {
  $PedalsTable get pedals => attachedDatabase.pedals;
  PedalDaoManager get managers => PedalDaoManager(this);
}

class PedalDaoManager {
  final _$PedalDaoMixin _db;
  PedalDaoManager(this._db);
  $$PedalsTableTableManager get pedals =>
      $$PedalsTableTableManager(_db.attachedDatabase, _db.pedals);
}
