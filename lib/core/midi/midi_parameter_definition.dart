/// How one parameter reaches the device over MIDI, as opposed to a plain
/// on/off toggle or note data.
enum MidiParameterMessageType { controlChange, programChange, none }

/// The MIDI shape of one control: what a device profile has confirmed is
/// sendable, and how to send it.
///
/// Kept apart from `PedalControls`: a `PedalControl` row is what the user has
/// recorded locally about a knob, on any pedal, MIDI or not. A
/// [MidiParameterDefinition] is what one device profile's own MIDI
/// implementation chart says about that knob - the two are linked, not
/// merged, by a `MidiControlMapping` once one exists.
class MidiParameterDefinition {
  const MidiParameterDefinition({
    required this.name,
    required this.min,
    required this.max,
    required this.messageType,
    this.defaultValue,
    this.midiChannel,
    this.ccNumber,
    this.toMidiValue,
    this.fromMidiValue,
  });

  final String name;
  final double min;
  final double max;
  final MidiParameterMessageType messageType;
  final double? defaultValue;
  final int? midiChannel;

  /// Only meaningful when [messageType] is [MidiParameterMessageType.controlChange].
  final int? ccNumber;

  /// Maps an app-domain value onto the 0-127 MIDI range, where that mapping is
  /// not a plain linear scale across [min]..[max]. Null means linear.
  final int Function(double appValue)? toMidiValue;

  final double Function(int midiValue)? fromMidiValue;

  /// The same parameter, sent over a different CC - what a user override
  /// changes and nothing else.
  MidiParameterDefinition withCcNumber(int ccNumber) => MidiParameterDefinition(
    name: name,
    min: min,
    max: max,
    messageType: messageType,
    defaultValue: defaultValue,
    midiChannel: midiChannel,
    ccNumber: ccNumber,
    toMidiValue: toMidiValue,
    fromMidiValue: fromMidiValue,
  );
}
