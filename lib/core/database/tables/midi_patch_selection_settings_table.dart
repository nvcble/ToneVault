import 'package:drift/drift.dart';

/// A user's own patch-selection strategy for one device profile, where it
/// differs from the profile's own [PatchSelectionDefaults].
///
/// One row per device profile rather than per parameter, unlike
/// `MidiParameterOverrides`: Bank Select and Program Change are a sequence
/// with its own shape, not a single named value. Every column is nullable for
/// the same reason every column in that table is absent by default - null
/// means "use the device profile's own candidate", not "off".
@DataClassName('MidiPatchSelectionSetting')
class MidiPatchSelectionSettings extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get deviceProfileId =>
      text().withLength(min: 1, max: 60).unique()();

  BoolColumn get usesBankSelect => boolean().nullable()();

  IntColumn get bankSelectMsb => integer().nullable()();

  IntColumn get bankSelectLsb => integer().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<String> get customConstraints => [
    'CHECK (bank_select_msb IS NULL OR bank_select_msb BETWEEN 0 AND 127)',
    'CHECK (bank_select_lsb IS NULL OR bank_select_lsb BETWEEN 0 AND 127)',
  ];
}
