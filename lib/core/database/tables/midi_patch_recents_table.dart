import 'package:drift/drift.dart';

import 'patches_table.dart';

/// When a patch was last successfully loaded onto the device, for the Patch
/// Browser's "Recently Used" section.
///
/// Written only after `PatchControlController.loadPatch` actually succeeds -
/// never on a tap alone - so this stays a record of what the device was
/// really switched to.
@DataClassName('MidiPatchRecent')
class MidiPatchRecents extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get patchId => integer()
      .references(Patches, #id, onDelete: KeyAction.cascade)
      .unique()();

  DateTimeColumn get lastUsedAt => dateTime()();
}
