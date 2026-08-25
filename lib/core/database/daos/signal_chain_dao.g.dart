// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signal_chain_dao.dart';

// ignore_for_file: type=lint
mixin _$SignalChainDaoMixin on DatabaseAccessor<AppDatabase> {
  $PedalboardsTable get pedalboards => attachedDatabase.pedalboards;
  $PedalsTable get pedals => attachedDatabase.pedals;
  $SignalBlocksTable get signalBlocks => attachedDatabase.signalBlocks;
  $SignalConnectionsTable get signalConnections =>
      attachedDatabase.signalConnections;
  SignalChainDaoManager get managers => SignalChainDaoManager(this);
}

class SignalChainDaoManager {
  final _$SignalChainDaoMixin _db;
  SignalChainDaoManager(this._db);
  $$PedalboardsTableTableManager get pedalboards =>
      $$PedalboardsTableTableManager(_db.attachedDatabase, _db.pedalboards);
  $$PedalsTableTableManager get pedals =>
      $$PedalsTableTableManager(_db.attachedDatabase, _db.pedals);
  $$SignalBlocksTableTableManager get signalBlocks =>
      $$SignalBlocksTableTableManager(_db.attachedDatabase, _db.signalBlocks);
  $$SignalConnectionsTableTableManager get signalConnections =>
      $$SignalConnectionsTableTableManager(
        _db.attachedDatabase,
        _db.signalConnections,
      );
}
