import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/patch_control_controller.dart';
import 'midi_engine_providers.dart';
import 'midi_patch_browser_providers.dart';

/// On by default: Bank Select / Program Change is confirmed working, so
/// there is nothing left for the user to opt into before loading a patch.
final StateProvider<bool> experimentalProgramChangeEnabledProvider = StateProvider<bool>(
  (ref) => true,
);

/// The patch number the previous/next/load controls act on, per device
/// profile. Not a reading from the device - there is no confirmed way to ask
/// the MG-30 which patch it is on - only the last number this app asked it to
/// load, or 0 - the device's first slot - until it has asked for anything.
final StateProviderFamily<int, String> currentPatchNumberProvider = StateProvider.family<int, String>(
  (ref, deviceProfileId) => 0,
);

/// The Pro Scene the previous scene button press sent, per device profile -
/// same idea as [currentPatchNumberProvider]: not a reading from the device,
/// only the last one this app sent, or null until it has sent one.
final StateProviderFamily<int?, String> currentSceneNumberProvider =
    StateProvider.family<int?, String>((ref, deviceProfileId) => null);

final Provider<PatchControlController> patchControlControllerProvider =
    Provider<PatchControlController>(
      (ref) => PatchControlController(
        ref.watch(midiEngineProvider),
        ref.watch(midiPatchRecentRepositoryProvider),
      ),
    );
