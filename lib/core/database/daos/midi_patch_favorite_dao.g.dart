// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'midi_patch_favorite_dao.dart';

// ignore_for_file: type=lint
mixin _$MidiPatchFavoriteDaoMixin on DatabaseAccessor<AppDatabase> {
  $PedalsTable get pedals => attachedDatabase.pedals;
  $PatchesTable get patches => attachedDatabase.patches;
  $MidiPatchFavoritesTable get midiPatchFavorites =>
      attachedDatabase.midiPatchFavorites;
  MidiPatchFavoriteDaoManager get managers => MidiPatchFavoriteDaoManager(this);
}

class MidiPatchFavoriteDaoManager {
  final _$MidiPatchFavoriteDaoMixin _db;
  MidiPatchFavoriteDaoManager(this._db);
  $$PedalsTableTableManager get pedals =>
      $$PedalsTableTableManager(_db.attachedDatabase, _db.pedals);
  $$PatchesTableTableManager get patches =>
      $$PatchesTableTableManager(_db.attachedDatabase, _db.patches);
  $$MidiPatchFavoritesTableTableManager get midiPatchFavorites =>
      $$MidiPatchFavoritesTableTableManager(
        _db.attachedDatabase,
        _db.midiPatchFavorites,
      );
}
