import 'midi_device_profile.dart';
import 'profiles/hotone_ampero_mini/hotone_ampero_mini_profile.dart';
import 'profiles/nux_mg30_v5/nux_mg30_v5_profile.dart';

/// Every device profile the app ships with, in the order the device
/// selection screen lists them.
///
/// The seam for a second device: a new profile implementation and one more
/// entry here, never a change to the engine or the screens that read this
/// list.
abstract final class MidiDeviceRegistry {
  static const List<MidiDeviceProfile> profiles = [
    NuxMg30V5Profile(),
    HotoneAmperoMiniProfile(),
  ];

  static MidiDeviceProfile? findById(String id) =>
      profiles.where((profile) => profile.id == id).firstOrNull;
}
