import '../midi_support_level.dart';

/// One preset read off a device, decoded as far as whatever
/// [NuxMg30V5PresetTransferService] read it could confirm.
///
/// [confidence] says how much of this to trust: anything short of
/// [MidiSupportLevel.supported] is a best-effort reading, not a guarantee the
/// device actually holds these values - see that class's own documentation
/// for why nothing backed by real hardware exists yet.
class ImportedPreset {
  const ImportedPreset({
    required this.programNumber,
    required this.name,
    required this.confidence,
    this.blocks = const [],
  });

  final int programNumber;
  final String name;
  final MidiSupportLevel confidence;
  final List<ImportedBlock> blocks;
}

/// One block of an [ImportedPreset]'s signal chain.
///
/// [label] names a row of the owning device profile's
/// `blockDefinitions` - the same label a seeded block pedal carries - so the
/// import pipeline can match one to the other by name alone, the same way
/// `MidiDeviceLinkRepository` already does.
class ImportedBlock {
  const ImportedBlock({
    required this.label,
    this.modelNumber,
    this.parameters = const {},
  });

  final String label;

  /// The block's model-select value, or null when the preset did not say.
  final int? modelNumber;

  /// Parameter name (matching a `MidiParameterDefinition.name`) to its value.
  final Map<String, double> parameters;
}
