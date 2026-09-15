import '../../midi_feature.dart';
import '../../midi_support_level.dart';

/// Capability matrix for the NUX MG-30 (V5), read off the unit's own V5 MIDI
/// implementation chart and its QuickTone Custom MIDI screen (86 confirmed CC
/// rows between them). Each entry below cites what those sources do and do
/// not say, per the SUPPORTED / PARTIALLY SUPPORTED / NEEDS HARDWARE
/// VERIFICATION / UNSUPPORTED breakdown the MIDI module brief requires.
const Map<MidiFeature, MidiSupportLevel> nuxMg30V5Capabilities = {
  // Neither the V5 chart nor the QuickTone Custom MIDI screen has a row for
  // changing which patch is loaded. `NuxMg30V5Profile.patchSelectionDefaults`
  // now carries a plain-Program-Change candidate corroborated by the GPL-3.0
  // `mg30-controller` reference project (confirmed only on its own firmware,
  // v4.0.3) rather than either confirmed V5 source. Whether V5 answers to
  // Program Change the same way - and whether `PC 0` really is "01A" on this
  // specific unit - has not been tried against real hardware.
  MidiFeature.patchSelection: MidiSupportLevel.needsHardwareVerification,

  // CC 80 ("Scene") is a real, named row in both confirmed sources, so scene
  // switching over MIDI is real. What is not stated is the value each of the
  // three Pro Scenes expects - the app assumes scene 1/2/3 map to 0/1/2,
  // which is unverified against hardware.
  MidiFeature.sceneSwitching: MidiSupportLevel.partiallySupported,

  // Every block's type-select CC has a documented range of 1..N, not 0..N, so
  // the chart does not itself say that 0 bypasses the block - only that 1..N
  // picks a model. Switching models is confirmed; an independent on/off is
  // not.
  MidiFeature.blockBypass: MidiSupportLevel.partiallySupported,

  // All 60 knob CCs and their exact ranges (including the four that are not
  // 0-100) are named rows in the chart.
  MidiFeature.parameterControl: MidiSupportLevel.supported,

  // Editing the blocks and knobs of whichever patch is currently loaded is
  // exactly what the CCs above do. Writing that edit back into a saved patch
  // slot is a different question - see patchTransfer.
  MidiFeature.patchEditing: MidiSupportLevel.supported,

  // Every block's type-select CC picks one of its documented model count.
  MidiFeature.effectModelSelection: MidiSupportLevel.supported,

  // No CC in the chart addresses the order of the eleven blocks, only their
  // models and parameters. An 86-row chart this granular (down to knobs with a
  // 0-6 or 0-2 range) not mentioning chain order is treated as it having none,
  // not as an oversight.
  MidiFeature.signalChainEditing: MidiSupportLevel.unsupported,

  // Reading works: `NuxMg30V5SysEx.getPresetDataRequest` has been verified
  // against a physical V5, which answers with the slot's full dump. Only the
  // slot number and patch name decode reliably out of it so far, and writing a
  // patch back is still undocumented and deliberately unimplemented - so this
  // is partial, not supported.
  MidiFeature.patchTransfer: MidiSupportLevel.partiallySupported,

  // IR CC 9 selects one of 25 factory slots, which the chart confirms.
  // Managing IR files themselves - loading a user's own impulse response -
  // is not something a CC number can do and is not mentioned here.
  MidiFeature.irManagement: MidiSupportLevel.partiallySupported,
};
