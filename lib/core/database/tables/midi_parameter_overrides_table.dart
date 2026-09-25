import 'package:drift/drift.dart';

/// A user's own CC number for one named MIDI parameter of one device profile,
/// where it differs from the profile's shipped default.
///
/// Mirrors what NUX's own QuickTone app lets a user do on the MG-30 itself:
/// remap which CC a function answers to. A row here exists only for a
/// parameter the user has actually changed - absence means "use the device
/// profile's default", so resetting one is deleting its row rather than
/// writing the default back into it.
///
/// [deviceProfileId] and [parameterName] are strings rather than foreign keys:
/// a device profile and its parameters are code, not rows, so there is
/// nothing in another table for this to reference.
@DataClassName('MidiParameterOverride')
@TableIndex(
  name: 'idx_midi_parameter_overrides_device',
  columns: {#deviceProfileId},
)
class MidiParameterOverrides extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get deviceProfileId => text().withLength(min: 1, max: 60)();

  /// Matches a `MidiParameterDefinition.name` the device profile ships.
  TextColumn get parameterName => text().withLength(min: 1, max: 80)();

  IntColumn get ccNumber => integer()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {deviceProfileId, parameterName},
  ];

  @override
  List<String> get customConstraints => ['CHECK (cc_number BETWEEN 0 AND 127)'];
}
