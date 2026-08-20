import '../../../core/database/app_database.dart';
import '../../../core/database/daos/configuration_dao.dart';
import '../../../core/database/daos/pedal_control_dao.dart';
import '../../../core/errors/app_failure.dart';
import '../../history/data/change_entry.dart';
import '../../history/data/change_log_repository.dart';
import 'configuration_validator.dart';

/// Where each control sits within one configuration.
///
/// Separate from `ConfigurationRepository` because it answers a different
/// question: that one owns the configurations a pedal has, this one owns the
/// positions inside them, which is where the history of a rig actually lives.
///
/// Every position is checked against its own control's domain, so nothing here
/// knows anything about particular pedals.
class ConfigurationValueRepository {
  ConfigurationValueRepository(
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

  Stream<List<ConfigurationValue>> watchValues(int configurationId) =>
      _dao.watchValues(configurationId);

  /// Records where one control sits in this configuration.
  ///
  /// [reason] is the user's own explanation, and it is theirs to leave out.
  /// Saving the position a control is already in changes nothing, so it is not
  /// written to the history either.
  Future<void> setValue({
    required int configurationId,
    required int controlId,
    required double value,
    String? reason,
  }) async {
    final target = await _targetFor(configurationId, controlId);
    final problem = ConfigurationValidator.value(
      value,
      control: target.control,
    );
    if (problem != null) {
      throw AppFailure(problem);
    }

    final previous = await _dao.findValue(
      configurationId: configurationId,
      controlId: controlId,
    );

    await _guard(
      () => _dao.transaction(() async {
        await _dao.upsertValue(
          configurationId: configurationId,
          controlId: controlId,
          value: value,
          updatedAt: _clock(),
        );

        if (previous != value) {
          await _changeLog.record(
            ChangeEntry.controlValueChanged(
              configuration: target.configuration,
              control: target.control,
              oldValue: previous,
              newValue: value,
              reason: reason,
            ),
          );
        }
      }),
      'Could not save this setting.',
    );
  }

  /// Forgets where one control sits, leaving it unset.
  ///
  /// A control that had no stored value is already in that state, so this
  /// succeeds either way rather than reporting a problem the user cannot act on -
  /// and records nothing, because nothing moved.
  Future<void> clearValue({
    required int configurationId,
    required int controlId,
    String? reason,
  }) async {
    final target = await _targetFor(configurationId, controlId);
    final previous = await _dao.findValue(
      configurationId: configurationId,
      controlId: controlId,
    );

    await _guard(
      () => _dao.transaction(() async {
        final removed = await _dao.deleteValue(
          configurationId: configurationId,
          controlId: controlId,
          updatedAt: _clock(),
        );

        if (removed) {
          await _changeLog.record(
            ChangeEntry.controlValueChanged(
              configuration: target.configuration,
              control: target.control,
              oldValue: previous,
              newValue: null,
              reason: reason,
            ),
          );
        }
      }),
      'Could not clear this setting.',
    );
  }

  /// A control can only be set within a configuration of the pedal it is on, or
  /// of the multi-effects unit that pedal sits inside.
  ///
  /// The second case is what a scene is: the unit is the patch, and its scenes
  /// set the controls of the pedals on that patch. The check is left to the
  /// query, so nothing here has to know which kind of pedal it is looking at.
  ///
  /// Both rows come back together because both are needed either way: the
  /// control to check the value against, and the configuration to file the
  /// history entry under the right pedal.
  Future<({Configuration configuration, PedalControl control})> _targetFor(
    int configurationId,
    int controlId,
  ) async {
    final configuration = await _dao.findConfiguration(configurationId);
    if (configuration == null) {
      throw const AppFailure('That configuration no longer exists.');
    }

    final control = await _controlDao.findSettableControl(
      controlId: controlId,
      pedalId: configuration.pedalId,
    );
    if (control == null) {
      throw const AppFailure('That control is no longer on this pedal.');
    }

    return (configuration: configuration, control: control);
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
