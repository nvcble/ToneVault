import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/signal_blocks_table.dart';
import '../tables/signal_endpoints_table.dart';

part 'signal_endpoint_dao.g.dart';

/// Typed queries over what the edges of a rig reach.
///
/// A rig is asked for its endpoints as a whole, because there are only ever a
/// handful and every screen that cares wants them together. The rig is reached
/// through the block rather than stored again here: a copy of `pedalboard_id`
/// would be a second answer to a question the block already answers.
@DriftAccessor(tables: [SignalEndpoints, SignalBlocks])
class SignalEndpointDao extends DatabaseAccessor<AppDatabase>
    with _$SignalEndpointDaoMixin {
  SignalEndpointDao(super.attachedDatabase);

  /// One rig's endpoints, re-read whenever one of them or its block changes.
  Stream<List<SignalEndpoint>> watchEndpointsOf(int pedalboardId) =>
      _query(pedalboardId).watch().map(_read);

  Future<List<SignalEndpoint>> endpointsOf(int pedalboardId) async =>
      _read(await _query(pedalboardId).get());

  Future<SignalEndpoint?> findEndpointOf(int blockId) {
    return (select(
      signalEndpoints,
    )..where((row) => row.blockId.equals(blockId))).getSingleOrNull();
  }

  /// Writes what a block reaches, replacing whatever it said before.
  ///
  /// Upserted on the block rather than inserted, because describing an output for
  /// the second time is the user correcting themselves, not a second output.
  Future<void> saveEndpoint(SignalEndpointsCompanion endpoint) {
    return into(signalEndpoints).insert(
      endpoint,
      onConflict: DoUpdate((_) => endpoint, target: [signalEndpoints.blockId]),
    );
  }

  /// Returns whether a row was there to remove.
  Future<bool> deleteEndpointOf(int blockId) async {
    final deletedRows = await (delete(
      signalEndpoints,
    )..where((row) => row.blockId.equals(blockId))).go();
    return deletedRows > 0;
  }

  /// Breaks any pairing that names [blockId], from either side.
  Future<void> clearPairingsWith(int blockId) async {
    await (update(signalEndpoints)..where(
          (row) =>
              row.blockId.equals(blockId) | row.pairedBlockId.equals(blockId),
        ))
        .write(const SignalEndpointsCompanion(pairedBlockId: Value(null)));
  }

  JoinedSelectStatement<HasResultSet, dynamic> _query(int pedalboardId) {
    return select(signalEndpoints).join([
      innerJoin(
        signalBlocks,
        signalBlocks.id.equalsExp(signalEndpoints.blockId),
      ),
    ])..where(signalBlocks.pedalboardId.equals(pedalboardId));
  }

  List<SignalEndpoint> _read(List<TypedResult> rows) => [
    for (final row in rows) row.readTable(signalEndpoints),
  ];
}
