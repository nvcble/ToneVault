// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'midi_device_link_dao.dart';

// ignore_for_file: type=lint
mixin _$MidiDeviceLinkDaoMixin on DatabaseAccessor<AppDatabase> {
  $PedalsTable get pedals => attachedDatabase.pedals;
  $MidiDeviceLinksTable get midiDeviceLinks => attachedDatabase.midiDeviceLinks;
  MidiDeviceLinkDaoManager get managers => MidiDeviceLinkDaoManager(this);
}

class MidiDeviceLinkDaoManager {
  final _$MidiDeviceLinkDaoMixin _db;
  MidiDeviceLinkDaoManager(this._db);
  $$PedalsTableTableManager get pedals =>
      $$PedalsTableTableManager(_db.attachedDatabase, _db.pedals);
  $$MidiDeviceLinksTableTableManager get midiDeviceLinks =>
      $$MidiDeviceLinksTableTableManager(
        _db.attachedDatabase,
        _db.midiDeviceLinks,
      );
}
