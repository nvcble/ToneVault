import 'package:drift/drift.dart';

import 'pedalboards_table.dart';

/// A rig as it stood on one date: what was on the board and where every knob
/// was.
///
/// The board itself keeps changing, so a snapshot copies the readings rather
/// than pointing at configurations that can be re-tweaked afterwards; see
/// `RigSnapshotValues`. That is what makes "what I played at Easter" answerable
/// a year later.
///
/// The rig is referenced with RESTRICT: a rig that has been played and recorded
/// is not something to lose by tidying up a name, so it has to have its
/// snapshots deleted first.
///
/// Two snapshots of one rig may share a name. Each carries the date it was
/// taken, which is what tells "Easter" in 2026 from "Easter" in 2027.
@TableIndex(
  name: 'idx_rig_snapshots_board_captured',
  columns: {#pedalboardId, #capturedAt},
)
class RigSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get pedalboardId =>
      integer().references(Pedalboards, #id, onDelete: KeyAction.restrict)();

  TextColumn get name => text().withLength(min: 1, max: 80)();

  TextColumn get notes => text().nullable()();

  /// When the rig looked like this, which is the snapshot's whole point and so
  /// is never rewritten. The name and notes stay editable.
  DateTimeColumn get capturedAt => dateTime()();
}
