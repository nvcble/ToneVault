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
