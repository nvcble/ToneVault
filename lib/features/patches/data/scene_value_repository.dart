import '../../../core/database/app_database.dart';
import '../../../core/database/daos/patch_dao.dart';
import '../../../core/database/daos/scene_dao.dart';
import '../../../core/errors/app_failure.dart';
import '../../configurations/data/configuration_validator.dart';
import '../../history/data/change_entry.dart';
import '../../history/data/change_log_repository.dart';

/// Where each control sits within one scene.
///
/// This is where the history of a multi-effects rig actually lives: the patch and
/// the scene are containers the user names, and this is what records that the
/// drive came up before Easter.
///
/// Every position is checked against its own control's domain by
/// `ConfigurationValidator.value` - the same rule as for a configuration, because
/// it is the same question about the same control.
class SceneValueRepository {
  SceneValueRepository(
    this._dao,
    this._patchDao,
    this._changeLog, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final SceneDao _dao;
  final PatchDao _patchDao;
  final ChangeLogRepository _changeLog;

  /// Injectable so tests can assert on exact timestamps.
  final DateTime Function() _clock;

  Stream<List<SceneValue>> watchValues(int sceneId) =>
      _dao.watchValues(sceneId);

  /// Records where one control sits in this scene.
  ///
  /// [reason] is the user's own explanation, and it is theirs to leave out.
  /// Saving the position a control is already in changes nothing, so it is not
  /// written to the history either.
  Future<void> setValue({
    required int sceneId,
    required int controlId,
    required double value,
    String? reason,
  }) async {
    final target = await _targetFor(sceneId, controlId);
    final problem = ConfigurationValidator.value(
      value,
      control: target.control,
    );
    if (problem != null) {
      throw AppFailure(problem);
    }

    final previous = await _dao.findValue(
      sceneId: sceneId,
      controlId: controlId,
    );

    await guardFailure(
      () => _dao.transaction(() async {
        await _dao.upsertValue(
          sceneId: sceneId,
          controlId: controlId,
          value: value,
          updatedAt: _clock(),
        );

        if (previous != value) {
          await _changeLog.record(_entry(target, previous, value, reason));
        }
      }),
      'Could not save this setting.',
    );
  }

  /// Forgets where one control sits, leaving it unset.
  ///
  /// A control that had no stored value is already in that state, so this succeeds
  /// either way rather than reporting a problem the user cannot act on - and
  /// records nothing, because nothing moved.
  Future<void> clearValue({
    required int sceneId,
    required int controlId,
    String? reason,
  }) async {
    final target = await _targetFor(sceneId, controlId);
    final previous = await _dao.findValue(
      sceneId: sceneId,
      controlId: controlId,
    );

    await guardFailure(
      () => _dao.transaction(() async {
        final removed = await _dao.deleteValue(
          sceneId: sceneId,
          controlId: controlId,
          updatedAt: _clock(),
        );

        if (removed) {
          await _changeLog.record(_entry(target, previous, null, reason));
        }
      }),
      'Could not clear this setting.',
    );
  }

  ChangeEntry _entry(
    _Target target,
    double? oldValue,
    double? newValue,
    String? reason,
  ) {
    return ChangeEntry.sceneValueChanged(
      patch: target.patch,
      scene: target.scene,
      control: target.control,
      controlPedal: target.controlPedal,
      oldValue: oldValue,
      newValue: newValue,
      reason: reason,
    );
  }

  /// A control can only be set within a scene that uses the pedal it is on.
  ///
  /// The check is left to the query, which joins through the scene's own pedals,
  /// so a knob on a pedal the scene does not reach for is refused the same way a
  /// deleted one is.
  ///
  /// All four rows come back together because all four are needed either way: the
  /// control to check the value against, the patch to file the entry under its
  /// unit, the scene to name the sound, and the pedal the control is on for the
  /// entry to say which of the unit's pedals moved.
  Future<_Target> _targetFor(int sceneId, int controlId) async {
    final scene = await _patchDao.findScene(sceneId);
    if (scene == null) {
      throw const AppFailure('That scene no longer exists.');
    }

    final patch = await _patchDao.findPatch(scene.patchId);
    if (patch == null) {
      throw const AppFailure('That patch no longer exists.');
    }

    final owned = await _dao.findSceneControl(
      sceneId: sceneId,
      controlId: controlId,
    );
    if (owned == null) {
      throw const AppFailure('That control is not in this scene.');
    }

    return (
      patch: patch,
      scene: scene,
      control: owned.control,
      controlPedal: owned.owner,
    );
  }
}

/// What one setting is being written to, read once and passed along.
typedef _Target = ({
  Patch patch,
  Scene scene,
  PedalControl control,
  Pedal controlPedal,
});
