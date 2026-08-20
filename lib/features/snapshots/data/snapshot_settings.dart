import '../../../core/database/daos/configuration_dao.dart';
import '../../../core/database/daos/patch_dao.dart';
import '../../../core/database/daos/pedal_control_dao.dart';
import '../../../core/database/daos/scene_dao.dart';
import '../../../core/errors/app_failure.dart';
import '../../patches/data/scene_label.dart';

/// What one pedal on the rig was set to, gathered ready to be frozen.
///
/// [label] is the name the snapshot keeps as text, and [controls] with
/// [positions] are the readings under it: every control the setting could reach,
/// and where the ones it dialled in sit.
typedef SnapshotSetting = ({
  String label,
  List<OwnedControl> controls,
  Map<int, double> positions,
});

/// Turns the choices made on the capture screen into what a snapshot stores.
///
/// A pedal is recorded as being on one of its own configurations; a multi-effects
/// unit, which has no configurations, is recorded as being on a scene of one of
/// its patches. Both come back as the same [SnapshotSetting], so capture itself
/// does not care which kind of sound it is freezing.
///
/// Every choice is checked against the database as it stands now. A choice made
/// on screen before someone edited the rig or the unit would otherwise be
/// captured as fact, or fail as a constraint violation with nothing readable in
/// it.
class SnapshotSettings {
  SnapshotSettings(
    this._configurationDao,
    this._controlDao,
    this._patchDao,
    this._sceneDao,
  );

  final ConfigurationDao _configurationDao;
  final PedalControlDao _controlDao;
  final PatchDao _patchDao;
  final SceneDao _sceneDao;

  /// The setting chosen for each pedal, keyed by pedal id.
  ///
  /// [onTheRig] is the pedals the snapshot is about. A pedal left out of both
  /// choice maps is absent from the result, which is how "not recorded" travels.
  Future<Map<int, SnapshotSetting>> resolve({
    required Set<int> onTheRig,
    required Map<int, int> configurationChoices,
    required Map<int, int> sceneChoices,
  }) async {
    final settings = <int, SnapshotSetting>{};

    for (final choice in configurationChoices.entries) {
      _checkOnTheRig(choice.key, onTheRig);
      settings[choice.key] = await _configuration(choice.key, choice.value);
    }

    for (final choice in sceneChoices.entries) {
      _checkOnTheRig(choice.key, onTheRig);
      if (settings.containsKey(choice.key)) {
        // One pedal was on one sound. Letting the second answer win would record
        // a reading nobody chose over one they did.
        throw const AppFailure(
          'One of those pedals was given two settings. Reopen the rig and try '
          'again.',
        );
      }
      settings[choice.key] = await _scene(choice.key, choice.value);
    }

    return settings;
  }

  void _checkOnTheRig(int pedalId, Set<int> onTheRig) {
    if (!onTheRig.contains(pedalId)) {
      throw const AppFailure(
        'One of those pedals is no longer on this rig. Reopen the rig and try '
        'again.',
      );
    }
  }

  Future<SnapshotSetting> _configuration(
    int pedalId,
    int configurationId,
  ) async {
    final configuration = await _configurationDao.findConfiguration(
      configurationId,
    );
    if (configuration == null || configuration.pedalId != pedalId) {
      throw const AppFailure(
        'One of those configurations is no longer on its pedal. Reopen the rig '
        'and try again.',
      );
    }

    final values = await _configurationDao.valuesOf(configuration.id);
    return (
      label: configuration.name,
      // Every control the configuration could set, which for a unit is the
      // controls of the pedals inside it.
      controls: await _controlDao.ownedSettableControlsOf(pedalId),
      positions: {for (final value in values) value.controlId: value.value},
    );
  }

  Future<SnapshotSetting> _scene(int pedalId, int sceneId) async {
    final found = await _patchDao.findUnitScene(
      pedalId: pedalId,
      sceneId: sceneId,
    );
    if (found == null) {
      throw const AppFailure(
        'One of those scenes is no longer on its unit. Reopen the rig and try '
        'again.',
      );
    }

    final values = await _sceneDao.valuesOf(sceneId);
    return (
      // The patch as well as the scene: "Verse" alone would not say which sound.
      label: sceneLabel(found.patch.name, found.scene.name),
      // Only the pedals the scene actually uses, which is narrower than the
      // unit - that is what makes a scene a scene.
      controls: await _sceneDao.sceneControlsOf(sceneId),
      positions: {for (final value in values) value.controlId: value.value},
    );
  }
}
