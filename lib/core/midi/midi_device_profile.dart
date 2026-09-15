import 'midi_block_definition.dart';
import 'midi_feature.dart';
import 'midi_parameter_definition.dart';
import 'midi_support_level.dart';
import 'midi_transport_type.dart';
import 'patch_selection_defaults.dart';

/// What one multi-effects device speaks, isolated from the generic engine.
///
/// The engine and every screen above it read a device only through this
/// contract, so supporting a second device is a second implementation of it
/// rather than a branch inside the engine.
///
/// Everything here is fixed, factory data - a profile holds no user state, so
/// it cannot itself apply a user's CC remapping or decide whether an
/// unverified command should actually be sent. Those live one layer up, in
/// `core/midi/midi_parameter_resolution.dart` and
/// `core/midi/midi_patch_selection.dart`, which read [parameterDefinitions]
/// and [patchSelectionDefaults] as the starting point rather than the answer.
abstract class MidiDeviceProfile {
  const MidiDeviceProfile();

  String get id;
  String get manufacturer;
  String get model;
  String get firmwareVersion;
  String get displayName;

  /// In the order a connection screen should offer them.
  List<MidiTransportType> get connectionTypes;

  /// The channel every message this device sends or receives uses, absent
  /// anything that says otherwise. Not yet something a user can change.
  int get defaultChannel;

  Map<MidiFeature, MidiSupportLevel> get capabilities;

  List<MidiParameterDefinition> get parameterDefinitions;

  /// The blocks of this device's signal chain, in signal-chain order - empty
  /// for a device with no such concept. What lets a generic "add this device
  /// as gear" action seed one child pedal per block with one control per
  /// parameter, without knowing anything about the device itself.
  List<MidiBlockDefinition> get blockDefinitions;

  /// This device's best candidate for loading a patch by number, or null when
  /// there is not even a candidate. See [PatchSelectionDefaults].
  PatchSelectionDefaults? get patchSelectionDefaults;

  MidiSupportLevel supportLevelOf(MidiFeature feature) =>
      capabilities[feature] ?? MidiSupportLevel.unknown;
}
