// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rig_snapshot_dao.dart';

// ignore_for_file: type=lint
mixin _$RigSnapshotDaoMixin on DatabaseAccessor<AppDatabase> {
  $PedalboardsTable get pedalboards => attachedDatabase.pedalboards;
  $RigSnapshotsTable get rigSnapshots => attachedDatabase.rigSnapshots;
  $PedalsTable get pedals => attachedDatabase.pedals;
  $RigSnapshotEntriesTable get rigSnapshotEntries =>
      attachedDatabase.rigSnapshotEntries;
  $RigSnapshotValuesTable get rigSnapshotValues =>
      attachedDatabase.rigSnapshotValues;
  RigSnapshotDaoManager get managers => RigSnapshotDaoManager(this);
}

class RigSnapshotDaoManager {
  final _$RigSnapshotDaoMixin _db;
  RigSnapshotDaoManager(this._db);
  $$PedalboardsTableTableManager get pedalboards =>
      $$PedalboardsTableTableManager(_db.attachedDatabase, _db.pedalboards);
  $$RigSnapshotsTableTableManager get rigSnapshots =>
      $$RigSnapshotsTableTableManager(_db.attachedDatabase, _db.rigSnapshots);
  $$PedalsTableTableManager get pedals =>
      $$PedalsTableTableManager(_db.attachedDatabase, _db.pedals);
  $$RigSnapshotEntriesTableTableManager get rigSnapshotEntries =>
      $$RigSnapshotEntriesTableTableManager(
        _db.attachedDatabase,
        _db.rigSnapshotEntries,
      );
  $$RigSnapshotValuesTableTableManager get rigSnapshotValues =>
      $$RigSnapshotValuesTableTableManager(
        _db.attachedDatabase,
        _db.rigSnapshotValues,
      );
}
