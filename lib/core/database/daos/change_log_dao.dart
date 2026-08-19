import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/change_logs_table.dart';
import '../tables/pedals_table.dart';

part 'change_log_dao.g.dart';

/// One history entry together with the pedal it belongs to, for the screens that
/// mix several pedals into one list.
typedef PedalChange = ({ChangeLog entry, String pedalName});

/// Typed queries over the append-only `change_logs` table.
///
/// Timestamps and error translation belong to `ChangeLogRepository`; this class
/// only reads and writes rows. There is deliberately no update method: an entry
/// records what happened, and what happened does not change.
@DriftAccessor(tables: [ChangeLogs, Pedals])
class ChangeLogDao extends DatabaseAccessor<AppDatabase>
    with _$ChangeLogDaoMixin {
  ChangeLogDao(super.attachedDatabase);

  Future<int> insertEntry(ChangeLogsCompanion entry) =>
      into(changeLogs).insert(entry);

  /// The newest changes across every pedal.
  ///
  /// Limited rather than unbounded: the history of a well-used rig grows without
  /// end, and a screen only ever shows the top of it.
  Stream<List<PedalChange>> watchRecentChanges({required int limit}) {
    final query = select(
      changeLogs,
    ).join([innerJoin(pedals, pedals.id.equalsExp(changeLogs.pedalId))]);
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
            ),
          )
          .toList(),
    );
  }

  Stream<List<ChangeLog>> watchPedalChanges(int pedalId, {required int limit}) {
    return (select(changeLogs)
          ..where((row) => row.pedalId.equals(pedalId))
          ..orderBy([
            (row) => OrderingTerm.desc(row.createdAt),
            (row) => OrderingTerm.desc(row.id),
          ])
          ..limit(limit))
        .watch();
  }

  Future<List<ChangeLog>> entriesOf(int pedalId) {
    return (select(
      changeLogs,
    )..where((row) => row.pedalId.equals(pedalId))).get();
  }

  /// Removes a pedal's history, only for use when the pedal itself is going.
  ///
  /// `change_logs.pedal_id` restricts deletion on purpose, so history cannot be
  /// lost by accident; a pedal being deleted outright has to clear it explicitly
  /// in the same transaction or the foreign key blocks the delete.
  Future<int> deleteForPedal(int pedalId) {
    return (delete(
      changeLogs,
    )..where((row) => row.pedalId.equals(pedalId))).go();
  }
}
