import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/pedals_table.dart';

part 'pedal_dao.g.dart';

/// Typed queries over the `pedals` table.
///
/// Timestamps, validation and error translation belong to `PedalRepository`;
/// this class only reads and writes rows.
@DriftAccessor(tables: [Pedals])
class PedalDao extends DatabaseAccessor<AppDatabase> with _$PedalDaoMixin {
  PedalDao(super.attachedDatabase);

  /// The pedals a player owns as separate pieces of gear, ordered by name.
  ///
  /// A stomp or block inside a multi-effects unit is deliberately not one of
  /// them: it is reached through its unit, and counting it here would put it in
  /// the inventory list, the dashboard tallies, the rig chain picker and the
  /// replacement list, none of which it belongs in. This is the only query the
  /// whole app lists pedals through, so excluding them once excludes them
  /// everywhere.
  ///
  /// SQLite's default collation is case-sensitive, which would sort "joyo"
  /// after "Zoom", so the ordering is explicitly case-insensitive.
  Stream<List<Pedal>> watchPedals() {
    return (select(pedals)
          ..where((row) => row.hostPedalId.isNull())
          ..orderBy([
            (row) => OrderingTerm.asc(row.name.collate(Collate.noCase)),
          ]))
        .watch();
  }

  /// The pedals inside [hostPedalId], in the order they are named.
  Stream<List<Pedal>> watchComponentPedals(int hostPedalId) {
    return (select(pedals)
          ..where((row) => row.hostPedalId.equals(hostPedalId))
          ..orderBy([
            (row) => OrderingTerm.asc(row.name.collate(Collate.noCase)),
          ]))
        .watch();
  }

  Stream<Pedal?> watchPedal(int pedalId) {
    return (select(
      pedals,
    )..where((row) => row.id.equals(pedalId))).watchSingleOrNull();
  }

  Future<Pedal?> findPedal(int pedalId) {
    return (select(
      pedals,
    )..where((row) => row.id.equals(pedalId))).getSingleOrNull();
  }

  Future<int> insertPedal(PedalsCompanion pedal) => into(pedals).insert(pedal);

  /// Returns whether a row matched [pedalId].
  Future<bool> updatePedal(int pedalId, PedalsCompanion changes) async {
    final changedRows = await (update(
      pedals,
    )..where((row) => row.id.equals(pedalId))).write(changes);
    return changedRows > 0;
  }

  Future<bool> deletePedal(int pedalId) async {
    final deletedRows = await (delete(
      pedals,
    )..where((row) => row.id.equals(pedalId))).go();
    return deletedRows > 0;
  }
}
