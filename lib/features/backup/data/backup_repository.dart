import '../../../core/database/daos/backup_dao.dart';
import '../../../core/errors/app_failure.dart';
import 'backup_document.dart';

/// A backup file waiting to be saved somewhere.
typedef VaultExport = ({String fileName, String contents});

/// Backing the vault up to a file, and putting a file back into the vault.
///
/// Reading a file and restoring it are two steps on purpose. A restore replaces
/// everything the user has, so the app has to be able to say what is in a file -
/// when it was made, how much is in it - and get an answer before anything is
/// written. Rolled into one call, the only honest confirmation left would be
/// asked before the file had even been read.
///
/// Nothing here is history. A restore is not something that happened to a pedal;
/// it is the vault becoming a copy of itself from another day, and the history it
/// carries is the history that was backed up.
class BackupRepository {
  BackupRepository(this._dao, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final BackupDao _dao;

  /// Injectable so tests can assert on exact timestamps.
  final DateTime Function() _clock;

  /// The whole vault as a backup file, named and ready to be saved.
  ///
  /// The name comes back with the contents because both are stamped with the
  /// same moment: a file called one day that says inside it was taken on another
  /// would be a file nobody could trust.
  Future<VaultExport> exportVault() async {
    final rows = await _guard(
      _dao.readEverything,
      'Could not read your gear to back it up.',
    );

    final exportedAt = _clock();
    return (
      fileName: backupFileName(exportedAt),
      contents: encodeVaultBackup(rows, exportedAt: exportedAt),
    );
  }

  /// What a file holds, without touching the vault.
  ///
  /// Refuses a file that is not a backup, or is one this version cannot read,
  /// before the user is asked to agree to anything.
  VaultBackup readBackup(String file) => decodeVaultBackup(file);

  /// Replaces everything in the vault with what [backup] holds.
  ///
  /// One transaction, so the vault is either the backup or exactly what it was
  /// beforehand. There is no half-restored vault and no merge: a backup is a
  /// record of the whole collection on a day, and merging one in would leave the
  /// user with rows from two days and no way to tell which is which.
  Future<void> restoreVault(VaultBackup backup) {
    return _guard(
      () => _dao.writeEverything(backup.rows),
      'Could not restore that backup, so your gear is as it was.',
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
