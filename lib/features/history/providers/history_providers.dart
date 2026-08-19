import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/change_log_dao.dart';
import '../../../core/database/database_provider.dart';
import '../data/change_log_repository.dart';

final Provider<ChangeLogDao> changeLogDaoProvider = Provider<ChangeLogDao>(
  (ref) => ChangeLogDao(ref.watch(appDatabaseProvider)),
);

final Provider<ChangeLogRepository> changeLogRepositoryProvider =
    Provider<ChangeLogRepository>(
      (ref) => ChangeLogRepository(ref.watch(changeLogDaoProvider)),
    );

/// The newest changes across the whole collection, for the history tab. Each
/// entry carries its pedal's name, since the list mixes pedals together.
final StreamProvider<List<PedalChange>> recentHistoryProvider =
    StreamProvider<List<PedalChange>>(
      (ref) => ref.watch(changeLogRepositoryProvider).watchRecentChanges(),
    );

/// One pedal's own history, newest first.
final StreamProviderFamily<List<ChangeLog>, int> pedalHistoryProvider =
    StreamProvider.family<List<ChangeLog>, int>(
      (ref, pedalId) =>
          ref.watch(changeLogRepositoryProvider).watchPedalChanges(pedalId),
    );
