import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/daos/pedal_control_dao.dart';
import '../../controls/providers/control_providers.dart';
import '../data/configuration_defaults.dart';
import '../data/configuration_draft.dart';
import '../data/configuration_repository.dart';
import '../data/configuration_value_repository.dart';
import 'configuration_providers.dart';

/// What the configuration screens do, without any of them holding the logic.
///
/// Widgets call these methods directly, so a button is `onPressed: editor.save`
/// rather than a screen full of database calls.
class ConfigurationEditor {
  const ConfigurationEditor(
    this._repository,
    this._valueRepository,
    this._controlDao,
  );

  final ConfigurationRepository _repository;
  final ConfigurationValueRepository _valueRepository;
  final PedalControlDao _controlDao;

  /// Creates a configuration, or renames an existing one, and reports which one
  /// to open afterwards.
  ///
  /// A new configuration starts out at whatever defaults the pedal's controls
  /// declare, which is the closest thing to "where this pedal usually sits"
  /// that the app actually knows. Renaming leaves the stored positions alone.
  Future<int> save(
    ConfigurationDraft draft, {
    required int pedalId,
    int? configurationId,
  }) async {
    if (configurationId != null) {
      await _repository.updateConfiguration(configurationId, draft);
      return configurationId;
    }

    final controls = await _controlDao.controlsOf(pedalId);
    return _repository.createConfiguration(
      pedalId,
      ConfigurationDraft(
        name: draft.name,
        notes: draft.notes,
        values: configurationDefaults(controls),
      ),
    );
  }

  Future<void> delete(int configurationId) =>
      _repository.deleteConfiguration(configurationId);

  Future<void> setValue({
    required int configurationId,
    required int controlId,
    required double value,
    String? reason,
  }) {
    return _valueRepository.setValue(
      configurationId: configurationId,
      controlId: controlId,
      value: value,
      reason: reason,
    );
  }

  Future<void> clearValue({
    required int configurationId,
    required int controlId,
    String? reason,
  }) {
    return _valueRepository.clearValue(
      configurationId: configurationId,
      controlId: controlId,
      reason: reason,
    );
  }
}

final Provider<ConfigurationEditor> configurationEditorProvider =
    Provider<ConfigurationEditor>(
      (ref) => ConfigurationEditor(
        ref.watch(configurationRepositoryProvider),
        ref.watch(configurationValueRepositoryProvider),
        ref.watch(pedalControlDaoProvider),
      ),
    );
