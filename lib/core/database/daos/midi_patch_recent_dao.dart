import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/midi_patch_recents_table.dart';

part 'midi_patch_recent_dao.g.dart';

/// Typed queries over `midi_patch_recents`.
@DriftAccessor(tables: [MidiPatchRecents])
class MidiPatchRecentDao extends DatabaseAccessor<AppDatabase>
    with _$MidiPatchRecentDaoMixin {
  MidiPatchRecentDao(super.attachedDatabase);

  /// The most recently used patches, newest first, app-wide - small enough
  /// that scoping by unit is left to whoever already has that unit's patch
  /// list in hand.
  Stream<List<MidiPatchRecent>> watchRecents({int limit = 20}) {
    return (select(midiPatchRecents)
          ..orderBy([(row) => OrderingTerm.desc(row.lastUsedAt)])
          ..limit(limit))
        .watch();
  }

  Future<void> recordUsed(int patchId, {DateTime Function()? clock}) {
    final now = (clock ?? DateTime.now)();
    return into(midiPatchRecents).insert(
      MidiPatchRecentsCompanion.insert(patchId: patchId, lastUsedAt: now),
      onConflict: DoUpdate(
        (_) => MidiPatchRecentsCompanion(lastUsedAt: Value(now)),
        target: [midiPatchRecents.patchId],
      ),
    );
  }
}
