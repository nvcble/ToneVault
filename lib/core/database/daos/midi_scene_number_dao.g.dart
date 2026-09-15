// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'midi_scene_number_dao.dart';

// ignore_for_file: type=lint
mixin _$MidiSceneNumberDaoMixin on DatabaseAccessor<AppDatabase> {
  $PedalsTable get pedals => attachedDatabase.pedals;
  $PatchesTable get patches => attachedDatabase.patches;
  $ScenesTable get scenes => attachedDatabase.scenes;
  $MidiSceneNumbersTable get midiSceneNumbers =>
      attachedDatabase.midiSceneNumbers;
  MidiSceneNumberDaoManager get managers => MidiSceneNumberDaoManager(this);
}

class MidiSceneNumberDaoManager {
  final _$MidiSceneNumberDaoMixin _db;
  MidiSceneNumberDaoManager(this._db);
  $$PedalsTableTableManager get pedals =>
      $$PedalsTableTableManager(_db.attachedDatabase, _db.pedals);
  $$PatchesTableTableManager get patches =>
      $$PatchesTableTableManager(_db.attachedDatabase, _db.patches);
  $$ScenesTableTableManager get scenes =>
      $$ScenesTableTableManager(_db.attachedDatabase, _db.scenes);
  $$MidiSceneNumbersTableTableManager get midiSceneNumbers =>
      $$MidiSceneNumbersTableTableManager(
        _db.attachedDatabase,
        _db.midiSceneNumbers,
      );
}
