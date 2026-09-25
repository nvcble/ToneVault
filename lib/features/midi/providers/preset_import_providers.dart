import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/midi/preset_transfer/nux_mg30_v5_preset_transfer_service.dart';
import '../../controls/providers/control_providers.dart';
import '../../patches/providers/patch_providers.dart';
import '../../pedals/providers/pedal_providers.dart';
import '../data/captured_nux_mg30_v5_preset_transfer_service.dart';
import '../data/preset_import_service.dart';
import 'midi_device_link_providers.dart';
import 'midi_preset_capture_providers.dart';

/// The real transfer service for one device profile, or null when none
/// exists yet.
///
/// Always null in the app's own wiring: see
/// `NuxMg30V5PresetTransferService`'s documentation for why no real
/// implementation of it exists for the NUX MG-30 (V5). Tests override this
/// with `MockNuxMg30V5PresetTransferService` to exercise the rest of the
/// import pipeline - the app's own graph never does, so no screen a real
/// user opens can end up showing simulated data as if it came from their
/// device.
final ProviderFamily<NuxMg30V5PresetTransferService?, String>
presetTransferServiceProvider =
    Provider.family<NuxMg30V5PresetTransferService?, String>(
      (ref, deviceProfileId) => null,
    );

/// Null under the same condition as [presetTransferServiceProvider], since
/// there is nothing for it to import from.
final ProviderFamily<PresetImportService?, String> presetImportServiceProvider =
    Provider.family<PresetImportService?, String>((ref, deviceProfileId) {
      final transfer = ref.watch(
        presetTransferServiceProvider(deviceProfileId),
      );
      if (transfer == null) {
        return null;
      }
      return PresetImportService(
        transfer,
        ref.watch(patchRepositoryProvider),
        ref.watch(midiPatchProgramRepositoryProvider),
        ref.watch(sceneRepositoryProvider),
        ref.watch(scenePedalRepositoryProvider),
        ref.watch(sceneValueRepositoryProvider),
        ref.watch(pedalRepositoryProvider),
        ref.watch(controlRepositoryProvider),
      );
    });

/// The experimental counterpart of [presetImportServiceProvider]: never
/// null, because it never needs the device - it only replays raw captures
/// already saved for [unitId] in MIDI Diagnostics. See
/// [CapturedNuxMg30V5PresetTransferService].
final ProviderFamily<PresetImportService, int>
experimentalCapturedPresetImportServiceProvider =
    Provider.family<PresetImportService, int>((ref, unitId) {
      final transfer = CapturedNuxMg30V5PresetTransferService(
        ref.watch(midiPresetCaptureRepositoryProvider),
        unitId,
      );
      return PresetImportService(
        transfer,
        ref.watch(patchRepositoryProvider),
        ref.watch(midiPatchProgramRepositoryProvider),
        ref.watch(sceneRepositoryProvider),
        ref.watch(scenePedalRepositoryProvider),
        ref.watch(sceneValueRepositoryProvider),
        ref.watch(pedalRepositoryProvider),
        ref.watch(controlRepositoryProvider),
      );
    });
