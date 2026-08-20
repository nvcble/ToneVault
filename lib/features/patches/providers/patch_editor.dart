import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../pedals/data/pedal_draft.dart';
import '../data/patch_draft.dart';
import '../data/patch_repository.dart';
import '../data/scene_duplicator.dart';
import '../data/scene_pedal_repository.dart';
import '../data/scene_repository.dart';
import '../data/scene_value_repository.dart';
import 'patch_providers.dart';

/// What the patch and scene screens do, without any of them holding the logic.
///
/// Widgets call these methods directly, so a button is `onPressed: editor.save`
/// rather than a screen full of database calls.
class PatchEditor {
  const PatchEditor(
    this._patches,
    this._scenes,
    this._scenePedals,
    this._values,
    this._duplicator,
  );

  final PatchRepository _patches;
  final SceneRepository _scenes;
  final ScenePedalRepository _scenePedals;
  final SceneValueRepository _values;
  final SceneDuplicator _duplicator;

  /// Creates a patch, or renames an existing one, and reports which one to open
  /// afterwards.
  Future<int> savePatch(
    PatchDraft draft, {
    required int pedalId,
    int? patchId,
  }) async {
    if (patchId != null) {
      await _patches.updatePatch(patchId, draft);
      return patchId;
    }
    return _patches.createPatch(pedalId, draft);
  }

  Future<void> deletePatch(int patchId) => _patches.deletePatch(patchId);

  /// Creates a scene, or renames an existing one, and reports which one to open
  /// afterwards.
  ///
  /// A new scene starts out empty: which of the unit's pedals it uses is the
  /// user's next decision, and guessing at it would put pedals in a sound that
  /// does not have them.
  Future<int> saveScene(
    SceneDraft draft, {
    required int patchId,
    int? sceneId,
  }) async {
    if (sceneId != null) {
      await _scenes.updateScene(sceneId, draft);
      return sceneId;
    }
    return _scenes.createScene(patchId, draft);
  }

  Future<void> deleteScene(int sceneId) => _scenes.deleteScene(sceneId);

  /// Copies a scene with the pedals it uses and where their controls sit, and
  /// reports which one to open afterwards.
  Future<int> duplicateScene(int sceneId) => _duplicator.duplicate(sceneId);

  Future<void> addPedal({required int sceneId, required int pedalId}) =>
      _scenePedals.addPedal(sceneId: sceneId, pedalId: pedalId);

  /// Creates a pedal inside this scene's unit and puts it straight into the
  /// scene, reporting its id so the caller can open it: setting its controls is
  /// what the user does next.
  Future<int> addNewPedal(PedalDraft draft, {required int sceneId}) =>
      _scenePedals.addNewPedal(sceneId: sceneId, draft: draft);

  Future<void> removePedal({required int sceneId, required int pedalId}) =>
      _scenePedals.removePedal(sceneId: sceneId, pedalId: pedalId);

  Future<void> setValue({
    required int sceneId,
    required int controlId,
    required double value,
    String? reason,
  }) {
    return _values.setValue(
      sceneId: sceneId,
      controlId: controlId,
      value: value,
      reason: reason,
    );
  }

  Future<void> clearValue({
    required int sceneId,
    required int controlId,
    String? reason,
  }) {
    return _values.clearValue(
      sceneId: sceneId,
      controlId: controlId,
      reason: reason,
    );
  }
}

final Provider<PatchEditor> patchEditorProvider = Provider<PatchEditor>(
  (ref) => PatchEditor(
    ref.watch(patchRepositoryProvider),
    ref.watch(sceneRepositoryProvider),
    ref.watch(scenePedalRepositoryProvider),
    ref.watch(sceneValueRepositoryProvider),
    ref.watch(sceneDuplicatorProvider),
  ),
);
