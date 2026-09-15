// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'midi_preset_capture_dao.dart';

// ignore_for_file: type=lint
mixin _$MidiPresetCaptureDaoMixin on DatabaseAccessor<AppDatabase> {
  $PedalsTable get pedals => attachedDatabase.pedals;
  $MidiPresetCapturesTable get midiPresetCaptures =>
      attachedDatabase.midiPresetCaptures;
  MidiPresetCaptureDaoManager get managers => MidiPresetCaptureDaoManager(this);
}

class MidiPresetCaptureDaoManager {
  final _$MidiPresetCaptureDaoMixin _db;
  MidiPresetCaptureDaoManager(this._db);
  $$PedalsTableTableManager get pedals =>
      $$PedalsTableTableManager(_db.attachedDatabase, _db.pedals);
  $$MidiPresetCapturesTableTableManager get midiPresetCaptures =>
      $$MidiPresetCapturesTableTableManager(
        _db.attachedDatabase,
        _db.midiPresetCaptures,
      );
}
