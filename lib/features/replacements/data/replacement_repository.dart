import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pedal_dao.dart';
import '../../../core/database/daos/pedal_replacement_dao.dart';
import '../../../core/enums/pedal_status.dart';
import '../../../core/errors/app_failure.dart';
import '../../history/data/change_entry.dart';
import '../../history/data/change_log_repository.dart';

/// Replacing one pedal in the rig with another.
///
/// Nothing here deletes anything. The outgoing pedal is only marked
/// [PedalStatus.replaced], so it keeps its controls, its configurations and its
/// history, and the swap itself becomes a row of its own that names both sides.
class ReplacementRepository {
  ReplacementRepository(
    this._dao,
    this._pedalDao,
    this._changeLog, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final PedalReplacementDao _dao;
  final PedalDao _pedalDao;
  final ChangeLogRepository _changeLog;

  /// Injectable so tests can assert on exact timestamps.
  final DateTime Function() _clock;

  Stream<List<PedalSwap>> watchSwaps(int pedalId) => _dao.watchSwaps(pedalId);

  /// Retires [outgoingPedalId] in favour of [incomingPedalId] and returns the id
  /// of the recorded swap.
  ///
  /// [replacedAt] defaults to now, and is there for a swap being entered after
  /// the fact. Both pedals must already be in the inventory: the replacement is
  /// a pedal the user owns, not a name typed into this form.
  Future<int> replacePedal({
    required int outgoingPedalId,
    required int incomingPedalId,
    String? reason,
    String? notes,
    DateTime? replacedAt,
  }) async {
    final now = _clock();
    final when = replacedAt ?? now;
    if (when.isAfter(now)) {
      throw const AppFailure('A replacement cannot be dated in the future.');
    }

    final pair = await _pairFor(outgoingPedalId, incomingPedalId);
    final explanation = _trimmed(reason);

    return _guard(
      () => _dao.transaction(() async {
        final swapId = await _dao.insertSwap(
          PedalReplacementsCompanion.insert(
            oldPedalId: pair.outgoing.id,
            newPedalId: pair.incoming.id,
            reason: Value(explanation),
            replacedAt: when,
            notes: Value(_trimmed(notes)),
          ),
        );

        await _pedalDao.updatePedal(
          pair.outgoing.id,
          PedalsCompanion(
            status: const Value(PedalStatus.replaced),
            updatedAt: Value(now),
          ),
        );

        // One entry rather than two: the status only moved because of the swap,
        // and this headline already says which pedal took over.
        await _changeLog.record(
          ChangeEntry.pedalReplaced(
            outgoing: pair.outgoing,
            incoming: pair.incoming,
            reason: explanation,
          ),
        );

        return swapId;
      }),
      'Could not record this replacement.',
    );
  }

  /// Both pedals as they stand, or the reason this swap cannot be recorded.
  Future<({Pedal outgoing, Pedal incoming})> _pairFor(
    int outgoingPedalId,
    int incomingPedalId,
  ) async {
    if (outgoingPedalId == incomingPedalId) {
      throw const AppFailure('A pedal cannot replace itself.');
    }

    final outgoing = await _pedalDao.findPedal(outgoingPedalId);
    if (outgoing == null) {
      throw const AppFailure('That pedal no longer exists.');
    }

    final incoming = await _pedalDao.findPedal(incomingPedalId);
    if (incoming == null) {
      throw const AppFailure('That replacement pedal no longer exists.');
    }

    // A pedal leaves the rig once. A second swap against the same outgoing
    // pedal would leave two answers to "what took over from this".
    final existing = await _dao.findReplacementOf(outgoingPedalId);
    if (existing != null) {
      final replacement = await _pedalDao.findPedal(existing.newPedalId);
      throw AppFailure(
        '${outgoing.name} was already replaced by '
        '${replacement?.name ?? 'another pedal'}.',
      );
    }

    return (outgoing: outgoing, incoming: incoming);
  }

  /// Blank text is an explanation the user chose not to give, not an empty one.
  String? _trimmed(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
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
