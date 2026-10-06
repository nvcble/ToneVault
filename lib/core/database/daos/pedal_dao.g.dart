// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedal_dao.dart';

// ignore_for_file: type=lint
mixin _$PedalDaoMixin on DatabaseAccessor<AppDatabase> {
  $PedalsTable get pedals => attachedDatabase.pedals;
  $PedalboardsTable get pedalboards => attachedDatabase.pedalboards;
  $SignalBlocksTable get signalBlocks => attachedDatabase.signalBlocks;
  $PatchesTable get patches => attachedDatabase.patches;
  $ConfigurationsTable get configurations => attachedDatabase.configurations;
  $PedalControlsTable get pedalControls => attachedDatabase.pedalControls;
  $ChangeLogsTable get changeLogs => attachedDatabase.changeLogs;
  $MidiDeviceLinksTable get midiDeviceLinks => attachedDatabase.midiDeviceLinks;
  PedalDaoManager get managers => PedalDaoManager(this);
}

class PedalDaoManager {
  final _$PedalDaoMixin _db;
  PedalDaoManager(this._db);
  $$PedalsTableTableManager get pedals =>
      $$PedalsTableTableManager(_db.attachedDatabase, _db.pedals);
  $$PedalboardsTableTableManager get pedalboards =>
      $$PedalboardsTableTableManager(_db.attachedDatabase, _db.pedalboards);
  $$SignalBlocksTableTableManager get signalBlocks =>
      $$SignalBlocksTableTableManager(_db.attachedDatabase, _db.signalBlocks);
  $$PatchesTableTableManager get patches =>
      $$PatchesTableTableManager(_db.attachedDatabase, _db.patches);
  $$ConfigurationsTableTableManager get configurations =>
      $$ConfigurationsTableTableManager(
        _db.attachedDatabase,
        _db.configurations,
      );
  $$PedalControlsTableTableManager get pedalControls =>
      $$PedalControlsTableTableManager(_db.attachedDatabase, _db.pedalControls);
  $$ChangeLogsTableTableManager get changeLogs =>
      $$ChangeLogsTableTableManager(_db.attachedDatabase, _db.changeLogs);
  $$MidiDeviceLinksTableTableManager get midiDeviceLinks =>
      $$MidiDeviceLinksTableTableManager(
        _db.attachedDatabase,
        _db.midiDeviceLinks,
      );
}
