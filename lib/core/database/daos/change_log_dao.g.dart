// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_log_dao.dart';

// ignore_for_file: type=lint
mixin _$ChangeLogDaoMixin on DatabaseAccessor<AppDatabase> {
  $PedalsTable get pedals => attachedDatabase.pedals;
  $ConfigurationsTable get configurations => attachedDatabase.configurations;
  $PedalControlsTable get pedalControls => attachedDatabase.pedalControls;
  $ChangeLogsTable get changeLogs => attachedDatabase.changeLogs;
  ChangeLogDaoManager get managers => ChangeLogDaoManager(this);
}

class ChangeLogDaoManager {
  final _$ChangeLogDaoMixin _db;
  ChangeLogDaoManager(this._db);
  $$PedalsTableTableManager get pedals =>
      $$PedalsTableTableManager(_db.attachedDatabase, _db.pedals);
  $$ConfigurationsTableTableManager get configurations =>
      $$ConfigurationsTableTableManager(
        _db.attachedDatabase,
        _db.configurations,
      );
  $$PedalControlsTableTableManager get pedalControls =>
      $$PedalControlsTableTableManager(_db.attachedDatabase, _db.pedalControls);
  $$ChangeLogsTableTableManager get changeLogs =>
      $$ChangeLogsTableTableManager(_db.attachedDatabase, _db.changeLogs);
}
