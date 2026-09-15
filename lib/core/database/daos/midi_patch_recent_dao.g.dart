// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'midi_patch_recent_dao.dart';

// ignore_for_file: type=lint
mixin _$MidiPatchRecentDaoMixin on DatabaseAccessor<AppDatabase> {
  $PedalsTable get pedals => attachedDatabase.pedals;
  $PatchesTable get patches => attachedDatabase.patches;
  $MidiPatchRecentsTable get midiPatchRecents =>
      attachedDatabase.midiPatchRecents;
  MidiPatchRecentDaoManager get managers => MidiPatchRecentDaoManager(this);
}

class MidiPatchRecentDaoManager {
  final _$MidiPatchRecentDaoMixin _db;
  MidiPatchRecentDaoManager(this._db);
  $$PedalsTableTableManager get pedals =>
      $$PedalsTableTableManager(_db.attachedDatabase, _db.pedals);
  $$PatchesTableTableManager get patches =>
      $$PatchesTableTableManager(_db.attachedDatabase, _db.patches);
  $$MidiPatchRecentsTableTableManager get midiPatchRecents =>
      $$MidiPatchRecentsTableTableManager(
        _db.attachedDatabase,
        _db.midiPatchRecents,
      );
}
