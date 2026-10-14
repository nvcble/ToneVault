import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/daos/midi_patch_program_number_dao.dart';
import '../data/patch_control_controller.dart';
import 'midi_device_link_providers.dart';
import 'midi_engine_providers.dart';
import 'midi_patch_browser_providers.dart';

/// On by default: Bank Select / Program Change is confirmed working, so
/// there is nothing left for the user to opt into before loading a patch.
final StateProvider<bool> experimentalProgramChangeEnabledProvider =
    StateProvider<bool>((ref) => true);

/// The patch number the previous/next/load controls act on, per device
/// profile. Not a reading from the device - there is no confirmed way to ask
/// the MG-30 which patch it is on - only the last number this app asked it to
/// load, or 0 - the device's first slot - until it has asked for anything.
final StateProviderFamily<int, String> currentPatchNumberProvider =
    StateProvider.family<int, String>((ref, deviceProfileId) => 0);

/// The patch number last successfully loaded (double-tapped) onto the device,
/// per device profile - distinct from [currentPatchNumberProvider], which
/// moves on a single tap that only pre-selects a tile. Null until one has
/// actually loaded.
final StateProviderFamily<int?, String> currentLoadedPatchNumberProvider =
    StateProvider.family<int?, String>((ref, deviceProfileId) => null);

/// The Pro Scene the previous scene button press sent, per device profile -
/// same idea as [currentPatchNumberProvider]: not a reading from the device,
/// only the last one this app sent, or null until it has sent one.
final StateProviderFamily<int?, String> currentSceneNumberProvider =
    StateProvider.family<int?, String>((ref, deviceProfileId) => null);

/// Program number to patch name, for whichever of a device's slots its owner
/// has actually given a patch to - what a patch grid shows under each number.
///
/// Empty, rather than absent, before the device is linked gear or while its
/// patches are still loading: a grid of numbered slots is still worth showing
/// without any names on it.
final ProviderFamily<Map<int, String>, String> patchNamesByNumberProvider =
    Provider.family<Map<int, String>, String>((ref, deviceProfileId) {
      final unitId = ref
          .watch(linkedPedalProvider(deviceProfileId))
          .valueOrNull
          ?.id;
      if (unitId == null) {
        return const {};
      }
      final numbered =
          ref.watch(numberedPatchesProvider(unitId)).valueOrNull ??
          const <NumberedPatch>[];
      return {for (final row in numbered) row.programNumber: row.patch.name};
    });

final Provider<PatchControlController> patchControlControllerProvider =
    Provider<PatchControlController>(
      (ref) => PatchControlController(
        ref.watch(midiEngineProvider),
        ref.watch(midiPatchRecentRepositoryProvider),
      ),
    );
