import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pedal_dao.dart';
import '../../../core/database/database_provider.dart';
import '../data/pedal_repository.dart';

final Provider<PedalDao> pedalDaoProvider = Provider<PedalDao>(
  (ref) => PedalDao(ref.watch(appDatabaseProvider)),
);

final Provider<PedalRepository> pedalRepositoryProvider =
    Provider<PedalRepository>(
      (ref) => PedalRepository(ref.watch(pedalDaoProvider)),
    );

/// The whole inventory, ordered by name. Drift pushes a new list whenever the
/// `pedals` table changes, so screens never refresh by hand.
final StreamProvider<List<Pedal>> pedalListProvider =
    StreamProvider<List<Pedal>>(
      (ref) => ref.watch(pedalRepositoryProvider).watchPedals(),
    );

final StreamProviderFamily<Pedal?, int> pedalProvider =
    StreamProvider.family<Pedal?, int>(
      (ref, pedalId) => ref.watch(pedalRepositoryProvider).watchPedal(pedalId),
    );
