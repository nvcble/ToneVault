import 'package:drift/drift.dart';

import 'patches_table.dart';

/// A patch the user has starred, for the Patch Browser's favorites section.
@DataClassName('MidiPatchFavorite')
class MidiPatchFavorites extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get patchId => integer()
      .references(Patches, #id, onDelete: KeyAction.cascade)
      .unique()();

  DateTimeColumn get createdAt => dateTime()();
}
