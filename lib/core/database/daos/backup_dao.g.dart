// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_dao.dart';

// ignore_for_file: type=lint
mixin _$BackupDaoMixin on DatabaseAccessor<AppDatabase> {
  $PedalsTable get pedals => attachedDatabase.pedals;
  $PedalControlsTable get pedalControls => attachedDatabase.pedalControls;
  $ConfigurationsTable get configurations => attachedDatabase.configurations;
  $ConfigurationValuesTable get configurationValues =>
      attachedDatabase.configurationValues;
  $ChangeLogsTable get changeLogs => attachedDatabase.changeLogs;
  $PedalReplacementsTable get pedalReplacements =>
      attachedDatabase.pedalReplacements;
  $PedalboardsTable get pedalboards => attachedDatabase.pedalboards;
  $PedalboardSlotsTable get pedalboardSlots => attachedDatabase.pedalboardSlots;
  $RigSnapshotsTable get rigSnapshots => attachedDatabase.rigSnapshots;
  $RigSnapshotEntriesTable get rigSnapshotEntries =>
      attachedDatabase.rigSnapshotEntries;
  $RigSnapshotValuesTable get rigSnapshotValues =>
      attachedDatabase.rigSnapshotValues;
  BackupDaoManager get managers => BackupDaoManager(this);
}

class BackupDaoManager {
  final _$BackupDaoMixin _db;
  BackupDaoManager(this._db);
  $$PedalsTableTableManager get pedals =>
      $$PedalsTableTableManager(_db.attachedDatabase, _db.pedals);
  $$PedalControlsTableTableManager get pedalControls =>
      $$PedalControlsTableTableManager(_db.attachedDatabase, _db.pedalControls);
  $$ConfigurationsTableTableManager get configurations =>
      $$ConfigurationsTableTableManager(
        _db.attachedDatabase,
        _db.configurations,
      );
  $$ConfigurationValuesTableTableManager get configurationValues =>
      $$ConfigurationValuesTableTableManager(
        _db.attachedDatabase,
        _db.configurationValues,
      );
  $$ChangeLogsTableTableManager get changeLogs =>
      $$ChangeLogsTableTableManager(_db.attachedDatabase, _db.changeLogs);
  $$PedalReplacementsTableTableManager get pedalReplacements =>
      $$PedalReplacementsTableTableManager(
        _db.attachedDatabase,
        _db.pedalReplacements,
      );
  $$PedalboardsTableTableManager get pedalboards =>
      $$PedalboardsTableTableManager(_db.attachedDatabase, _db.pedalboards);
  $$PedalboardSlotsTableTableManager get pedalboardSlots =>
      $$PedalboardSlotsTableTableManager(
        _db.attachedDatabase,
        _db.pedalboardSlots,
      );
  $$RigSnapshotsTableTableManager get rigSnapshots =>
      $$RigSnapshotsTableTableManager(_db.attachedDatabase, _db.rigSnapshots);
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
