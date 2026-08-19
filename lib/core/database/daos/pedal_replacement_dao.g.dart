// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedal_replacement_dao.dart';

// ignore_for_file: type=lint
mixin _$PedalReplacementDaoMixin on DatabaseAccessor<AppDatabase> {
  $PedalsTable get pedals => attachedDatabase.pedals;
  $PedalReplacementsTable get pedalReplacements =>
      attachedDatabase.pedalReplacements;
  PedalReplacementDaoManager get managers => PedalReplacementDaoManager(this);
}

class PedalReplacementDaoManager {
  final _$PedalReplacementDaoMixin _db;
  PedalReplacementDaoManager(this._db);
  $$PedalsTableTableManager get pedals =>
      $$PedalsTableTableManager(_db.attachedDatabase, _db.pedals);
  $$PedalReplacementsTableTableManager get pedalReplacements =>
      $$PedalReplacementsTableTableManager(
        _db.attachedDatabase,
        _db.pedalReplacements,
      );
}
