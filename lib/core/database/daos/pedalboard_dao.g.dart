// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedalboard_dao.dart';

// ignore_for_file: type=lint
mixin _$PedalboardDaoMixin on DatabaseAccessor<AppDatabase> {
  $PedalboardsTable get pedalboards => attachedDatabase.pedalboards;
  $PedalsTable get pedals => attachedDatabase.pedals;
  $PedalboardSlotsTable get pedalboardSlots => attachedDatabase.pedalboardSlots;
  $RigSnapshotsTable get rigSnapshots => attachedDatabase.rigSnapshots;
  PedalboardDaoManager get managers => PedalboardDaoManager(this);
}

class PedalboardDaoManager {
  final _$PedalboardDaoMixin _db;
  PedalboardDaoManager(this._db);
  $$PedalboardsTableTableManager get pedalboards =>
      $$PedalboardsTableTableManager(_db.attachedDatabase, _db.pedalboards);
  $$PedalsTableTableManager get pedals =>
      $$PedalsTableTableManager(_db.attachedDatabase, _db.pedals);
  $$PedalboardSlotsTableTableManager get pedalboardSlots =>
      $$PedalboardSlotsTableTableManager(
        _db.attachedDatabase,
        _db.pedalboardSlots,
      );
  $$RigSnapshotsTableTableManager get rigSnapshots =>
      $$RigSnapshotsTableTableManager(_db.attachedDatabase, _db.rigSnapshots);
}
