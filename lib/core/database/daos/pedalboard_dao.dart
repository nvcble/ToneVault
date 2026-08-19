import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/pedalboard_slots_table.dart';
import '../tables/pedalboards_table.dart';
import '../tables/pedals_table.dart';
import '../tables/rig_snapshots_table.dart';

part 'pedalboard_dao.g.dart';

/// One pedal and where it sits in a rig's chain.
typedef ChainSlot = ({PedalboardSlot slot, Pedal pedal});

/// Typed queries over `pedalboards` and the slots that make up their chains.
///
/// Timestamps, validation and error translation belong to
/// `PedalboardRepository` and `RigChainRepository`; this class only reads and
/// writes rows.
@DriftAccessor(tables: [Pedalboards, PedalboardSlots, Pedals, RigSnapshots])
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

  /// One rig's chain, in signal order, with the pedal each slot holds.
  ///
  /// The slot id is the tie-breaker so a chain whose slots somehow share a
  /// position never lists them differently between two reads.
  Stream<List<ChainSlot>> watchChain(int pedalboardId) {
    final query =
        select(pedalboardSlots).join([
            innerJoin(pedals, pedals.id.equalsExp(pedalboardSlots.pedalId)),
          ])
          ..where(pedalboardSlots.pedalboardId.equals(pedalboardId))
          ..orderBy([
            OrderingTerm.asc(pedalboardSlots.position),
            OrderingTerm.asc(pedalboardSlots.id),
          ]);

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => (
              slot: row.readTable(pedalboardSlots),
              pedal: row.readTable(pedals),
            ),
          )
          .toList(),
    );
  }

  /// One rig's slots in signal order, without the pedals they hold.
  Future<List<PedalboardSlot>> slotsOf(int pedalboardId) {
    return (select(pedalboardSlots)
          ..where((row) => row.pedalboardId.equals(pedalboardId))
          ..orderBy([
            (row) => OrderingTerm.asc(row.position),
            (row) => OrderingTerm.asc(row.id),
          ]))
        .get();
  }

  Future<PedalboardSlot?> findSlot(int slotId) {
    return (select(
      pedalboardSlots,
    )..where((row) => row.id.equals(slotId))).getSingleOrNull();
  }

  Future<int> insertSlot(PedalboardSlotsCompanion slot) =>
      into(pedalboardSlots).insert(slot);

  Future<bool> deleteSlot(int slotId) async {
    final deletedRows = await (delete(
      pedalboardSlots,
    )..where((row) => row.id.equals(slotId))).go();
    return deletedRows > 0;
  }

  /// The position a newly added pedal takes, which is the end of the chain.
  Future<int> nextPosition(int pedalboardId) async {
    final highest = pedalboardSlots.position.max();
    final query = selectOnly(pedalboardSlots)
      ..addColumns([highest])
      ..where(pedalboardSlots.pedalboardId.equals(pedalboardId));

    final row = await query.getSingle();
    return (row.read(highest) ?? -1) + 1;
  }

  /// Renumbers [slotIdsInOrder] to 0, 1, 2 and so on.
  ///
  /// A batch is one statement round-trip and one transaction, so the chain is
  /// never observed half-renumbered by the watching query.
  Future<void> applyOrder(List<int> slotIdsInOrder) async {
    await batch((batch) {
      for (final (index, slotId) in slotIdsInOrder.indexed) {
        batch.update(
          pedalboardSlots,
          PedalboardSlotsCompanion(position: Value(index)),
          where: (row) => row.id.equals(slotId),
        );
      }
    });
  }
}
