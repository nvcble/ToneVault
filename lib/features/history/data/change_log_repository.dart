import '../../../core/database/daos/change_log_dao.dart';
import '../../../core/errors/app_failure.dart';
import 'change_entry.dart';

/// How many entries a history screen reads at once.
///
/// A rig accumulates history for years and a screen shows the top of it, so the
/// query is bounded rather than pulling every row into memory.
const int historyPageSize = 100;

/// The append-only history of everything that happened to a pedal.
///
/// Writes are one-way on purpose: there is `record`, and there is no edit and no
/// individual delete. A history that can be corrected after the fact cannot be
/// trusted to say what the pedal was actually set to last month.
class ChangeLogRepository {
  ChangeLogRepository(this._dao, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final ChangeLogDao _dao;

  /// Injectable so tests can assert on exact timestamps.
  final DateTime Function() _clock;

  Stream<List<PedalChange>> watchRecentChanges({int limit = historyPageSize}) =>
      _dao.watchRecentChanges(limit: limit);

  Stream<List<PedalChange>> watchPedalChanges(
    int pedalId, {
    int limit = historyPageSize,
  }) => _dao.watchPedalChanges(pedalId, limit: limit);

  /// Appends one entry, stamped now.
  Future<void> record(ChangeEntry entry) async {
    await _guard(
      () => _dao.insertEntry(entry.toCompanion(_clock())),
      'Could not record this change.',
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
