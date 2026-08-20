import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/patch_dao.dart';
import '../../../core/database/daos/scene_dao.dart';
import '../../../core/database/database_provider.dart';
import '../../controls/data/control_group.dart';
import '../../controls/providers/control_providers.dart';
import '../../history/providers/history_providers.dart';
import '../../pedals/providers/pedal_providers.dart';
import '../data/patch_repository.dart';
import '../data/scene_pedal_repository.dart';
import '../data/scene_repository.dart';
import '../data/scene_value_repository.dart';

final Provider<PatchDao> patchDaoProvider = Provider<PatchDao>(
  (ref) => PatchDao(ref.watch(appDatabaseProvider)),
);

final Provider<SceneDao> sceneDaoProvider = Provider<SceneDao>(
  (ref) => SceneDao(ref.watch(appDatabaseProvider)),
);

final Provider<PatchRepository> patchRepositoryProvider =
    Provider<PatchRepository>(
      (ref) => PatchRepository(
        ref.watch(patchDaoProvider),
        ref.watch(changeLogRepositoryProvider),
      ),
    );

final Provider<SceneRepository> sceneRepositoryProvider =
    Provider<SceneRepository>(
      (ref) => SceneRepository(
        ref.watch(patchDaoProvider),
        ref.watch(changeLogRepositoryProvider),
      ),
    );

final Provider<ScenePedalRepository> scenePedalRepositoryProvider =
    Provider<ScenePedalRepository>(
      (ref) => ScenePedalRepository(
        ref.watch(sceneDaoProvider),
        ref.watch(patchDaoProvider),
        ref.watch(pedalDaoProvider),
        ref.watch(pedalControlDaoProvider),
      ),
    );

final Provider<SceneValueRepository> sceneValueRepositoryProvider =
    Provider<SceneValueRepository>(
      (ref) => SceneValueRepository(
        ref.watch(sceneDaoProvider),
        ref.watch(patchDaoProvider),
        ref.watch(changeLogRepositoryProvider),
      ),
    );

/// One unit's patches by name. Drift pushes a new list whenever the table
/// changes, so screens never refresh by hand.
final StreamProviderFamily<List<Patch>, int> patchListProvider =
    StreamProvider.family<List<Patch>, int>(
      (ref, pedalId) =>
          ref.watch(patchRepositoryProvider).watchPatches(pedalId),
    );

/// One patch. Watched rather than read once so a patch deleted behind an open
/// screen is noticed.
final StreamProviderFamily<Patch?, int> patchProvider =
    StreamProvider.family<Patch?, int>(
      (ref, patchId) => ref.watch(patchRepositoryProvider).watchPatch(patchId),
    );

final StreamProviderFamily<List<Scene>, int> sceneListProvider =
    StreamProvider.family<List<Scene>, int>(
      (ref, patchId) => ref.watch(sceneRepositoryProvider).watchScenes(patchId),
    );

final StreamProviderFamily<Scene?, int> sceneProvider =
    StreamProvider.family<Scene?, int>(
      (ref, sceneId) => ref.watch(sceneRepositoryProvider).watchScene(sceneId),
    );

/// The pedals one scene uses, by name.
final StreamProviderFamily<List<Pedal>, int> scenePedalListProvider =
    StreamProvider.family<List<Pedal>, int>(
      (ref, sceneId) =>
          ref.watch(scenePedalRepositoryProvider).watchScenePedals(sceneId),
    );

/// The controls a scene can set, grouped by the pedal each is on.
///
/// The same shape `settableControlsProvider` gives a configuration, so the widget
/// that lists positions does not care which of the two it is showing.
final StreamProviderFamily<List<ControlGroup>, int> sceneControlsProvider =
    StreamProvider.family<List<ControlGroup>, int>(
      (ref, sceneId) => ref
          .watch(scenePedalRepositoryProvider)
          .watchSceneControls(sceneId)
          .map(groupByOwner),
    );

/// A scene's stored positions, keyed by control id.
///
/// A map rather than the rows themselves: the screen walks the scene's controls in
/// order and looks each one up, and a control with no entry is one that was never
/// set.
final StreamProviderFamily<Map<int, double>, int> sceneValuesProvider =
    StreamProvider.family<Map<int, double>, int>(
      (ref, sceneId) => ref
          .watch(sceneValueRepositoryProvider)
          .watchValues(sceneId)
          .map(
            (values) => {
              for (final value in values) value.controlId: value.value,
            },
          ),
    );
