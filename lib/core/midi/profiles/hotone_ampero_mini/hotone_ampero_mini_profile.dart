import '../../midi_block_definition.dart';
import '../../midi_device_profile.dart';
import '../../midi_feature.dart';
import '../../midi_parameter_definition.dart';
import '../../midi_support_level.dart';
import '../../midi_transport_type.dart';
import '../../patch_selection_defaults.dart';
import 'hotone_ampero_mini_capabilities.dart';

/// The Hotone Ampero Mini - retail model number MP-50, a pure patch-based
/// multi-effects unit. No Scenes, no Send/Return: see
/// [hotoneAmperoMiniCapabilities] for exactly what is and is not confirmed.
///
/// Built independently of the NUX MG-30 (V5) profile - a different device,
/// researched and verified on its own. Hotone publishes no MIDI
/// implementation chart for this model (it does for the Ampero II, not the
/// Mini), so this profile is deliberately conservative: only Program Change
/// patch selection is marked [MidiSupportLevel.supported], because it is the
/// only thing actually tried against real hardware so far.
class HotoneAmperoMiniProfile extends MidiDeviceProfile {
  const HotoneAmperoMiniProfile();

  @override
  String get id => 'hotone_ampero_mini';

  @override
  String get manufacturer => 'Hotone';

  @override
  String get model => 'Ampero Mini (MP-50)';

  /// Not read from the device - no identify command has been confirmed for
  /// this model. Left unknown rather than guessed, per the firmware-awareness
  /// requirement: behavior seen on one firmware is not assumed to hold on
  /// another.
  @override
  String get firmwareVersion => 'Unknown';

  @override
  String get displayName => 'Hotone Ampero Mini';

  /// Confirmed on real hardware: the unit connects over USB as a
  /// class-compliant MIDI device.
  @override
  List<MidiTransportType> get connectionTypes => const [MidiTransportType.usb];

  /// Confirmed on real hardware: Program Change on channel 0 changed the
  /// loaded patch. Not stated by any official source, so this is a tested
  /// default, not a documented one.
  @override
  int get defaultChannel => 0;

  @override
  Map<MidiFeature, MidiSupportLevel> get capabilities =>
      hotoneAmperoMiniCapabilities;

  /// Empty: no CC has been confirmed for this unit.
  @override
  List<MidiParameterDefinition> get parameterDefinitions => const [];

  /// Empty: with no confirmed CCs, there is no signal-chain block to name.
  @override
  List<MidiBlockDefinition> get blockDefinitions => const [];

  /// A plain Program Change (0-127), no Bank Select - confirmed on real
  /// hardware rather than offered as a candidate, unlike `NuxMg30V5Profile`'s
  /// own still-unverified one.
  @override
  PatchSelectionDefaults get patchSelectionDefaults =>
      const PatchSelectionDefaults(
        usesBankSelect: false,
        verificationStatus: MidiSupportLevel.supported,
      );
}
