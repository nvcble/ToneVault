import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/pedalboards_table.dart';
import '../tables/rig_snapshots_table.dart';

part 'pedalboard_dao.g.dart';

/// Typed queries over `pedalboards` themselves.
///
/// The chain a rig holds is `SignalChainDao`'s, so that neither class has to be
/// read whole to be understood. Timestamps, validation and error translation
/// belong to `PedalboardRepository`; this class only reads and writes rows.
@DriftAccessor(tables: [Pedalboards, RigSnapshots])
class PedalboardDao extends DatabaseAccessor<AppDatabase>
    with _$PedalboardDaoMixin {
  PedalboardDao(super.attachedDatabase);

  /// Every rig, ordered by name.
  ///
  /// SQLite's default collation is case-sensitive, which would sort "home" after
  /// "Worship", so the ordering is explicitly case-insensitive.
  Stream<List<Pedalboard>> watchPedalboards() {
    return (select(pedalboards)..orderBy([
          (row) => OrderingTerm.asc(row.name.collate(Collate.noCase)),
        ]))
        .watch();
  }

  Stream<Pedalboard?> watchPedalboard(int pedalboardId) {
    return (select(
      pedalboards,
    )..where((row) => row.id.equals(pedalboardId))).watchSingleOrNull();
  }

  Future<Pedalboard?> findPedalboard(int pedalboardId) {
    return (select(
      pedalboards,
    )..where((row) => row.id.equals(pedalboardId))).getSingleOrNull();
  }

  /// The rig called [name], whatever case it was stored in.
  ///
  /// `pedalboards.name` is unique, but SQLite compares text case-sensitively, so
  /// the constraint alone would let "Home" and "home" both exist.
  Future<Pedalboard?> findByName(String name) {
    return (select(pedalboards)
          ..where((row) => row.name.lower().equals(name.toLowerCase()))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> insertPedalboard(PedalboardsCompanion pedalboard) =>
      into(pedalboards).insert(pedalboard);

  /// Returns whether a row matched [pedalboardId].
  Future<bool> updatePedalboard(
    int pedalboardId,
    PedalboardsCompanion changes,
  ) async {
    final changedRows = await (update(
      pedalboards,
    )..where((row) => row.id.equals(pedalboardId))).write(changes);
    return changedRows > 0;
  }

  Future<bool> deletePedalboard(int pedalboardId) async {
    final deletedRows = await (delete(
      pedalboards,
    )..where((row) => row.id.equals(pedalboardId))).go();
    return deletedRows > 0;
  }

  /// How many snapshots have been taken of this rig.
  ///
  /// `rig_snapshots` references a rig with RESTRICT, so this is what lets the
  /// repository refuse a delete in words rather than leaving SQLite to raise a
  /// constraint failure. Reading snapshots themselves is `RigSnapshotDao`'s job.
  Future<int> countSnapshots(int pedalboardId) async {
    final total = rigSnapshots.id.count();
    final query = selectOnly(rigSnapshots)
      ..addColumns([total])
      ..where(rigSnapshots.pedalboardId.equals(pedalboardId));

    final row = await query.getSingle();
    return row.read(total) ?? 0;
  }
}
