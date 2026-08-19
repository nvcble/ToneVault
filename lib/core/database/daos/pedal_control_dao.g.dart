// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedal_control_dao.dart';

// ignore_for_file: type=lint
mixin _$PedalControlDaoMixin on DatabaseAccessor<AppDatabase> {
  $PedalsTable get pedals => attachedDatabase.pedals;
  $PedalControlsTable get pedalControls => attachedDatabase.pedalControls;
  PedalControlDaoManager get managers => PedalControlDaoManager(this);
}

class PedalControlDaoManager {
  final _$PedalControlDaoMixin _db;
  PedalControlDaoManager(this._db);
  $$PedalsTableTableManager get pedals =>
      $$PedalsTableTableManager(_db.attachedDatabase, _db.pedals);
  $$PedalControlsTableTableManager get pedalControls =>
      $$PedalControlsTableTableManager(_db.attachedDatabase, _db.pedalControls);
}
