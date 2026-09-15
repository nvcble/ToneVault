import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/midi_message.dart';

void main() {
  group('ProgramChangeMessage', () {
    test('encodes channel and program into two bytes', () {
      const message = ProgramChangeMessage(channel: 0, program: 5);

      expect(message.toBytes(), [0xC0, 5]);
    });

    test('folds the channel into the low nibble of the status byte', () {
      const message = ProgramChangeMessage(channel: 3, program: 12);

      expect(message.toBytes(), [0xC3, 12]);
    });
  });

  group('ControlChangeMessage', () {
    test('encodes controller and value into three bytes', () {
      const message = ControlChangeMessage(channel: 0, controller: 21, value: 127);

      expect(message.toBytes(), [0xB0, 21, 127]);
    });
  });

  group('NoteMessage', () {
    test('uses the note-on status byte when isNoteOn is true', () {
      const message = NoteMessage(channel: 0, note: 60, velocity: 100, isNoteOn: true);

      expect(message.toBytes(), [0x90, 60, 100]);
    });

    test('uses the note-off status byte when isNoteOn is false', () {
      const message = NoteMessage(channel: 0, note: 60, velocity: 0, isNoteOn: false);

      expect(message.toBytes(), [0x80, 60, 0]);
    });
  });

  group('SysExMessage', () {
    test('frames the payload with the start and end bytes', () {
      const message = SysExMessage(payload: [0x43, 0x10]);

      expect(message.toBytes(), [0xF0, 0x43, 0x10, 0xF7]);
    });
  });

  group('UnknownMessage', () {
    test('returns the raw bytes unchanged, for whatever this app cannot decode', () {
      const message = UnknownMessage(raw: [0xE0, 0x00, 0x40]);

      expect(message.toBytes(), [0xE0, 0x00, 0x40]);
    });
  });
}
