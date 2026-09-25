import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The patch a single tap highlighted in the list - UI-only, never sent to
/// the device. Distinct from [hotoneAmperoMiniActivePatchNumberProvider], per
/// the MIDI module's state-separation requirement.
final StateProvider<int> hotoneAmperoMiniPreSelectedPatchNumberProvider =
    StateProvider<int>((ref) => 0);

/// The patch number this app last confirmed sending to the device with a
/// double tap - not a reading from the device (there is no confirmed way to
/// ask the Ampero Mini which patch it is on yet), only the last one this app
/// asked it to load. Null until one has actually been sent.
final StateProvider<int?> hotoneAmperoMiniActivePatchNumberProvider =
    StateProvider<int?>((ref) => null);

/// Which patch, if any, is open in the editor - separate from both of the
/// above, so opening a patch to look at it never changes what is pre-selected
/// or active.
final StateProvider<int?> hotoneAmperoMiniEditingPatchNumberProvider =
    StateProvider<int?>((ref) => null);
