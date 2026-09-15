import 'package:drift/drift.dart';

import 'pedals_table.dart';

/// Which owned pedal is a live-controllable MIDI device, and which device
/// profile speaks for it.
///
/// A pedal exists independently of this: most are never linked, because most
/// are not MIDI devices at all. A link is what turns an ordinary logged unit
/// into one the MIDI module can connect to and send patches/scenes to.
@DataClassName('MidiDeviceLink')
@TableIndex(name: 'idx_midi_device_links_profile', columns: {#deviceProfileId})
class MidiDeviceLinks extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Restricted, like every other reference to a pedal: retiring the unit
  /// keeps the link's record of what it was rather than losing it.
  IntColumn get pedalId => integer()
      .references(Pedals, #id, onDelete: KeyAction.restrict)
      .unique()();

  TextColumn get deviceProfileId => text().withLength(min: 1, max: 60)();

  DateTimeColumn get linkedAt => dateTime()();
}
