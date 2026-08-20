import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/daos/backup_dao.dart';
import '../../../core/database/database_provider.dart';
import '../data/backup_files.dart';
import '../data/backup_repository.dart';

final Provider<BackupDao> backupDaoProvider = Provider<BackupDao>(
  (ref) => BackupDao(ref.watch(appDatabaseProvider)),
);

final Provider<BackupRepository> backupRepositoryProvider =
    Provider<BackupRepository>(
      (ref) => BackupRepository(ref.watch(backupDaoProvider)),
    );

/// The share sheet and the file picker, behind providers so a test can hand a
/// backup to a variable and choose a file that only exists in the test.
///
/// Nothing else about backup needs a seam: the repository runs happily against
/// an in-memory database.
final Provider<BackupSender> backupSenderProvider = Provider<BackupSender>(
  (ref) => shareBackupFile,
);

final Provider<BackupChooser> backupChooserProvider = Provider<BackupChooser>(
  (ref) => chooseBackupFile,
);
