import '../../../core/database/app_database.dart';
import '../../../core/database/daos/patch_dao.dart';
import '../../../core/database/daos/pedal_control_dao.dart';
import '../../../core/database/daos/pedal_dao.dart';
import '../../../core/database/daos/scene_dao.dart';
import '../../../core/errors/app_failure.dart';
import '../../configurations/data/configuration_defaults.dart';

/// Which of the unit's pedals one scene uses.
///
/// A scene never creates a pedal. The unit owns its pedals once, entered with
/// `host_pedal_id` set, and a scene points at the ones it reaches for - so the
/// same Tube Screamer used by three scenes is one row of gear, not three.
class ScenePedalRepository {
  ScenePedalRepository(
    this._dao,
    this._patchDao,
    this._pedalDao,
    this._controlDao, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final SceneDao _dao;
  final PatchDao _patchDao;
  final PedalDao _pedalDao;
  final PedalControlDao _controlDao;

  /// Injectable so tests can assert on exact timestamps.
  final DateTime Function() _clock;

  Stream<List<Pedal>> watchScenePedals(int sceneId) =>
      _dao.watchScenePedals(sceneId);

  /// Every control the scene can set, each with the pedal it is on.
  Stream<List<OwnedControl>> watchSceneControls(int sceneId) =>
      _dao.watchSceneControls(sceneId);

  /// Puts one of the unit's pedals into this scene, at whatever defaults its
  /// controls declare.
  ///
  /// The defaults are the same ones a new configuration starts at, and the same
  /// function decides them: a knob that never recorded a default is left unset
  /// rather than invented, because a scene is a record of where the unit actually
  /// was.
  Future<void> addPedal({required int sceneId, required int pedalId}) async {
    final scene = await _require(sceneId);
    final pedal = await _requireInsideTheUnit(scene, pedalId);

    if (await _uses(sceneId, pedalId)) {
      throw AppFailure('This scene already uses ${pedal.name}.');
    }

    final defaults = configurationDefaults(
      await _controlDao.controlsOf(pedalId),
    );
    final now = _clock();

    await guardFailure(
      () => _dao.transaction(() async {
        await _dao.addPedal(sceneId: sceneId, pedalId: pedalId);
        for (final entry in defaults.entries) {
          await _dao.upsertValue(
            sceneId: sceneId,
            controlId: entry.key,
            value: entry.value,
            updatedAt: now,
          );
        }
        await _dao.touchScene(sceneId, now);
      }),
      'Could not add that pedal to this scene.',
    );
  }

  /// Takes a pedal out of the scene, and the positions the scene held for it with
  /// it.
  ///
  /// The values go in the same transaction rather than being left behind: rows for
  /// a pedal the scene no longer uses are unreachable, and would come back the
  /// moment it was added again, showing positions the user thought they had
  /// discarded. The pedal itself stays in the vault - it belongs to the unit.
  Future<void> removePedal({required int sceneId, required int pedalId}) async {
    await _require(sceneId);
    if (!await _uses(sceneId, pedalId)) {
      throw const AppFailure('This scene does not use that pedal.');
    }
    final now = _clock();

    await guardFailure(
      () => _dao.transaction(() async {
        await _dao.deleteValuesOfPedal(sceneId: sceneId, pedalId: pedalId);
        await _dao.removePedal(sceneId: sceneId, pedalId: pedalId);
        await _dao.touchScene(sceneId, now);
      }),
      'Could not remove that pedal from this scene.',
    );
  }

  Future<Scene> _require(int sceneId) async {
    final scene = await _patchDao.findScene(sceneId);
    if (scene == null) {
      throw const AppFailure('That scene no longer exists.');
    }
    return scene;
  }

  /// A scene may only use a pedal the unit its patch is on actually holds.
  ///
  /// The foreign key alone would accept any pedal in the vault, which would let a
  /// scene of a Valeton reach for a Tube Screamer standing on the floor.
  Future<Pedal> _requireInsideTheUnit(Scene scene, int pedalId) async {
    final patch = await _patchDao.findPatch(scene.patchId);
    if (patch == null) {
      throw const AppFailure('That patch no longer exists.');
    }

    final pedal = await _pedalDao.findPedal(pedalId);
    if (pedal == null || pedal.hostPedalId != patch.pedalId) {
      throw const AppFailure('That pedal is not inside this unit.');
    }
    return pedal;
  }

  Future<bool> _uses(int sceneId, int pedalId) async {
    final pedals = await _dao.scenePedalsOf(sceneId);
    return pedals.any((pedal) => pedal.id == pedalId);
  }
}
