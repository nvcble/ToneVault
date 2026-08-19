import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pedal_dao.dart';
import '../../../core/database/daos/pedalboard_dao.dart';
import '../../../core/errors/app_failure.dart';

/// What is on a rig, and in what order signal reaches it.
///
/// Positions are kept as 0, 1, 2 with no gaps: a pedal added goes on the end, a
/// pedal taken off closes the gap behind it, and a reorder renumbers the lot.
/// Nothing outside this class decides a position.
///
/// Every write also moves the rig's `updatedAt` on, because changing the chain
/// is changing the rig. Like naming a rig, none of it is pedal history.
class RigChainRepository {
  RigChainRepository(this._dao, this._pedalDao, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final PedalboardDao _dao;
  final PedalDao _pedalDao;

  /// Injectable so tests can assert on exact timestamps.
  final DateTime Function() _clock;

  Stream<List<ChainSlot>> watchChain(int pedalboardId) =>
      _dao.watchChain(pedalboardId);

  /// Puts [pedalId] on the end of the rig's chain and returns the new slot's id.
  Future<int> addPedal({
    required int pedalboardId,
    required int pedalId,
  }) async {
    final pedalboard = await _dao.findPedalboard(pedalboardId);
    if (pedalboard == null) {
      throw const AppFailure('That rig no longer exists.');
    }

    final pedal = await _pedalDao.findPedal(pedalId);
    if (pedal == null) {
      throw const AppFailure('That pedal no longer exists.');
    }

    // The unique key would catch this too, as a driver exception with nothing
    // readable in it. Checked here, the refusal can name both.
    final slots = await _dao.slotsOf(pedalboardId);
    if (slots.any((slot) => slot.pedalId == pedalId)) {
      throw AppFailure('${pedal.name} is already on ${pedalboard.name}.');
    }

    return _guard(
      () => _dao.transaction(() async {
        final slotId = await _dao.insertSlot(
          PedalboardSlotsCompanion.insert(
            pedalboardId: pedalboardId,
            pedalId: pedalId,
            position: await _dao.nextPosition(pedalboardId),
          ),
        );
        await _touch(pedalboardId);
        return slotId;
      }),
      'Could not add this pedal to the rig.',
    );
  }

  /// Takes one pedal off the rig, closing the gap it leaves in the chain.
  ///
  /// The pedal itself is untouched: it is still owned, with its controls,
  /// configurations and history intact.
  Future<void> removePedal(int slotId) async {
    final slot = await _dao.findSlot(slotId);
    if (slot == null) {
      throw const AppFailure('That pedal is no longer on this rig.');
    }

    await _guard(
      () => _dao.transaction(() async {
        await _dao.deleteSlot(slotId);

        // Read back in signal order without the slot that just went, so what is
        // left renumbers into 0, 1, 2 rather than keeping a hole.
        final remaining = await _dao.slotsOf(slot.pedalboardId);
        await _dao.applyOrder([for (final kept in remaining) kept.id]);
        await _touch(slot.pedalboardId);
      }),
      'Could not take this pedal off the rig.',
    );
  }

  /// Rearranges the rig into the given signal order.
  ///
  /// [slotIdsInOrder] has to be exactly the rig's current slots: a list built
  /// before someone added or removed a pedal would silently renumber around the
  /// change.
  Future<void> reorderChain(int pedalboardId, List<int> slotIdsInOrder) async {
    final current = await _dao.slotsOf(pedalboardId);
    final expected = {for (final slot in current) slot.id};

    if (expected.length != slotIdsInOrder.length ||
        !expected.containsAll(slotIdsInOrder)) {
      throw const AppFailure(
        'This rig changed while you were reordering it. Reopen the rig and try '
        'again.',
      );
    }

    await _guard(
      () => _dao.transaction(() async {
        await _dao.applyOrder(slotIdsInOrder);
        await _touch(pedalboardId);
      }),
      'Could not save the new order.',
    );
  }

  Future<void> _touch(int pedalboardId) {
    return _dao.updatePedalboard(
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
