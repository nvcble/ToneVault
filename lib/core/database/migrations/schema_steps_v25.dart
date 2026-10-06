import 'package:drift/drift.dart';

/// `academy_lessons.image_url` and `.video_url`, the picture of a lesson and the
/// video of somebody teaching it.
///
/// Two nullable columns with no default, so every lesson already stored reads
/// exactly as it did and simply says neither - which is what the shipped curriculum
/// says too. Nothing is backfilled in SQL: where a lesson names no picture and no
/// video the screen works both out from what the lesson already has, so there is no
/// value here worth writing a hundred times.
///
/// Purely additive - two ADD COLUMNs, no DROP and no table rebuild.
Future<void> upgradeThroughV25(GeneratedDatabase database, int from) async {
  if (from < 25) {
    final columns = await database
        .customSelect('PRAGMA table_info("academy_lessons")')
        .get();
    // No rows at all means there is no such table: a database that never held the
    // Academy has nothing here to add a column to, and saying nothing is what keeps
    // the rest of the chain running for it.
    if (columns.isEmpty) {
      return;
    }

    final names = columns.map((row) => row.read<String>('name')).toSet();

    // Guarded one by one: ADD COLUMN throws on a duplicate, which would brick the
    // whole migration chain for the sake of a column that was already there.
    for (final column in const ['image_url', 'video_url']) {
      if (!names.contains(column)) {
        await database.customStatement(
          'ALTER TABLE "academy_lessons" ADD COLUMN "$column" TEXT NULL',
        );
      }
    }
  }
}
