// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'midi_parameter_override_dao.dart';

// ignore_for_file: type=lint
mixin _$MidiParameterOverrideDaoMixin on DatabaseAccessor<AppDatabase> {
  $MidiParameterOverridesTable get midiParameterOverrides =>
      attachedDatabase.midiParameterOverrides;
  MidiParameterOverrideDaoManager get managers =>
      MidiParameterOverrideDaoManager(this);
}

class MidiParameterOverrideDaoManager {
  final _$MidiParameterOverrideDaoMixin _db;
  MidiParameterOverrideDaoManager(this._db);
  $$MidiParameterOverridesTableTableManager get midiParameterOverrides =>
      $$MidiParameterOverridesTableTableManager(
        _db.attachedDatabase,
        _db.midiParameterOverrides,
      );
}
