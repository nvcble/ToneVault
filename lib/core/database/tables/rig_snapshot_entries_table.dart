import 'package:drift/drift.dart';

import 'pedals_table.dart';
import 'rig_snapshots_table.dart';

/// One pedal within one snapshot, at the place in the chain it held that day.
///
/// The pedal is referenced rather than copied: a pedal row is never deleted once
/// anything references it, so the link stays good and a snapshot can be read
/// through to the pedal it names.
///
/// [configurationName] is copied text, not a reference. It records which preset
/// was dialled in under the name it had at the time, so renaming or deleting
/// that configuration afterwards cannot rewrite what the snapshot says. The
/// readings themselves are in `RigSnapshotValues`.
@TableIndex(
  name: 'idx_rig_snapshot_entries_snapshot_position',
  columns: {#snapshotId, #position},
)
class RigSnapshotEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get snapshotId =>
      integer().references(RigSnapshots, #id, onDelete: KeyAction.cascade)();

  IntColumn get pedalId =>
      integer().references(Pedals, #id, onDelete: KeyAction.restrict)();

  /// Zero-based, in the order signal reached it, exactly as the chain read.
  IntColumn get position => integer()();

  TextColumn get configurationName =>
      text().withLength(min: 1, max: 80).nullable()();

  /// One pedal appears on a board once, so it appears in a snapshot of that
  /// board once too.
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {snapshotId, pedalId},
  ];
}
