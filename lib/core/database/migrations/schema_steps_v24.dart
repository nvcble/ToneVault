import 'package:drift/drift.dart';

/// `hotone_ampero_mini_patches.local_label`, the name the user typed for a
/// patch slot themselves.
///
/// A separate column from `name` on purpose: `name` holds only what was
/// decoded from bytes the pedal sent, and the Ampero Mini has no confirmed
/// patch-read command, so it is null everywhere. Merging the two would make a
/// hand-typed label unidentifiable as such once stored.
///
/// Purely additive - one ADD COLUMN, no DROP and no table rebuild, so every
/// existing row keeps its data and gets NULL for the new column.
Future<void> upgradeThroughV24(GeneratedDatabase database, int from) async {
  if (from < 24) {
    // v23's CREATE TABLE does not list this column, so the ALTER is what adds
    // it on every upgrading phone. Guarded anyway: ADD COLUMN throws on a
    // duplicate, which would brick the whole migration chain, and that is a
    // cheap thing to rule out rather than trust.
    final columns = await database
        .customSelect('PRAGMA table_info("hotone_ampero_mini_patches")')
        .get();
    final hasColumn = columns.any(
      (row) => row.read<String>('name') == 'local_label',
    );
    if (!hasColumn) {
      await database.customStatement(
        'ALTER TABLE "hotone_ampero_mini_patches" ADD COLUMN "local_label" TEXT NULL',
      );
    }
  }
}
