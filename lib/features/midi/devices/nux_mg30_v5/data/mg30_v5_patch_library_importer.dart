import '../../../../../core/database/app_database.dart';
import '../../../../../core/database/daos/mg30_patch_payload_dao.dart';
import '../../../../../core/errors/app_failure.dart';
import '../../../../patches/data/patch_draft.dart';
import '../../../../patches/data/patch_repository.dart';
import '../../../../patches/data/scene_pedal_repository.dart';
import '../../../../patches/data/scene_repository.dart';
import '../../../../patches/data/scene_value_repository.dart';
import '../../../../pedals/data/pedal_repository.dart';
import '../../../data/midi_patch_program_repository.dart';
import '../domain/mg30_patch.dart';
import '../domain/mg30_slot_label.dart';

/// What one import run did. A slot that failed is named rather than counted, so
/// "118 of 128" can be acted on.
typedef Mg30ImportSummary = ({int imported, List<String> failures});

/// Where a patch's bytes came from. Only a device read is the device answering;
/// a file export is QuickTone's word for it.
const String mg30SourceQuickToneFile = 'quicktone_file';

/// Puts decoded MG-30 V5 patches into the library the rest of the app already
/// uses: a `Patch` per slot, a `Scene` per Pro Scene, the unit's blocks in each
/// scene, and the exact bytes kept beside them.
///
/// Nothing device-specific is invented here - a scene's amp model is written to
/// the block's own model control through `SceneValueRepository`, so an imported
/// patch reads and edits exactly like a hand-entered one.
class Mg30V5PatchLibraryImporter {
  const Mg30V5PatchLibraryImporter(
    this._patches,
    this._scenes,
    this._scenePedals,
    this._values,
    this._programs,
    this._pedals,
    this._payloads,
  );

  final PatchRepository _patches;
  final SceneRepository _scenes;
  final ScenePedalRepository _scenePedals;
  final SceneValueRepository _values;
  final MidiPatchProgramRepository _programs;
  final PedalRepository _pedals;
  final Mg30PatchPayloadDao _payloads;

  /// Imports [patches] onto [unitId], replacing any patch already imported at
  /// the same program number - the patch at slot 12 of the unit is one patch,
  /// however many times it is read.
  ///
  /// One slot failing does not stop the rest: 128 patches is a long run, and a
  /// single clashing name is not a reason to lose the other 127.
  Future<Mg30ImportSummary> import({
    required int unitId,
    required List<Mg30Patch> patches,
  }) async {
    final blocks = {
      for (final block in await _pedals.componentPedals(unitId))
        block.name: block,
    };
    if (blocks.isEmpty) {
      throw const AppFailure(
        'This unit has no blocks yet, so there is nothing for a patch to use. '
        'Add the device as gear first.',
      );
    }

    final existing = {
      for (final numbered in await _programs.numberedPatches(unitId))
        numbered.programNumber: numbered.patch,
    };
    // Names the library already holds, so a slot whose name is taken can be told
    // apart instead of refused. The device puts no such rule on its own slots.
    final taken = {
      for (final patch in await _patches.patches(unitId)) patch.name,
    }..removeAll(existing.values.map((patch) => patch.name));

    var imported = 0;
    final failures = <String>[];
    for (final patch in patches) {
      try {
        final name = _libraryName(patch, taken);
        await _importOne(unitId, patch, blocks, existing[patch.slot], name);
        taken.add(name);
        imported++;
      } catch (error) {
        failures.add('Slot ${patch.slot} ("${patch.name}"): $error');
      }
    }
    return (imported: imported, failures: failures);
  }

  /// What to call this patch in the library.
  ///
  /// The device's own name, unless it is blank or another patch already has it -
  /// two slots may share a name on the unit, where the library keeps them
  /// distinct. The slot label the unit itself displays, "01A" style, is what
  /// tells them apart, so the name still points at the slot in front of you.
  String _libraryName(Mg30Patch patch, Set<String> taken) {
    final label = mg30SlotLabel(patch.slot);
    final name = patch.name.isEmpty ? label : patch.name;
    return taken.contains(name) ? '$name $label' : name;
  }

  Future<void> _importOne(
    int unitId,
    Mg30Patch patch,
    Map<String, Pedal> blocks,
    Patch? existing,
    String name,
  ) async {
    if (existing != null) {
      await _patches.deletePatch(existing.id);
    }

    final patchId = await _patches.createPatch(unitId, PatchDraft(name: name));
    await _programs.setNumber(patchId: patchId, programNumber: patch.slot);

    for (var index = 0; index < patch.scenes.length; index++) {
      final scene = patch.scenes[index];
      final sceneId = await _scenes.createScene(
        patchId,
        SceneDraft(name: 'Scene ${index + 1}'),
      );
      // The unit's whole chain: a V5 patch runs every block, and which of them
      // are bypassed is in bytes this decoder does not read yet.
      await _scenePedals.addUnitPedals(sceneId);
      await _writeAmpModel(sceneId, scene.ampModelCode, blocks['Amp']);
    }

    await _payloads.upsert(
      Mg30PatchPayloadsCompanion.insert(
        patchId: patchId,
        slot: patch.slot,
        source: mg30SourceQuickToneFile,
        rawRecord: patch.raw,
        importedAt: DateTime.now(),
      ),
    );
  }

  /// Writes the scene's amp model onto the Amp block's own model control, which
  /// is where every other screen reads a block's model from.
  Future<void> _writeAmpModel(int sceneId, int code, Pedal? ampBlock) async {
    if (ampBlock == null) {
      return;
    }
    final control = (await _scenePedals.sceneControls(sceneId))
        .where(
          (owned) =>
              owned.owner.id == ampBlock.id &&
              owned.control.name.endsWith(' model'),
        )
        .firstOrNull;
    if (control == null) {
      return;
    }
    await _values.setValue(
      sceneId: sceneId,
      controlId: control.control.id,
      value: code.toDouble(),
    );
  }
}
