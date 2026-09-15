import 'package:drift/drift.dart';

import 'pedals_table.dart';

/// One raw SysEx preset dump read off a device, kept alongside whatever the
/// decoder made of it - see the diagnostic/preset-import brief's "Raw Preset
/// Storage" requirement.
///
/// [rawSysEx] is the exact wire bytes: if a decoder improves later, a
/// capture can be re-decoded without reconnecting to the device. Deliberately
/// separate from `Patches`/`Scenes` - nothing here is trusted enough yet to
/// be a real library patch; see `NuxMg30V5PresetDecoder`'s own documentation
/// for what it does and does not decode.
@DataClassName('MidiPresetCapture')
class MidiPresetCaptures extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get pedalId => integer().references(Pedals, #id, onDelete: KeyAction.cascade)();

  /// Which device profile's protocol this capture should be read with, e.g.
  /// "nux_mg30_v5" - never assumed from context, since a unit could in
  /// principle be relinked to a different profile later.
  TextColumn get deviceProfileId => text()();

  IntColumn get programNumber => integer()();

  BlobColumn get rawSysEx => blob()();

  /// The decoder's best-effort name, or null if that field did not decode.
  TextColumn get decodedName => text().nullable()();

  /// The rest of what the decoder produced, as JSON - kept as one column
  /// rather than a table per field, since which fields exist depends on the
  /// decoder version that produced this row.
  TextColumn get decodedSummaryJson => text().nullable()();

  /// What this capture's firmware identify response said, if anything - not
  /// assumed to be the profile's own [firmwareVersion] label.
  TextColumn get firmwareLabel => text().nullable()();

  DateTimeColumn get capturedAt => dateTime()();

  @override
  List<Set<Column>>? get uniqueKeys => [
    {pedalId, programNumber},
  ];
}
