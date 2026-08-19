import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pedal_control_dao.dart';
import '../../../core/database/database_provider.dart';
import '../data/control_repository.dart';

final Provider<PedalControlDao> pedalControlDaoProvider =
    Provider<PedalControlDao>(
      (ref) => PedalControlDao(ref.watch(appDatabaseProvider)),
    );

final Provider<ControlRepository> controlRepositoryProvider =
    Provider<ControlRepository>(
      (ref) => ControlRepository(ref.watch(pedalControlDaoProvider)),
    );

/// One pedal's controls in display order. Drift pushes a new list whenever the
/// `pedal_controls` table changes, so screens never refresh by hand.
final StreamProviderFamily<List<PedalControl>, int> controlListProvider =
    StreamProvider.family<List<PedalControl>, int>(
      (ref, pedalId) =>
          ref.watch(controlRepositoryProvider).watchControls(pedalId),
    );
