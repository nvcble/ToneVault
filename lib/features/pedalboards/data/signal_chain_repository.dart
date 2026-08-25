import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pedal_dao.dart';
import '../../../core/database/daos/pedalboard_dao.dart';
import '../../../core/database/daos/signal_chain_dao.dart';
import '../../../core/enums/signal_block_type.dart';
import '../../../core/errors/app_failure.dart';
import 'chain_order.dart';
import 'signal_block_draft.dart';
import 'signal_block_validator.dart';

/// What a rig's signal chain is made of, and in what order signal reaches it.
///
/// Positions are kept as 0, 1, 2 with no gaps: a block added goes on the end, a
/// block removed closes the gap behind it, and a reorder renumbers the lot.
/// Nothing outside this class decides a position.
///
/// A block holds a pedal or nothing at all, and the two are only ever loosely
/// tied: assigning a pedal writes one column, removing a block leaves the pedal
/// owned, and the same pedal can stand on as many rigs as the user has.
///
/// Every write also moves the rig's `updatedAt` on, because changing the chain
/// is changing the rig. Like naming a rig, none of it is pedal history.
class SignalChainRepository {
  SignalChainRepository(
    this._dao,
    this._pedalboardDao,
    this._pedalDao, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final SignalChainDao _dao;
  final PedalboardDao _pedalboardDao;
  final PedalDao _pedalDao;

  /// Injectable so tests can assert on exact timestamps.
  final DateTime Function() _clock;

  /// One rig's chain, in the order signal reaches it, worked out by
  /// [chainInSignalOrder].
  Stream<List<ChainBlock>> watchChain(int pedalboardId) =>
      _dao.watchChainRows(pedalboardId).map(chainInSignalOrder);

  /// One block as stored, for a screen that has just added one and needs the row
  /// rather than the id it got back.
  Future<SignalBlock?> findBlock(int blockId) => _dao.findBlock(blockId);

  /// How many blocks each rig holds, for the rig list to read at a glance.
  Stream<Map<int, int>> watchBlockCounts() => _dao.watchBlockCounts();

  /// Puts a block on the end of the rig's chain and returns its id.
  ///
  /// [pedalId] is optional on purpose: a rig is laid out before it is bought, so
  /// "a delay goes here" is a complete thing to say.
  ///
  /// [atStart] is for the one block that belongs nowhere else: what the rig is
  /// fed from. Everything else is added last and dragged into place, but signal
  /// arriving halfway down a chain would read as a mistake rather than as an
  /// arrangement waiting to be tidied.
  Future<int> addBlock({
    required int pedalboardId,
    required SignalBlockType blockType,
    int? pedalId,
    String? label,
    bool atStart = false,
  }) async {
    final pedalboard = await _pedalboardDao.findPedalboard(pedalboardId);
    if (pedalboard == null) {
      throw const AppFailure('That rig no longer exists.');
    }
    if (pedalId != null) {
      await _checkPedalFree(
        pedalboardId: pedalboardId,
        pedalId: pedalId,
        rigName: pedalboard.name,
      );
    }

    return _guard(
      () => _dao.transaction(() async {
        final blockId = await _dao.insertBlock(
          SignalBlocksCompanion.insert(
            pedalboardId: pedalboardId,
            pedalId: Value(pedalId),
            blockType: blockType,
            label: Value(label),
            position: await _dao.nextPosition(pedalboardId),
          ),
        );
        if (atStart) {
          final ids = [
            for (final block in await _dao.blocksOf(pedalboardId))
              if (block.id != blockId) block.id,
          ];
          await _dao.applyOrder([blockId, ...ids]);
        }
        await _touch(pedalboardId);
        return blockId;
      }),
      'Could not add this block to the rig.',
    );
  }

  /// Puts [pedalId] in an existing block, or empties it when null.
  ///
  /// Only the block changes. The pedal that was there stays owned, with its
  /// controls, configurations and history intact, and the one arriving is
  /// referenced rather than copied.
  Future<void> assignPedal({
    required int blockId,
    required int? pedalId,
  }) async {
    final block = await _requireBlock(blockId);
    if (pedalId != null && pedalId != block.pedalId) {
      final pedalboard = await _pedalboardDao.findPedalboard(
        block.pedalboardId,
      );
      await _checkPedalFree(
        pedalboardId: block.pedalboardId,
        pedalId: pedalId,
        rigName: pedalboard?.name ?? 'this rig',
      );
    }

    await _guard(
      () => _dao.transaction(() async {
        await _dao.updateBlock(
          blockId,
          SignalBlocksCompanion(pedalId: Value(pedalId)),
        );
        await _touch(block.pedalboardId);
      }),
      'Could not change the pedal in this block.',
    );
  }

  /// Changes what a block is, what it is called, and what is noted about it.
  ///
  /// Not what is in it and not where it sits: the pedal has a picker and the
  /// position is dragged, so neither is asked for twice. Changing the type of a
  /// block that already holds a pedal is allowed - a rig gets rethought around
  /// the gear on it, and the pedal is what the user put there either way.
  Future<void> editBlock({
    required int blockId,
    required SignalBlockDraft draft,
  }) async {
    final tidy = draft.normalized();
    final problem = SignalBlockValidator.draft(tidy);
    if (problem != null) {
      throw AppFailure(problem);
    }

    final block = await _requireBlock(blockId);

    await _guard(
      () => _dao.transaction(() async {
        await _dao.updateBlock(
          blockId,
          SignalBlocksCompanion(
            blockType: Value(tidy.blockType),
            label: Value(tidy.label),
            notes: Value(tidy.notes),
            isEnabled: Value(tidy.isEnabled),
          ),
        );
        await _touch(block.pedalboardId);
      }),
      'Could not save this block.',
    );
  }

  /// Bypasses a block, or brings it back in.
  ///
  /// The block keeps its place either way: bypassing is a sound the user is
  /// trying, not a decision to take the pedal off the board.
  Future<void> setEnabled({
    required int blockId,
    required bool isEnabled,
  }) async {
    final block = await _requireBlock(blockId);

    await _guard(
      () => _dao.transaction(() async {
        await _dao.updateBlock(
          blockId,
          SignalBlocksCompanion(isEnabled: Value(isEnabled)),
        );
        await _touch(block.pedalboardId);
      }),
      'Could not change whether this block is on.',
    );
  }

  /// Takes one block off the rig, closing the gap it leaves in the chain.
  ///
  /// The pedal that was in it is untouched: removing a block says the rig no
  /// longer routes through there, not that the pedal is gone.
  ///
  /// Returns the row that went, which is what [restoreBlock] needs to put it
  /// back. Any cables to it go with it, and those are not restored: an undo that
  /// guessed at routing would be rewiring the rig rather than undoing a delete.
  Future<SignalBlock> removeBlock(int blockId) async {
    final block = await _requireBlock(blockId);

    await _guard(
      () => _dao.transaction(() async {
        await _dao.deleteBlock(blockId);

        // Read back in signal order without the block that just went, so what is
        // left renumbers into 0, 1, 2 rather than keeping a hole.
        final remaining = await _dao.blocksOf(block.pedalboardId);
        await _dao.applyOrder([for (final kept in remaining) kept.id]);
        await _touch(block.pedalboardId);
      }),
      'Could not take this block off the rig.',
    );

    return block;
  }

  /// Puts a removed block back where it stood.
  ///
  /// A new row rather than the old id: the block was deleted, and an id that has
  /// been handed out again is worse than one that moved on. Everything the user
  /// chose comes back - the type, the label, the notes, the pedal, whether it was
  /// bypassed - and the chain renumbers around it.
  ///
  /// The pedal is refused if it has been put somewhere else on the rig in the
  /// meantime, which is the same refusal as assigning it there by hand.
  Future<void> restoreBlock(SignalBlock gone) async {
    final pedalboard = await _pedalboardDao.findPedalboard(gone.pedalboardId);
    if (pedalboard == null) {
      throw const AppFailure('That rig no longer exists.');
    }
    if (gone.pedalId != null) {
      await _checkPedalFree(
        pedalboardId: gone.pedalboardId,
        pedalId: gone.pedalId!,
        rigName: pedalboard.name,
      );
    }

    await _guard(
      () => _dao.transaction(() async {
        final blockId = await _dao.insertBlock(
          SignalBlocksCompanion.insert(
            pedalboardId: gone.pedalboardId,
            pedalId: Value(gone.pedalId),
            blockType: gone.blockType,
            label: Value(gone.label),
            position: gone.position,
            isEnabled: Value(gone.isEnabled),
            notes: Value(gone.notes),
          ),
        );

        // It shares a position with whatever closed the gap behind it, so the
        // order is settled here rather than left to the tie-break on id.
        final ids = [
          for (final block in await _dao.blocksOf(gone.pedalboardId))
            if (block.id != blockId) block.id,
        ];
        ids.insert(gone.position.clamp(0, ids.length), blockId);
        await _dao.applyOrder(ids);
        await _touch(gone.pedalboardId);
      }),
      'Could not put this block back.',
    );
  }

  /// Takes every block off the rig, leaving the rig itself.
  ///
  /// For starting a layout again rather than for tidying up: the pedals stay
  /// owned, and only the arrangement goes. There is no undo, which is why the
  /// screen asks first.
  Future<void> clearChain(int pedalboardId) async {
    if (await _pedalboardDao.findPedalboard(pedalboardId) == null) {
      throw const AppFailure('That rig no longer exists.');
    }

    await _guard(
      () => _dao.transaction(() async {
        await _dao.deleteBlocksOf(pedalboardId);
        await _touch(pedalboardId);
      }),
      'Could not clear this rig.',
    );
  }

  /// Rearranges the rig into the given signal order.
  ///
  /// [blockIdsInOrder] has to be exactly the rig's current blocks: a list built
  /// before someone added or removed one would silently renumber around the
  /// change.
  Future<void> reorderChain(int pedalboardId, List<int> blockIdsInOrder) async {
    final current = await _dao.blocksOf(pedalboardId);
    final expected = {for (final block in current) block.id};

    if (expected.length != blockIdsInOrder.length ||
        !expected.containsAll(blockIdsInOrder)) {
      throw const AppFailure(
        'This rig changed while you were reordering it. Reopen the rig and try '
        'again.',
      );
    }

    await _guard(
      () => _dao.transaction(() async {
        await _dao.applyOrder(blockIdsInOrder);
        await _touch(pedalboardId);
      }),
      'Could not save the new order.',
    );
  }

  Future<SignalBlock> _requireBlock(int blockId) async {
    final block = await _dao.findBlock(blockId);
    if (block == null) {
      throw const AppFailure('That block is no longer on this rig.');
    }
    return block;
  }

  /// Refuses a pedal that is already somewhere else on the same rig.
  ///
  /// The unique key would catch this too, as a driver exception with nothing
  /// readable in it. Checked here, the refusal can name both.
  Future<void> _checkPedalFree({
    required int pedalboardId,
    required int pedalId,
    required String rigName,
  }) async {
    final pedal = await _pedalDao.findPedal(pedalId);
    if (pedal == null) {
      throw const AppFailure('That pedal no longer exists.');
    }

    final blocks = await _dao.blocksOf(pedalboardId);
    if (blocks.any((block) => block.pedalId == pedalId)) {
      throw AppFailure('${pedal.name} is already on $rigName.');
    }
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
