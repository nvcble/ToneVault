import '../../../core/database/app_database.dart';
import '../../../core/midi/preset_transfer/imported_preset.dart';
import '../../../core/midi/preset_transfer/nux_mg30_v5_preset_transfer_service.dart';
import '../../controls/data/control_repository.dart';
import '../../patches/data/patch_draft.dart';
import '../../patches/data/patch_repository.dart';
import '../../patches/data/scene_pedal_repository.dart';
import '../../patches/data/scene_repository.dart';
import '../../patches/data/scene_value_repository.dart';
import '../../pedals/data/pedal_repository.dart';
import 'midi_patch_program_repository.dart';

/// Whether to keep or replace a patch already imported at the same program
/// number as an incoming one.
enum PresetImportDecision { skip, overwrite }

/// What one import run did.
typedef PresetImportSummary = ({int imported, int overwritten, int skipped, List<PresetImportFailure> failures});

/// One preset that could not be imported, and why - a name clash with an
/// existing patch on the unit is the likeliest cause.
typedef PresetImportFailure = ({int programNumber, String message});

/// Turns [ImportedPreset]s into the same Patch/Scene/pedal/control rows a
/// user filling them in by hand would leave - see
/// `MidiDeviceLinkRepository` for the block pedals this reads, seeded the
/// same way when the device was added as gear.
///
/// Never wired to a real [NuxMg30V5PresetTransferService] in the app's own
/// provider graph: see that interface's documentation for why none exists.
class PresetImportService {
  const PresetImportService(
    this._transfer,
    this._patches,
    this._programs,
    this._scenes,
    this._scenePedals,
    this._sceneValues,
    this._pedals,
    this._controls,
  );

  final NuxMg30V5PresetTransferService _transfer;
  final PatchRepository _patches;
  final MidiPatchProgramRepository _programs;
  final SceneRepository _scenes;
  final ScenePedalRepository _scenePedals;
  final SceneValueRepository _sceneValues;
  final PedalRepository _pedals;
  final ControlRepository _controls;

  Future<List<ImportedPreset>> fetchPresets({void Function(int completed, int total)? onProgress}) =>
      _transfer.importAllPresets(onProgress: onProgress);

  /// Imports [presets] onto [unitId], calling [resolveDuplicate] whenever an
  /// already-imported patch holds the incoming preset's program number.
  ///
  /// One preset failing - a name clash with a patch outside this import, for
  /// instance - is recorded in the summary rather than stopping the rest.
  Future<PresetImportSummary> importPresets({
    required int unitId,
    required List<ImportedPreset> presets,
    required Future<PresetImportDecision> Function(ImportedPreset incoming, Patch existing) resolveDuplicate,
  }) async {
    final existingByNumber = {
      for (final numbered in await _programs.watchNumberedPatches(unitId).first)
        numbered.programNumber: numbered.patch,
    };
    final blockPedalsByLabel = {
      for (final pedal in await _pedals.watchComponentPedals(unitId).first) pedal.name: pedal,
    };

    var imported = 0;
    var overwritten = 0;
    var skipped = 0;
    final failures = <PresetImportFailure>[];

    for (final preset in presets) {
      try {
        final existing = existingByNumber[preset.programNumber];
        var isOverwrite = false;
        if (existing != null) {
          final decision = await resolveDuplicate(preset, existing);
          if (decision == PresetImportDecision.skip) {
            skipped++;
            continue;
          }
          await _patches.deletePatch(existing.id);
          isOverwrite = true;
        }
        // Counted only once the patch, scene and its values are actually
        // written - a preset that fails partway through is a failure, not a
        // partial import.
        await _importOne(unitId, preset, blockPedalsByLabel);
        if (isOverwrite) {
          overwritten++;
        } else {
          imported++;
        }
      } catch (error) {
        failures.add((programNumber: preset.programNumber, message: error.toString()));
      }
    }

    return (imported: imported, overwritten: overwritten, skipped: skipped, failures: failures);
  }

  Future<void> _importOne(
    int unitId,
    ImportedPreset preset,
    Map<String, Pedal> blockPedalsByLabel,
  ) async {
    final patchId = await _patches.createPatch(unitId, PatchDraft(name: preset.name));
    await _programs.setNumber(patchId: patchId, programNumber: preset.programNumber);
    final sceneId = await _scenes.createScene(patchId, const SceneDraft(name: 'Imported'));

    for (final block in preset.blocks) {
      final pedal = blockPedalsByLabel[block.label];
      if (pedal == null) {
        // Not one of this profile's seeded blocks - the Send/Return loop, on
        // the MG-30, which has no model or knob to seed a control for.
        continue;
      }
      await _scenePedals.addPedal(sceneId: sceneId, pedalId: pedal.id);
      final controls = await _controls.watchControls(pedal.id).first;

      if (block.modelNumber != null) {
        await _setValueByName(sceneId, controls, '${block.label} model', block.modelNumber!.toDouble());
      }
      for (final entry in block.parameters.entries) {
        await _setValueByName(sceneId, controls, entry.key, entry.value);
      }
    }
  }

  Future<void> _setValueByName(
    int sceneId,
    List<PedalControl> controls,
    String name,
    double value,
  ) async {
    final control = controls.where((candidate) => candidate.name == name).firstOrNull;
    if (control == null) {
      return;
    }
    await _sceneValues.setValue(sceneId: sceneId, controlId: control.id, value: value);
  }
}
