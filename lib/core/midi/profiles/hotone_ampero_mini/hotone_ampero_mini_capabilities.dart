import '../../midi_feature.dart';
import '../../midi_support_level.dart';

/// Capability matrix for the Hotone Ampero Mini (MP-50).
///
/// Unlike `nuxMg30V5Capabilities`, almost nothing here comes from an official
/// chart - Hotone publishes a MIDI Control Information List for the Ampero
/// II, but not for the Mini. What is confirmed comes from ToneVault's own
/// hardware test (2026-09-16): connected over USB, and Program Change on
/// channel 0 changed the loaded patch, watched on the unit itself. Nothing
/// else has been tried yet, so [MidiSupportLevel.unknown] dominates.
const Map<MidiFeature, MidiSupportLevel> hotoneAmperoMiniCapabilities = {
  // Confirmed on real hardware: a plain Program Change, channel 0, no Bank
  // Select, changed the loaded patch - watched on the unit's own screen.
  MidiFeature.patchSelection: MidiSupportLevel.supported,

  // The Ampero Mini is a pure patch-based unit; it has no Pro-Scene-style
  // concept at all. A confirmed product-scope fact, not a research gap.
  MidiFeature.sceneSwitching: MidiSupportLevel.unsupported,

  // No CC list is published for this unit, and none has been captured or
  // tried, so there is nothing to confirm any of these against yet.
  MidiFeature.blockBypass: MidiSupportLevel.unknown,
  MidiFeature.parameterControl: MidiSupportLevel.unknown,
  MidiFeature.effectModelSelection: MidiSupportLevel.unknown,
  MidiFeature.signalChainEditing: MidiSupportLevel.unknown,

  // The device sends unprompted SysEx over the same USB connection (captured
  // 2026-09-16), which proves it speaks SysEx at all, but no request/response
  // pair for reading or writing a full patch has been confirmed yet - the
  // capture so far is entirely the unit talking on its own.
  MidiFeature.patchEditing: MidiSupportLevel.unknown,
  MidiFeature.patchTransfer: MidiSupportLevel.unknown,

  MidiFeature.irManagement: MidiSupportLevel.unknown,
};
