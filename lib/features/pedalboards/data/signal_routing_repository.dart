import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pedalboard_dao.dart';
import '../../../core/database/daos/signal_chain_dao.dart';
import '../../../core/enums/signal_connection_type.dart';
import '../../../core/errors/app_failure.dart';
import 'chain_routing.dart';
import 'routing_rules.dart';
import 'signal_graph.dart';

/// The cables of a rig: which block feeds which.
///
/// Kept apart from `SignalChainRepository` because it answers a different
/// question. That one owns what is on the board and in what order; this one owns
/// how it is wired, which is what a rig needs once one path is not enough.
///
/// A rig with nothing here runs straight through in position order, so a plain
/// chain never writes a row and nothing has to be undone to go back to one.
class SignalRoutingRepository {
  SignalRoutingRepository(
    this._dao,
    this._pedalboardDao, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final SignalChainDao _dao;
  final PedalboardDao _pedalboardDao;
  final DateTime Function() _clock;

  /// One rig's cabling, re-read whenever a block or a cable changes.
  Stream<ChainRouting> watchRouting(int pedalboardId) {
    return _dao
        .watchChainRows(pedalboardId)
        .map((rows) => ChainRouting(rows.cables));
  }

  /// Runs a cable from one block to another and returns its id.
  ///
  /// Both blocks have to be on the same rig, and the result has to stay a chain
  /// signal can pass through once: `RoutingRules` is what refuses a block feeding
  /// itself, a cable that is already there, a loop, and a cable at the wrong end
  /// of an input, an output, a send or a return.
  ///
  /// [type] is worked out from the rig unless it is given: the first cable out of
  /// a block is the next thing in line, and a second one is a split, whether or
  /// not the user called that block a split.
  Future<int> connect({
    required int sourceBlockId,
    required int targetBlockId,
    SignalConnectionType? type,
  }) async {
    final source = await _requireBlock(sourceBlockId);
    final target = await _requireBlock(targetBlockId);
    if (source.pedalboardId != target.pedalboardId) {
      throw const AppFailure('Those two blocks are on different rigs.');
    }

    final pedalboardId = source.pedalboardId;
    final routing = ChainRouting(await _dao.connectionsOf(pedalboardId));
    final graph = SignalGraph(
      blockIdsByPosition: [
        for (final block in await _dao.blocksOf(pedalboardId)) block.id,
      ],
      connections: routing.cables,
    );

    final refusal = RoutingRules.refusalFor(
      source: source,
      target: target,
      graph: graph,
    );
    if (refusal != null) throw AppFailure(refusal);

    final wiring =
        type ??
        (routing.pathsFrom(sourceBlockId) == 0
            ? SignalConnectionType.series
            : SignalConnectionType.parallel);

    return _guard(
      () => _dao.transaction(() async {
        final id = await _dao.insertConnection(
          SignalConnectionsCompanion.insert(
            pedalboardId: pedalboardId,
            sourceBlockId: sourceBlockId,
            targetBlockId: targetBlockId,
            connectionType: wiring,
          ),
        );
        await _touch(pedalboardId);
        return id;
      }),
      'Could not connect those two blocks.',
    );
  }

  /// Pulls one cable out. The blocks at either end stay where they are.
  Future<void> disconnect(int connectionId) async {
    final cable = await _dao.findConnection(connectionId);
    if (cable == null) {
      throw const AppFailure('That connection is no longer on this rig.');
    }

    await _guard(
      () => _dao.transaction(() async {
        await _dao.deleteConnection(connectionId);
        await _touch(cable.pedalboardId);
      }),
      'Could not disconnect those two blocks.',
    );
  }

  Future<SignalBlock> _requireBlock(int blockId) async {
    final block = await _dao.findBlock(blockId);
    if (block == null) {
      throw const AppFailure('That block is no longer on this rig.');
    }
    return block;
  }

  Future<void> _touch(int pedalboardId) {
    return _pedalboardDao.updatePedalboard(
      pedalboardId,
      PedalboardsCompanion(updatedAt: Value(_clock())),
    );
  }

  Future<T> _guard<T>(Future<T> Function() operation, String message) async {
    try {
      return await operation();
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw AppFailure(message, cause: error);
    }
  }
}
