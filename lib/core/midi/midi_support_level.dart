/// How confidently a device profile can back one [MidiFeature].
///
/// [unknown] is the default for anything not yet checked against the
/// device's own MIDI implementation chart - deliberately distinct from
/// [unsupported], which is itself a claim that needs the chart to back it up.
/// A profile should only move a feature to [unsupported] once the chart
/// confirms there is no command for it, not merely because nobody has looked
/// yet.
///
/// [needsHardwareVerification] is stronger than [unknown] but short of
/// [partiallySupported]: there is a specific, plausible command in place -
/// built from general MIDI convention or outside research rather than the
/// device's own chart - that has not been tried against real hardware. Unlike
/// [unknown], there is something here to test; unlike [partiallySupported],
/// nothing about it has been confirmed to work yet.
enum MidiSupportLevel {
  supported,
  partiallySupported,
  needsHardwareVerification,
  unsupported,
  unknown;

  String get label => switch (this) {
    MidiSupportLevel.supported => 'Supported',
    MidiSupportLevel.partiallySupported => 'Partially supported',
    MidiSupportLevel.needsHardwareVerification => 'Needs hardware verification',
    MidiSupportLevel.unsupported => 'Not supported',
    MidiSupportLevel.unknown => 'Not yet confirmed',
  };
}
