import 'dart:typed_data';

/// One MIDI message, decoded far enough to send or log - never a
/// device-specific shape. A device's own meaning for a message (which
/// control a CC maps to, which patch a Program Change selects) is read
/// through `MidiDeviceProfile` instead.
sealed class MidiMessage {
  const MidiMessage();

  /// The raw bytes this message puts on the wire.
  Uint8List toBytes();
}

class ProgramChangeMessage extends MidiMessage {
  const ProgramChangeMessage({required this.channel, required this.program});

  final int channel;
  final int program;

  @override
  Uint8List toBytes() =>
      Uint8List.fromList([0xC0 | (channel & 0x0F), program & 0x7F]);

  @override
  String toString() => 'ProgramChange(channel: $channel, program: $program)';
}

class ControlChangeMessage extends MidiMessage {
  const ControlChangeMessage({
    required this.channel,
    required this.controller,
    required this.value,
  });

  final int channel;
  final int controller;
  final int value;

  @override
  Uint8List toBytes() => Uint8List.fromList([
    0xB0 | (channel & 0x0F),
    controller & 0x7F,
    value & 0x7F,
  ]);

  @override
  String toString() =>
      'ControlChange(channel: $channel, cc: $controller, value: $value)';
}

class NoteMessage extends MidiMessage {
  const NoteMessage({
    required this.channel,
    required this.note,
    required this.velocity,
    required this.isNoteOn,
  });

  final int channel;
  final int note;
  final int velocity;
  final bool isNoteOn;

  @override
  Uint8List toBytes() => Uint8List.fromList([
    (isNoteOn ? 0x90 : 0x80) | (channel & 0x0F),
    note & 0x7F,
    velocity & 0x7F,
  ]);

  @override
  String toString() =>
      '${isNoteOn ? 'NoteOn' : 'NoteOff'}'
      '(channel: $channel, note: $note, velocity: $velocity)';
}

class SysExMessage extends MidiMessage {
  const SysExMessage({required this.payload});

  /// The bytes between the 0xF0 start byte and the 0xF7 end byte.
  final List<int> payload;

  @override
  Uint8List toBytes() => Uint8List.fromList([0xF0, ...payload, 0xF7]);

  @override
  String toString() => 'SysEx(${payload.length} bytes)';
}

/// A message a transport received but this app has no typed shape for -
/// pitch bend, aftertouch, clock, NRPN/RPN, or anything else outside the
/// cases above.
///
/// Exists so a diagnostic capture never silently drops bytes a real device
/// sends just because nothing here knows what they mean yet: [raw] is exactly
/// what came off the wire.
class UnknownMessage extends MidiMessage {
  const UnknownMessage({required this.raw});

  final List<int> raw;

  @override
  Uint8List toBytes() => Uint8List.fromList(raw);

  @override
  String toString() => 'Unknown(${raw.length} bytes)';
}

/// A short, human name for [message]'s type, for the MIDI Monitor's columns -
/// never something a user picks apart programmatically, so it stays a plain
/// string rather than another enum.
String midiMessageTypeLabel(MidiMessage message) => switch (message) {
  ProgramChangeMessage() => 'Program Change',
  ControlChangeMessage() => 'Control Change',
  NoteMessage(isNoteOn: true) => 'Note On',
  NoteMessage(isNoteOn: false) => 'Note Off',
  SysExMessage() => 'SysEx',
  UnknownMessage() => 'Unknown',
};

/// The MIDI channel [message] carries, or null for message shapes with no
/// channel of their own - [SysExMessage] and [UnknownMessage].
int? midiMessageChannel(MidiMessage message) => switch (message) {
  ProgramChangeMessage(channel: final channel) => channel,
  ControlChangeMessage(channel: final channel) => channel,
  NoteMessage(channel: final channel) => channel,
  SysExMessage() => null,
  UnknownMessage() => null,
};

/// [bytes] as space-separated, upper-case hex pairs - e.g. "F0 43 10 F7" -
/// the shape a MIDI capture or a hardware spec is read in, so the Monitor and
/// any exported capture show the same thing someone would see in a spec sheet.
String hexBytes(List<int> bytes) =>
    bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');

/// Parses a hex string such as "F0 43 10 F7" (whitespace between pairs
/// optional, case-insensitive) back into bytes, for the diagnostic raw SysEx
/// sender - a user typing in a candidate command, not this app generating
/// one. Throws [FormatException] on anything that is not a whole number of
/// hex digit pairs.
List<int> parseHexBytes(String text) {
  final cleaned = text.replaceAll(RegExp(r'\s+'), '');
  if (cleaned.isEmpty) {
    throw const FormatException('Enter at least one byte.');
  }
  if (cleaned.length.isOdd || !RegExp(r'^[0-9a-fA-F]+$').hasMatch(cleaned)) {
    throw const FormatException('Bytes must be hex pairs, e.g. "F0 43 10 F7".');
  }
  return [
    for (var i = 0; i < cleaned.length; i += 2) int.parse(cleaned.substring(i, i + 2), radix: 16),
  ];
}
