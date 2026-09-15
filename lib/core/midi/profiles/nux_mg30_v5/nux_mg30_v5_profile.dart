import '../../midi_block_definition.dart';
import '../../midi_device_profile.dart';
import '../../midi_feature.dart';
import '../../midi_parameter_definition.dart';
import '../../midi_support_level.dart';
import '../../midi_transport_type.dart';
import '../../patch_selection_defaults.dart';
import 'nux_mg30_v5_capabilities.dart';
import 'nux_mg30_v5_parameters.dart';

/// The original NUX MG-30 running firmware V5 - not the Gen2 unit, which
/// speaks a different protocol and is out of scope here.
///
/// Built from the unit's own V5 MIDI implementation chart (86 Control Change
/// rows) plus the QuickTone Custom MIDI screen, which confirmed Patch Min,
/// Patch Max, Patch Volume, Current Block, Pedal and Scene as configurable CC
/// mappings - see [nuxMg30V5Parameters]. Selecting a patch by number is not in
/// either source; [patchSelectionDefaults] carries the best outside candidate
/// for it, marked [MidiSupportLevel.needsHardwareVerification] rather than
/// confirmed. No SysEx message is documented anywhere, so none is offered.
///
/// See [nuxMg30V5Capabilities] for exactly what is and is not confirmed.
class NuxMg30V5Profile extends MidiDeviceProfile {
  const NuxMg30V5Profile();

  @override
  String get id => 'nux_mg30_v5';

  @override
  String get manufacturer => 'NUX';

  @override
  String get model => 'MG-30';

  @override
  String get firmwareVersion => 'V5';

  @override
  String get displayName => 'NUX MG-30 (V5)';

  @override
  List<MidiTransportType> get connectionTypes => const [MidiTransportType.usb];

  /// The chart names no MIDI channel; this is the device's factory default
  /// and may not match a unit whose channel has been changed in its own
  /// settings. Not yet exposed as something the user can override.
  @override
  int get defaultChannel => 0;

  @override
  Map<MidiFeature, MidiSupportLevel> get capabilities => nuxMg30V5Capabilities;

  @override
  List<MidiParameterDefinition> get parameterDefinitions => nuxMg30V5Parameters;

  @override
  List<MidiBlockDefinition> get blockDefinitions => nuxMg30V5BlockDefinitions;

  /// Bank Select MSB (CC 0) set to 0, then a plain Program Change - a
  /// candidate from general MIDI convention and outside research, not from
  /// either confirmed MG-30 source. Untested against hardware: see
  /// [MidiSupportLevel.needsHardwareVerification].
  @override
  PatchSelectionDefaults get patchSelectionDefaults => const PatchSelectionDefaults(
    usesBankSelect: true,
    bankSelectMsb: 0,
    verificationStatus: MidiSupportLevel.needsHardwareVerification,
  );
}
