import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/daos/pedal_replacement_dao.dart';
import '../../../core/database/database_provider.dart';
import '../../history/providers/history_providers.dart';
import '../../pedals/providers/pedal_providers.dart';
import '../data/replacement_repository.dart';

final Provider<PedalReplacementDao> pedalReplacementDaoProvider =
    Provider<PedalReplacementDao>(
      (ref) => PedalReplacementDao(ref.watch(appDatabaseProvider)),
    );

final Provider<ReplacementRepository> replacementRepositoryProvider =
    Provider<ReplacementRepository>(
      (ref) => ReplacementRepository(
        ref.watch(pedalReplacementDaoProvider),
        ref.watch(pedalDaoProvider),
        ref.watch(changeLogRepositoryProvider),
      ),
    );

/// Every swap one pedal takes part in, on either side of it.
final StreamProviderFamily<List<PedalSwap>, int> pedalSwapsProvider =
    StreamProvider.family<List<PedalSwap>, int>(
      (ref, pedalId) =>
          ref.watch(replacementRepositoryProvider).watchSwaps(pedalId),
    );
