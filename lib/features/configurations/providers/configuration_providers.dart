import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/configuration_dao.dart';
import '../../../core/database/database_provider.dart';
import '../../controls/providers/control_providers.dart';
import '../data/configuration_repository.dart';

final Provider<ConfigurationDao> configurationDaoProvider =
    Provider<ConfigurationDao>(
      (ref) => ConfigurationDao(ref.watch(appDatabaseProvider)),
    );

final Provider<ConfigurationRepository> configurationRepositoryProvider =
    Provider<ConfigurationRepository>(
      (ref) => ConfigurationRepository(
        ref.watch(configurationDaoProvider),
        ref.watch(pedalControlDaoProvider),
      ),
    );

/// One pedal's configurations by name. Drift pushes a new list whenever the
/// table changes, so screens never refresh by hand.
final StreamProviderFamily<List<Configuration>, int> configurationListProvider =
    StreamProvider.family<List<Configuration>, int>(
      (ref, pedalId) => ref
          .watch(configurationRepositoryProvider)
          .watchConfigurations(pedalId),
    );

/// One configuration. Watched rather than read once so a configuration deleted
/// behind an open screen is noticed.
final StreamProviderFamily<Configuration?, int> configurationProvider =
    StreamProvider.family<Configuration?, int>(
      (ref, configurationId) => ref
          .watch(configurationRepositoryProvider)
          .watchConfiguration(configurationId),
    );

/// A configuration's stored positions, keyed by control id.
///
/// A map rather than the rows themselves: the screen walks the pedal's controls
/// in display order and looks each one up, and a control with no entry is one
/// that was never set.
final StreamProviderFamily<Map<int, double>, int> configurationValuesProvider =
    StreamProvider.family<Map<int, double>, int>(
      (ref, configurationId) => ref
          .watch(configurationRepositoryProvider)
          .watchValues(configurationId)
          .map(
            (values) => {
              for (final value in values) value.controlId: value.value,
            },
          ),
    );
