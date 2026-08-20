import 'package:tone_vault/features/history/data/change_entry.dart';
import 'package:tone_vault/features/history/data/change_log_repository.dart';

/// A change log that refuses to write, to prove the change is rolled back with
/// it rather than left behind with no record of itself.
///
/// Every repository that records history wraps the write and the entry in one
/// transaction, so every one of them can be held to that with this.
class BrokenChangeLog extends ChangeLogRepository {
  BrokenChangeLog(super.dao);

  @override
  Future<void> record(ChangeEntry entry) async => throw Exception('disk gone');
}
