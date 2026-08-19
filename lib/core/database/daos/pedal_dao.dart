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

  /// All pedals, ordered by name.
  ///
  /// SQLite's default collation is case-sensitive, which would sort "joyo"
  /// after "Zoom", so the ordering is explicitly case-insensitive.
  Stream<List<Pedal>> watchPedals() {
    return (select(pedals)..orderBy([
      (row) => OrderingTerm.asc(row.name.collate(Collate.noCase)),
    ])).watch();
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
    final changedRows = await (update(pedals)
      ..where((row) => row.id.equals(pedalId))).write(changes);
    return changedRows > 0;
  }

  Future<bool> deletePedal(int pedalId) async {
    final deletedRows = await (delete(pedals)
      ..where((row) => row.id.equals(pedalId))).go();
    return deletedRows > 0;
  }
}
