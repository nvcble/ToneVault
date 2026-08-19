import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/change_logs_table.dart';
import '../tables/pedal_controls_table.dart';
import '../tables/pedals_table.dart';

part 'change_log_dao.g.dart';

/// One history entry with everything a screen needs to render it.
///
/// The pedal name comes along because the history list mixes pedals together.
/// The control comes along because a stored value is only a number until its own
/// control says whether that number is a clock position, a percentage or a mode:
/// it is null once the control has been removed, which is exactly when the
/// entry's copy of the name is all there is left to show.
typedef PedalChange = ({
  ChangeLog entry,
  String pedalName,
  PedalControl? control,
});

/// Typed queries over the append-only `change_logs` table.
///
/// Timestamps and error translation belong to `ChangeLogRepository`; this class
/// only reads and writes rows. There is deliberately no update method: an entry
/// records what happened, and what happened does not change.
@DriftAccessor(tables: [ChangeLogs, Pedals, PedalControls])
class ChangeLogDao extends DatabaseAccessor<AppDatabase>
    with _$ChangeLogDaoMixin {
  ChangeLogDao(super.attachedDatabase);

  Future<int> insertEntry(ChangeLogsCompanion entry) =>
      into(changeLogs).insert(entry);

  /// The newest changes across every pedal.
  ///
  /// Limited rather than unbounded: the history of a well-used rig grows without
  /// end, and a screen only ever shows the top of it.
  Stream<List<PedalChange>> watchRecentChanges({required int limit}) =>
      _watchChanges(limit: limit);

  /// The same timeline narrowed to one pedal, for its own history tab.
  Stream<List<PedalChange>> watchPedalChanges(
    int pedalId, {
    required int limit,
  }) => _watchChanges(limit: limit, pedalId: pedalId);

  Stream<List<PedalChange>> _watchChanges({required int limit, int? pedalId}) {
    final query = select(changeLogs).join([
      innerJoin(pedals, pedals.id.equalsExp(changeLogs.pedalId)),
      // Outer, because an entry outlives the control it was recorded about.
      leftOuterJoin(
        pedalControls,
        pedalControls.id.equalsExp(changeLogs.controlId),
      ),
    ]);
    if (pedalId != null) {
      query.where(changeLogs.pedalId.equals(pedalId));
    }
    // The id breaks ties: several changes saved in one transaction share a
    // timestamp, and insertion order is the real order.
    query.orderBy([
      OrderingTerm.desc(changeLogs.createdAt),
      OrderingTerm.desc(changeLogs.id),
    ]);
    query.limit(limit);

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => (
              entry: row.readTable(changeLogs),
              pedalName: row.readTable(pedals).name,
              control: row.readTableOrNull(pedalControls),
            ),
          )
          .toList(),
    );
  }

  Future<List<ChangeLog>> entriesOf(int pedalId) {
    return (select(
      changeLogs,
    )..where((row) => row.pedalId.equals(pedalId))).get();
  }
}
