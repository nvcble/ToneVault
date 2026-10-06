// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mg30_patch_payload_dao.dart';

// ignore_for_file: type=lint
mixin _$Mg30PatchPayloadDaoMixin on DatabaseAccessor<AppDatabase> {
  $PedalsTable get pedals => attachedDatabase.pedals;
  $PatchesTable get patches => attachedDatabase.patches;
  $Mg30PatchPayloadsTable get mg30PatchPayloads =>
      attachedDatabase.mg30PatchPayloads;
  Mg30PatchPayloadDaoManager get managers => Mg30PatchPayloadDaoManager(this);
}

class Mg30PatchPayloadDaoManager {
  final _$Mg30PatchPayloadDaoMixin _db;
  Mg30PatchPayloadDaoManager(this._db);
  $$PedalsTableTableManager get pedals =>
      $$PedalsTableTableManager(_db.attachedDatabase, _db.pedals);
  $$PatchesTableTableManager get patches =>
      $$PatchesTableTableManager(_db.attachedDatabase, _db.patches);
  $$Mg30PatchPayloadsTableTableManager get mg30PatchPayloads =>
      $$Mg30PatchPayloadsTableTableManager(
        _db.attachedDatabase,
        _db.mg30PatchPayloads,
      );
}
