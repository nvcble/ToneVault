import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pedal_control_dao.dart';
import '../../../core/database/database_provider.dart';
import '../../history/providers/history_providers.dart';
import '../data/control_group.dart';
import '../data/control_repository.dart';

final Provider<PedalControlDao> pedalControlDaoProvider =
    Provider<PedalControlDao>(
      (ref) => PedalControlDao(ref.watch(appDatabaseProvider)),
    );

final Provider<ControlRepository> controlRepositoryProvider =
    Provider<ControlRepository>(
      (ref) => ControlRepository(
        ref.watch(pedalControlDaoProvider),
        ref.watch(changeLogRepositoryProvider),
      ),
    );

/// One pedal's controls in display order. Drift pushes a new list whenever the
/// `pedal_controls` table changes, so screens never refresh by hand.
final StreamProviderFamily<List<PedalControl>, int> controlListProvider =
    StreamProvider.family<List<PedalControl>, int>(
      (ref, pedalId) =>
          ref.watch(controlRepositoryProvider).watchControls(pedalId),
    );

/// Every control a configuration of one pedal can set, grouped by the pedal each
/// is on. The same list for an ordinary pedal as [controlListProvider]; for a
/// multi-effects unit in scene mode, the controls of the pedals on its patch.
final StreamProviderFamily<List<ControlGroup>, int> settableControlsProvider =
    StreamProvider.family<List<ControlGroup>, int>(
      (ref, pedalId) => ref
          .watch(controlRepositoryProvider)
          .watchSettableControls(pedalId)
          .map(groupByOwner),
    );

/// One control, for the edit form. Watched rather than read once so a control
/// deleted from the list behind the form is noticed.
final StreamProviderFamily<PedalControl?, int> controlProvider =
    StreamProvider.family<PedalControl?, int>(
      (ref, controlId) =>
          ref.watch(controlRepositoryProvider).watchControl(controlId),
    );
