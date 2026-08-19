import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pedalboard_dao.dart';
import '../../../core/database/database_provider.dart';
import '../data/pedalboard_repository.dart';

final Provider<PedalboardDao> pedalboardDaoProvider = Provider<PedalboardDao>(
  (ref) => PedalboardDao(ref.watch(appDatabaseProvider)),
);

final Provider<PedalboardRepository> pedalboardRepositoryProvider =
    Provider<PedalboardRepository>(
      (ref) => PedalboardRepository(ref.watch(pedalboardDaoProvider)),
    );

/// Every rig by name. Drift pushes a new list whenever the table changes, so the
/// Rigs screen never refreshes by hand.
final StreamProvider<List<Pedalboard>> pedalboardListProvider =
    StreamProvider<List<Pedalboard>>(
      (ref) => ref.watch(pedalboardRepositoryProvider).watchPedalboards(),
    );

/// One rig. Watched rather than read once so a rig deleted behind an open screen
/// is noticed.
final StreamProviderFamily<Pedalboard?, int> pedalboardProvider =
    StreamProvider.family<Pedalboard?, int>(
      (ref, pedalboardId) =>
          ref.watch(pedalboardRepositoryProvider).watchPedalboard(pedalboardId),
    );
