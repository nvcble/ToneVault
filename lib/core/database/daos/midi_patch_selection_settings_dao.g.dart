// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'midi_patch_selection_settings_dao.dart';

// ignore_for_file: type=lint
mixin _$MidiPatchSelectionSettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $MidiPatchSelectionSettingsTable get midiPatchSelectionSettings =>
      attachedDatabase.midiPatchSelectionSettings;
  MidiPatchSelectionSettingsDaoManager get managers =>
      MidiPatchSelectionSettingsDaoManager(this);
}

class MidiPatchSelectionSettingsDaoManager {
  final _$MidiPatchSelectionSettingsDaoMixin _db;
  MidiPatchSelectionSettingsDaoManager(this._db);
  $$MidiPatchSelectionSettingsTableTableManager
  get midiPatchSelectionSettings =>
      $$MidiPatchSelectionSettingsTableTableManager(
        _db.attachedDatabase,
        _db.midiPatchSelectionSettings,
      );
}
