// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'midi_patch_program_number_dao.dart';

// ignore_for_file: type=lint
mixin _$MidiPatchProgramNumberDaoMixin on DatabaseAccessor<AppDatabase> {
  $PedalsTable get pedals => attachedDatabase.pedals;
  $PatchesTable get patches => attachedDatabase.patches;
  $MidiPatchProgramNumbersTable get midiPatchProgramNumbers =>
      attachedDatabase.midiPatchProgramNumbers;
  MidiPatchProgramNumberDaoManager get managers =>
      MidiPatchProgramNumberDaoManager(this);
}

class MidiPatchProgramNumberDaoManager {
  final _$MidiPatchProgramNumberDaoMixin _db;
  MidiPatchProgramNumberDaoManager(this._db);
  $$PedalsTableTableManager get pedals =>
      $$PedalsTableTableManager(_db.attachedDatabase, _db.pedals);
  $$PatchesTableTableManager get patches =>
      $$PatchesTableTableManager(_db.attachedDatabase, _db.patches);
  $$MidiPatchProgramNumbersTableTableManager get midiPatchProgramNumbers =>
      $$MidiPatchProgramNumbersTableTableManager(
        _db.attachedDatabase,
        _db.midiPatchProgramNumbers,
      );
}
