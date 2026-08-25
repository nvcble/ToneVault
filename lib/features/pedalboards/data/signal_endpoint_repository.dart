import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pedalboard_dao.dart';
import '../../../core/database/daos/signal_chain_dao.dart';
import '../../../core/database/daos/signal_endpoint_dao.dart';
import '../../../core/errors/app_failure.dart';
import 'chain_endpoints.dart';
import 'signal_endpoint_draft.dart';
import 'signal_endpoint_validator.dart';

/// What the edges of a rig reach, and which send comes back through which return.
///
/// Kept apart from the chain and the cables because it answers a third question.
/// Those two own what is on the board and how it is wired; this one owns where the
/// wiring leaves off - the amp it goes into, the desk it feeds, the loop it takes a
/// trip through on the way.
///
/// Nothing here is guessed. A rig that has said nothing has no rows, and a screen
/// reads that as not-said rather than as a guitar and an amplifier.
class SignalEndpointRepository {
  SignalEndpointRepository(
    this._dao,
    this._chainDao,
    this._pedalboardDao, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final SignalEndpointDao _dao;
  final SignalChainDao _chainDao;
  final PedalboardDao _pedalboardDao;
  final DateTime Function() _clock;

  /// One rig's edges, re-read whenever one of them changes.
  Stream<ChainEndpoints> watchEndpoints(int pedalboardId) =>
      _dao.watchEndpointsOf(pedalboardId).map(ChainEndpoints.new);

  /// Records where signal goes from this block, or where it arrives from.
  ///
  /// Which of the two is asked for comes off the block's own type, so a reverb
  /// cannot claim to be an output and a send cannot claim to be fed from a guitar.
  /// Saving over an earlier answer replaces it: the user is correcting themselves,
  /// not adding a second destination.
  Future<void> describe({
    required int blockId,
    required SignalEndpointDraft draft,
  }) async {
    final block = await _requireBlock(blockId);
    final tidy = draft.normalized();

    final problem = SignalEndpointValidator.draft(tidy, block.blockType);
    if (problem != null) throw AppFailure(problem);

    // Whatever it was paired with stays paired: where a send goes and what brings
    // it back are two separate answers.
    final paired = await _pairOf(blockId);

    await _write(
      block.pedalboardId,
      'Could not save where this block goes.',
      () => _dao.saveEndpoint(
        SignalEndpointsCompanion.insert(
          blockId: blockId,
          destination: Value(tidy.destination),
          source: Value(tidy.source),
          pairedBlockId: Value(paired),
          gear: Value(tidy.gear),
          notes: Value(tidy.notes),
        ),
      ),
    );
  }

  /// Says that what leaves at [sendBlockId] comes back in at [returnBlockId].
  ///
  /// This is the pedalboard's own trip out and back - most often through the
  /// amplifier's effects loop, which is why the send goes to the amp's input and
  /// the return is fed by the amp's send, not the other way round. No cable is
  /// stored between the two: the signal is out of the rig in between, and a cable
  /// would claim the app knows what happens to it out there.
  ///
  /// Written on both halves in one transaction, so either can be read on its own.
  Future<void> pair({
    required int sendBlockId,
    required int returnBlockId,
  }) async {
    final send = await _requireBlock(sendBlockId);
    final back = await _requireBlock(returnBlockId);

    if (send.pedalboardId != back.pedalboardId) {
      throw const AppFailure('Those two blocks are on different rigs.');
    }
    if (!send.blockType.carriesDestination) {
      throw const AppFailure('Only a send or an output goes out of the rig.');
    }
    if (!back.blockType.carriesSource) {
      throw const AppFailure(
        'Only a return or an input brings signal back in.',
      );
    }

    await _write(send.pedalboardId, 'Could not pair those two blocks.', () async {
      // Either block may already be half of another pair, and a block cannot be
      // in two loops at once.
      await _dao.clearPairingsWith(sendBlockId);
      await _dao.clearPairingsWith(returnBlockId);
      await _savePairing(sendBlockId, returnBlockId);
      await _savePairing(returnBlockId, sendBlockId);
    });
  }

  /// Separates a send and its return. Both blocks stay on the rig, and what each
  /// one reaches is left as the user said it.
  Future<void> unpair(int blockId) async {
    final block = await _requireBlock(blockId);

    await _write(
      block.pedalboardId,
      'Could not separate those two blocks.',
      () => _dao.clearPairingsWith(blockId),
    );
  }

  /// Forgets what a block reaches, leaving the block itself on the rig.
  Future<void> clearEndpoint(int blockId) async {
    final block = await _requireBlock(blockId);

    await _write(
      block.pedalboardId,
      'Could not clear what this block goes to.',
      () => _dao.deleteEndpointOf(blockId),
    );
  }

  /// Adds or updates one half of a pairing without disturbing what that block
  /// already said it reaches.
  Future<void> _savePairing(int blockId, int pairedBlockId) async {
    final existing = await _dao.findEndpointOf(blockId);
    await _dao.saveEndpoint(
      SignalEndpointsCompanion.insert(
        blockId: blockId,
        destination: Value(existing?.destination),
        source: Value(existing?.source),
        pairedBlockId: Value(pairedBlockId),
        gear: Value(existing?.gear),
        notes: Value(existing?.notes),
      ),
    );
  }

  Future<int?> _pairOf(int blockId) async =>
      (await _dao.findEndpointOf(blockId))?.pairedBlockId;

  Future<SignalBlock> _requireBlock(int blockId) async {
    final block = await _chainDao.findBlock(blockId);
    if (block == null) {
      throw const AppFailure('That block is no longer on this rig.');
    }
    return block;
  }

  /// Every write moves the rig's `updatedAt` on, because saying where a rig ends
  /// is changing the rig. None of it is pedal history.
  Future<void> _write(
    int pedalboardId,
    String message,
    Future<void> Function() operation,
  ) async {
    try {
      await _dao.transaction(() async {
        await operation();
        await _pedalboardDao.updatePedalboard(
          pedalboardId,
          PedalboardsCompanion(updatedAt: Value(_clock())),
        );
      });
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw AppFailure(message, cause: error);
    }
  }
}
