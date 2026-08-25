import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/pedals_table.dart';
import '../tables/signal_blocks_table.dart';
import '../tables/signal_connections_table.dart';

part 'signal_chain_dao.g.dart';

/// One block of a chain and the pedal in it, if the user has put one there yet.
typedef ChainBlock = ({SignalBlock block, Pedal? pedal});

/// Everything a rig's chain is made of: its blocks, the cables between them, and
/// where the wiring leaves off at either edge.
typedef ChainRows = ({
  List<ChainBlock> blocks,
  List<SignalConnection> cables,
  List<SignalEndpoint> endpoints,
});

/// Typed queries over the blocks and connections that make up a rig's chain.
///
/// Timestamps, renumbering and error translation belong to
/// `SignalChainRepository` and `SignalRoutingRepository`; this class only reads
/// and writes rows.
@DriftAccessor(tables: [SignalBlocks, SignalConnections, Pedals])
class SignalChainDao extends DatabaseAccessor<AppDatabase>
    with _$SignalChainDaoMixin {
  SignalChainDao(super.attachedDatabase);

  /// One rig's chain rows together, re-read whenever any of them changes.
  ///
  /// Several tables cannot be watched as one query, so a trivial select declares
  /// what the result depends on and all of them are read whenever drift says
  /// something under it moved. Turning them into a chain is `SignalGraph`'s job.
  ///
  /// The endpoints are here because a paired send and return have to be read one
  /// after the other, and a second stream would let the chain be drawn from a
  /// pairing that had already changed.
  Stream<ChainRows> watchChainRows(int pedalboardId) {
    return customSelect(
      'SELECT 1',
      readsFrom: {
        signalBlocks,
        signalConnections,
        pedals,
        attachedDatabase.signalEndpoints,
      },
    ).watch().asyncMap((_) => chainRows(pedalboardId));
  }

  /// One rig's chain rows as they stand, for a caller reading the chain once
  /// rather than following it - taking a snapshot of the rig, most of all.
  Future<ChainRows> chainRows(int pedalboardId) async {
    return (
      blocks: await _chainOf(pedalboardId),
      cables: await connectionsOf(pedalboardId),
      endpoints: await attachedDatabase.signalEndpointDao.endpointsOf(
        pedalboardId,
      ),
    );
  }

  /// One rig's chain in position order, with whatever pedal each block holds.
  ///
  /// The join is an outer one because a block is allowed to be empty, and the
  /// block id is the tie-breaker so a chain whose blocks somehow share a
  /// position never lists them differently between two reads.
  Future<List<ChainBlock>> _chainOf(int pedalboardId) async {
    final query =
        select(signalBlocks).join([
            leftOuterJoin(pedals, pedals.id.equalsExp(signalBlocks.pedalId)),
          ])
          ..where(signalBlocks.pedalboardId.equals(pedalboardId))
          ..orderBy([
            OrderingTerm.asc(signalBlocks.position),
            OrderingTerm.asc(signalBlocks.id),
          ]);

    final rows = await query.get();
    return [
      for (final row in rows)
        (
          block: row.readTable(signalBlocks),
          pedal: row.readTableOrNull(pedals),
        ),
    ];
  }

  /// One rig's blocks in signal order, without the pedals they hold.
  Future<List<SignalBlock>> blocksOf(int pedalboardId) {
    return (select(signalBlocks)
          ..where((row) => row.pedalboardId.equals(pedalboardId))
          ..orderBy([
            (row) => OrderingTerm.asc(row.position),
            (row) => OrderingTerm.asc(row.id),
          ]))
        .get();
  }

  Future<SignalBlock?> findBlock(int blockId) {
    return (select(
      signalBlocks,
    )..where((row) => row.id.equals(blockId))).getSingleOrNull();
  }

  Future<int> insertBlock(SignalBlocksCompanion block) =>
      into(signalBlocks).insert(block);

  /// Returns whether a row matched [blockId].
  Future<bool> updateBlock(int blockId, SignalBlocksCompanion changes) async {
    final changedRows = await (update(
      signalBlocks,
    )..where((row) => row.id.equals(blockId))).write(changes);
    return changedRows > 0;
  }

  Future<bool> deleteBlock(int blockId) async {
    final deletedRows = await (delete(
      signalBlocks,
    )..where((row) => row.id.equals(blockId))).go();
    return deletedRows > 0;
  }

  /// Empties one rig's chain, returning how many blocks went.
  Future<int> deleteBlocksOf(int pedalboardId) {
    return (delete(
      signalBlocks,
    )..where((row) => row.pedalboardId.equals(pedalboardId))).go();
  }

  /// The position a newly added block takes, which is the end of the chain.
  Future<int> nextPosition(int pedalboardId) async {
    final highest = signalBlocks.position.max();
    final query = selectOnly(signalBlocks)
      ..addColumns([highest])
      ..where(signalBlocks.pedalboardId.equals(pedalboardId));

    final row = await query.getSingle();
    return (row.read(highest) ?? -1) + 1;
  }

  /// Renumbers [blockIdsInOrder] to 0, 1, 2 and so on.
  ///
  /// A batch is one statement round-trip and one transaction, so the chain is
  /// never observed half-renumbered by the watching query.
  Future<void> applyOrder(List<int> blockIdsInOrder) async {
    await batch((batch) {
      for (final (index, blockId) in blockIdsInOrder.indexed) {
        batch.update(
          signalBlocks,
          SignalBlocksCompanion(position: Value(index)),
          where: (row) => row.id.equals(blockId),
        );
      }
    });
  }

  /// How many blocks each rig has, by rig id.
  ///
  /// One grouped query rather than one per rig, so the rig list does not open a
  /// stream for every card it shows. Rigs with an empty chain are absent, which
  /// the caller reads as none.
  Stream<Map<int, int>> watchBlockCounts() {
    final total = signalBlocks.id.count();
    final query = selectOnly(signalBlocks)
      ..addColumns([signalBlocks.pedalboardId, total])
      ..groupBy([signalBlocks.pedalboardId]);

    return query.watch().map(
      (rows) => {
        for (final row in rows)
          row.read(signalBlocks.pedalboardId)!: row.read(total) ?? 0,
      },
    );
  }

  Future<List<SignalConnection>> connectionsOf(int pedalboardId) {
    return (select(
      signalConnections,
    )..where((row) => row.pedalboardId.equals(pedalboardId))).get();
  }

  Future<SignalConnection?> findConnection(int connectionId) {
    return (select(
      signalConnections,
    )..where((row) => row.id.equals(connectionId))).getSingleOrNull();
  }

  Future<int> insertConnection(SignalConnectionsCompanion connection) =>
      into(signalConnections).insert(connection);

  Future<bool> deleteConnection(int connectionId) async {
    final deletedRows = await (delete(
      signalConnections,
    )..where((row) => row.id.equals(connectionId))).go();
    return deletedRows > 0;
  }
}
