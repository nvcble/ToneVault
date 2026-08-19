// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configuration_dao.dart';

// ignore_for_file: type=lint
mixin _$ConfigurationDaoMixin on DatabaseAccessor<AppDatabase> {
  $PedalsTable get pedals => attachedDatabase.pedals;
  $ConfigurationsTable get configurations => attachedDatabase.configurations;
  $PedalControlsTable get pedalControls => attachedDatabase.pedalControls;
  $ConfigurationValuesTable get configurationValues =>
      attachedDatabase.configurationValues;
  ConfigurationDaoManager get managers => ConfigurationDaoManager(this);
}

class ConfigurationDaoManager {
  final _$ConfigurationDaoMixin _db;
  ConfigurationDaoManager(this._db);
  $$PedalsTableTableManager get pedals =>
      $$PedalsTableTableManager(_db.attachedDatabase, _db.pedals);
  $$ConfigurationsTableTableManager get configurations =>
      $$ConfigurationsTableTableManager(
        _db.attachedDatabase,
        _db.configurations,
      );
  $$PedalControlsTableTableManager get pedalControls =>
      $$PedalControlsTableTableManager(_db.attachedDatabase, _db.pedalControls);
  $$ConfigurationValuesTableTableManager get configurationValues =>
      $$ConfigurationValuesTableTableManager(
        _db.attachedDatabase,
        _db.configurationValues,
      );
}
