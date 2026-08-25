// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signal_endpoint_dao.dart';

// ignore_for_file: type=lint
mixin _$SignalEndpointDaoMixin on DatabaseAccessor<AppDatabase> {
  $PedalboardsTable get pedalboards => attachedDatabase.pedalboards;
  $PedalsTable get pedals => attachedDatabase.pedals;
  $SignalBlocksTable get signalBlocks => attachedDatabase.signalBlocks;
  $SignalEndpointsTable get signalEndpoints => attachedDatabase.signalEndpoints;
  SignalEndpointDaoManager get managers => SignalEndpointDaoManager(this);
}

class SignalEndpointDaoManager {
  final _$SignalEndpointDaoMixin _db;
  SignalEndpointDaoManager(this._db);
  $$PedalboardsTableTableManager get pedalboards =>
      $$PedalboardsTableTableManager(_db.attachedDatabase, _db.pedalboards);
  $$PedalsTableTableManager get pedals =>
      $$PedalsTableTableManager(_db.attachedDatabase, _db.pedals);
  $$SignalBlocksTableTableManager get signalBlocks =>
      $$SignalBlocksTableTableManager(_db.attachedDatabase, _db.signalBlocks);
  $$SignalEndpointsTableTableManager get signalEndpoints =>
      $$SignalEndpointsTableTableManager(
        _db.attachedDatabase,
        _db.signalEndpoints,
      );
}
