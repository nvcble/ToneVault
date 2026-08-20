import '../../../core/database/app_database.dart';
import '../../../core/database/daos/patch_dao.dart';
import '../../../core/database/daos/pedal_control_dao.dart';
import '../../../core/database/daos/pedal_dao.dart';
import '../../../core/database/daos/scene_dao.dart';
import '../../../core/errors/app_failure.dart';
import '../../configurations/data/configuration_defaults.dart';
import '../../pedals/data/pedal_draft.dart';
import '../../pedals/data/pedal_repository.dart';

/// Which of the unit's pedals one scene uses.
///
/// The unit owns its pedals, entered once with `host_pedal_id` set, and a scene
/// points at the ones it reaches for - so the same Tube Screamer used by three
/// scenes is one row of gear, not three.
///
/// A pedal may be entered from inside a scene as well as from the unit's own list;
/// see [addNewPedal]. Either way it lands in the unit and the scene points at it,
/// so its controls, configurations and history are the one pedal's.
class ScenePedalRepository {
  ScenePedalRepository(
    this._dao,
    this._patchDao,
    this._pedalDao,
    this._controlDao,
    this._pedals, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final SceneDao _dao;
  final PatchDao _patchDao;
  final PedalDao _pedalDao;
  final PedalControlDao _controlDao;

  /// The inventory, which is where a pedal is created: naming rules, timestamps
  /// and the pedal's own history stay in one place rather than being written a
  /// second way for pedals that happen to arrive through a scene.
  final PedalRepository _pedals;

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

  /// Creates a pedal inside this scene's unit, puts it straight into the scene,
  /// and returns its id.
  ///
  /// The pedal is filed under the unit the scene's patch is on, taken from the
  /// scene rather than from [draft]: a block added here belongs to that unit, and
  /// a form cannot be allowed to say otherwise.
  ///
  /// Both writes are one transaction. A link that fails would otherwise leave a
  /// pedal inside the unit that the user never sees on the screen they added it
  /// from.
  Future<int> addNewPedal({
    required int sceneId,
    required PedalDraft draft,
  }) async {
    final scene = await _require(sceneId);
    final patch = await _requirePatchOf(scene);

    return guardFailure(
      () => _dao.transaction(() async {
        final pedalId = await _pedals.createPedal(
          draft.insideUnit(patch.pedalId),
        );
        // Through the same path a picked pedal takes, so a new one arrives at the
        // defaults its controls declare and the scene is marked touched once.
        await addPedal(sceneId: sceneId, pedalId: pedalId);
        return pedalId;
      }),
      'Could not add this pedal to the scene.',
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
    final patch = await _requirePatchOf(scene);
    final pedal = await _pedalDao.findPedal(pedalId);
    if (pedal == null || pedal.hostPedalId != patch.pedalId) {
      throw const AppFailure('That pedal is not inside this unit.');
    }
    return pedal;
  }

  /// The patch a scene is a sound of, which is what says which unit it is on.
  Future<Patch> _requirePatchOf(Scene scene) async {
    final patch = await _patchDao.findPatch(scene.patchId);
    if (patch == null) {
      throw const AppFailure('That patch no longer exists.');
    }
    return patch;
  }

  Future<bool> _uses(int sceneId, int pedalId) async {
    final pedals = await _dao.scenePedalsOf(sceneId);
    return pedals.any((pedal) => pedal.id == pedalId);
  }
}
