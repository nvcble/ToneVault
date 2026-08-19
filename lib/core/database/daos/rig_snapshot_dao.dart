import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/pedals_table.dart';
import '../tables/rig_snapshot_entries_table.dart';
import '../tables/rig_snapshot_values_table.dart';
import '../tables/rig_snapshots_table.dart';

part 'rig_snapshot_dao.g.dart';

/// One pedal in a snapshot: where it sat, the pedal it still points at, and the
/// readings frozen with it.
typedef SnapshotEntry = ({
  RigSnapshotEntry entry,
  Pedal pedal,
  List<RigSnapshotValue> values,
});

/// Typed queries over saved snapshots of a rig.
///
/// Timestamps, what gets copied at capture and error translation belong to
/// `RigSnapshotRepository`; this class only reads and writes rows.
@DriftAccessor(
  tables: [RigSnapshots, RigSnapshotEntries, RigSnapshotValues, Pedals],
)
class RigSnapshotDao extends DatabaseAccessor<AppDatabase>
    with _$RigSnapshotDaoMixin {
  RigSnapshotDao(super.attachedDatabase);

  /// One rig's snapshots, newest first, since the last thing played is the thing
  /// most likely being looked up.
  Stream<List<RigSnapshot>> watchSnapshots(int pedalboardId) {
    return (select(rigSnapshots)
          ..where((row) => row.pedalboardId.equals(pedalboardId))
          ..orderBy([
            (row) => OrderingTerm.desc(row.capturedAt),
            (row) => OrderingTerm.desc(row.id),
          ]))
        .watch();
  }

  Stream<RigSnapshot?> watchSnapshot(int snapshotId) {
    return (select(
      rigSnapshots,
    )..where((row) => row.id.equals(snapshotId))).watchSingleOrNull();
  }

  Future<RigSnapshot?> findSnapshot(int snapshotId) {
    return (select(
      rigSnapshots,
    )..where((row) => row.id.equals(snapshotId))).getSingleOrNull();
  }

  Future<int> insertSnapshot(RigSnapshotsCompanion snapshot) =>
      into(rigSnapshots).insert(snapshot);

  /// Returns whether a row matched [snapshotId].
  Future<bool> updateSnapshot(
    int snapshotId,
    RigSnapshotsCompanion changes,
  ) async {
    final changedRows = await (update(
      rigSnapshots,
    )..where((row) => row.id.equals(snapshotId))).write(changes);
    return changedRows > 0;
  }

  Future<bool> deleteSnapshot(int snapshotId) async {
    final deletedRows = await (delete(
      rigSnapshots,
    )..where((row) => row.id.equals(snapshotId))).go();
    return deletedRows > 0;
  }

  Future<int> insertEntry(RigSnapshotEntriesCompanion entry) =>
      into(rigSnapshotEntries).insert(entry);

  Future<void> insertValues(Iterable<RigSnapshotValuesCompanion> values) async {
    await batch((batch) => batch.insertAll(rigSnapshotValues, values));
  }

  /// What one snapshot recorded, in the order signal ran through it.
  ///
  /// A left join, so a pedal captured with no configuration dialled in still
  /// appears in the chain with no readings under it.
  Stream<List<SnapshotEntry>> watchEntries(int snapshotId) {
    final query =
        select(rigSnapshotEntries).join([
            innerJoin(pedals, pedals.id.equalsExp(rigSnapshotEntries.pedalId)),
            leftOuterJoin(
              rigSnapshotValues,
              rigSnapshotValues.entryId.equalsExp(rigSnapshotEntries.id),
            ),
          ])
          ..where(rigSnapshotEntries.snapshotId.equals(snapshotId))
          ..orderBy([
            OrderingTerm.asc(rigSnapshotEntries.position),
            OrderingTerm.asc(rigSnapshotEntries.id),
            OrderingTerm.asc(rigSnapshotValues.displayOrder),
            OrderingTerm.asc(rigSnapshotValues.id),
          ]);

    return query.watch().map(_groupByEntry);
  }

  /// Collapses the joined rows, one per reading, back into one record per pedal.
  List<SnapshotEntry> _groupByEntry(List<TypedResult> rows) {
    final entries = <int, RigSnapshotEntry>{};
    final pedalsById = <int, Pedal>{};
    final valuesByEntry = <int, List<RigSnapshotValue>>{};

    for (final row in rows) {
      final entry = row.readTable(rigSnapshotEntries);
      entries[entry.id] = entry;
      pedalsById[entry.id] = row.readTable(pedals);

      final value = row.readTableOrNull(rigSnapshotValues);
      final values = valuesByEntry.putIfAbsent(entry.id, () => []);
      if (value != null) {
        values.add(value);
      }
    }

    // Insertion order, which the query already put in signal order.
    return [
      for (final entry in entries.values)
        (
          entry: entry,
          pedal: pedalsById[entry.id]!,
          values: valuesByEntry[entry.id]!,
        ),
    ];
  }
}
