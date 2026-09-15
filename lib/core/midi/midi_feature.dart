/// A capability a multi-effects device might expose over MIDI.
///
/// Every device profile reports one of [MidiSupportLevel] against each of
/// these rather than the app assuming a whole unit works because one command
/// does; see section 24 of the MIDI module brief.
enum MidiFeature {
  patchSelection,
  sceneSwitching,
  blockBypass,
  parameterControl,
  patchEditing,
  effectModelSelection,
  signalChainEditing,
  patchTransfer,
  irManagement;

  String get label => switch (this) {
    MidiFeature.patchSelection => 'Patch selection',
    MidiFeature.sceneSwitching => 'Scene switching',
    MidiFeature.blockBypass => 'Block bypass',
    MidiFeature.parameterControl => 'Parameter control',
    MidiFeature.patchEditing => 'Patch editing',
    MidiFeature.effectModelSelection => 'Effect model selection',
    MidiFeature.signalChainEditing => 'Signal-chain editing',
    MidiFeature.patchTransfer => 'Patch transfer',
    MidiFeature.irManagement => 'IR management',
  };
}
