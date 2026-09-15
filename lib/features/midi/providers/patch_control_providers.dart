import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/patch_control_controller.dart';
import 'midi_engine_providers.dart';
import 'midi_patch_browser_providers.dart';

/// Off by default every time the app starts, so sending an unverified
/// Program Change is always something the user just chose to do this
/// session rather than a setting left on from before.
final StateProvider<bool> experimentalProgramChangeEnabledProvider = StateProvider<bool>(
  (ref) => false,
);

/// The patch number the previous/next/load controls act on, per device
/// profile. Not a reading from the device - there is no confirmed way to ask
/// the MG-30 which patch it is on - only the last number this app asked it to
/// load, or 1 until it has asked for anything.
final StateProviderFamily<int, String> currentPatchNumberProvider = StateProvider.family<int, String>(
  (ref, deviceProfileId) => 1,
);

final Provider<PatchControlController> patchControlControllerProvider =
    Provider<PatchControlController>(
      (ref) => PatchControlController(
        ref.watch(midiEngineProvider),
        ref.watch(midiPatchRecentRepositoryProvider),
      ),
    );
