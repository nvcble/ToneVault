import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/configuration_dao.dart';
import '../../../core/database/daos/pedal_control_dao.dart';
import '../../../core/errors/app_failure.dart';
import '../../history/data/change_entry.dart';
import '../../history/data/change_log_repository.dart';
import 'configuration_draft.dart';
import 'configuration_validator.dart';

/// Configuration operations for one pedal at a time.
///
/// Owns what the database cannot express on its own: validation, createdAt and
/// updatedAt bookkeeping, and turning driver exceptions into [AppFailure]s whose
/// message can be shown to the user as-is. Where each control sits within a
/// configuration belongs to `ConfigurationValueRepository`.
///
/// Reads the control definitions too, because that is the only way to know what
/// a value is allowed to be: every position is checked against its own control's
/// domain rather than against anything this class knows about pedals.
class ConfigurationRepository {
  ConfigurationRepository(
    this._dao,
    this._controlDao,
    this._changeLog, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final ConfigurationDao _dao;
  final PedalControlDao _controlDao;
  final ChangeLogRepository _changeLog;

  /// Injectable so tests can assert on exact timestamps.
  final DateTime Function() _clock;

  Stream<List<Configuration>> watchConfigurations(int pedalId) =>
      _dao.watchConfigurations(pedalId);

  Stream<Configuration?> watchConfiguration(int configurationId) =>
      _dao.watchConfiguration(configurationId);

  /// Creates a configuration, along with the positions it starts out with.
  Future<int> createConfiguration(int pedalId, ConfigurationDraft draft) async {
    final configuration = _validated(draft);
    await _ensureNameIsFree(pedalId, configuration.name);

    // The pedals inside a multi-effects unit included: a scene of that unit
    // starts out setting the controls on its patch, which are not the unit's own.
    final controls = await _controlDao.settableControlsOf(pedalId);
    final values = _validatedValues(configuration.values, controls);
    final now = _clock();

    return _guard(
      () => _dao.transaction(() async {
        final configurationId = await _dao.insertConfiguration(
          ConfigurationsCompanion.insert(
            pedalId: pedalId,
            name: configuration.name,
            notes: Value(configuration.notes),
            createdAt: now,
            updatedAt: now,
          ),
          values: values,
        );

        // Read back rather than rebuilt from the draft, so the entry names the
        // row that was actually written.
        final inserted = await _dao.findConfiguration(configurationId);
        await _changeLog.record(ChangeEntry.configurationCreated(inserted!));

        return configurationId;
      }),
      'Could not save this configuration.',
    );
  }

  /// Renames a configuration and rewrites its notes. Stored positions are
  /// untouched: those are saved one control at a time.
  ///
  /// Only the rename is history. Rewritten notes are the user correcting their
  /// own description of a configuration, not the configuration changing.
  Future<void> updateConfiguration(
    int configurationId,
    ConfigurationDraft draft,
  ) async {
    final configuration = _validated(draft);
    final existing = await _require(configurationId);
    await _ensureNameIsFree(
      existing.pedalId,
      configuration.name,
      exceptConfigurationId: configurationId,
    );

    await _guard(
      () => _dao.transaction(() async {
        await _dao.updateConfiguration(
          configurationId,
          ConfigurationsCompanion(
            name: Value(configuration.name),
            notes: Value(configuration.notes),
            updatedAt: Value(_clock()),
          ),
        );

        if (existing.name != configuration.name) {
          await _changeLog.record(
            ChangeEntry.configurationRenamed(
              configuration: existing.copyWith(name: configuration.name),
              previousName: existing.name,
            ),
          );
        }
      }),
      'Could not update this configuration.',
    );
  }

  /// The stored positions go with it: `configuration_values` references
  /// configurations with ON DELETE CASCADE. Asking the user first is the UI's
  /// job, since it is the only place that knows they meant it.
  ///
  /// Past entries about this configuration survive it. `change_logs` references
  /// configurations with ON DELETE SET NULL, and each entry kept a copy of the
  /// name for exactly this moment.
  Future<void> deleteConfiguration(int configurationId) async {
    final existing = await _require(configurationId);

    await _guard(
      () => _dao.transaction(() async {
        await _dao.deleteConfiguration(configurationId);
        await _changeLog.record(ChangeEntry.configurationDeleted(existing));
      }),
      'Could not delete this configuration.',
    );
  }

  ConfigurationDraft _validated(ConfigurationDraft draft) {
    final normalized = draft.normalized();
    final problem = ConfigurationValidator.draft(normalized);
    if (problem != null) {
      throw AppFailure(problem);
    }
    return normalized;
  }

  /// Checks each starting position against the control it belongs to, so a
  /// configuration is never stored holding a value its own pedal cannot be in.
  Map<int, double> _validatedValues(
    Map<int, double> values,
    List<PedalControl> controls,
  ) {
    final byId = {for (final control in controls) control.id: control};

    for (final entry in values.entries) {
      final control = byId[entry.key];
      if (control == null) {
        throw const AppFailure('That control is no longer on this pedal.');
      }
      final problem = ConfigurationValidator.value(
        entry.value,
        control: control,
      );
      if (problem != null) {
        throw AppFailure(problem);
      }
    }

    return values;
  }

  Future<Configuration> _require(int configurationId) async {
    final configuration = await _dao.findConfiguration(configurationId);
    if (configuration == null) {
      throw const AppFailure('That configuration no longer exists.');
    }
    return configuration;
  }

  /// The `{pedalId, name}` unique key would catch a repeat, but only exactly:
  /// "Clean" and "clean" on one pedal are equally ambiguous, and a checked name
  /// gives the user the name in the message.
  Future<void> _ensureNameIsFree(
    int pedalId,
    String name, {
    int? exceptConfigurationId,
  }) async {
    final existing = await _dao.configurationsOf(pedalId);
    final clash = existing.any(
      (configuration) =>
          configuration.id != exceptConfigurationId &&
          configuration.name.toLowerCase() == name.toLowerCase(),
    );

    if (clash) {
      throw AppFailure(
        'This pedal already has a configuration called "$name".',
      );
    }
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
