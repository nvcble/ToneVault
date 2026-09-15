import 'package:drift/drift.dart';

import 'patches_table.dart';

/// Which Program Change number one patch loads as, on the device it belongs
/// to - see `PatchControlController`.
///
/// A patch with no row here has never been given a number, and cannot be
/// loaded until it is: there is no default to fall back to, unlike a MIDI
/// parameter's CC, because a program number says which of the device's own
/// slots this patch corresponds to, and guessing one would point at whatever
/// patch happens to already be in that slot.
@DataClassName('MidiPatchProgramNumber')
class MidiPatchProgramNumbers extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get patchId => integer()
      .references(Patches, #id, onDelete: KeyAction.cascade)
      .unique()();

  /// Counted from 0, the same as the Program Change value sent on the wire -
  /// `buildPatchSelectionMessages` sends this number unchanged. A device's
  /// first slot is 0 and its last is 127.
  IntColumn get programNumber => integer()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<String> get customConstraints => [
    'CHECK (program_number BETWEEN 0 AND 127)',
  ];
}
