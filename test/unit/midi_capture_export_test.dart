import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/midi_log_entry.dart';
import 'package:tone_vault/core/midi/midi_message.dart';
import 'package:tone_vault/features/midi/data/midi_capture_export.dart';

void main() {
  final entries = [
    MidiLogEntry(
      direction: MidiDirection.outgoing,
      message: const SysExMessage(payload: [0x43, 0x10]),
      timestamp: DateTime.utc(2026, 1, 1, 11, 31, 2),
    ),
    MidiLogEntry(
      direction: MidiDirection.incoming,
      message: const ControlChangeMessage(channel: 0, controller: 80, value: 1),
      timestamp: DateTime.utc(2026, 1, 1, 11, 31, 3),
    ),
  ];

  test('encodeCaptureAsJson keeps direction, type and exact bytes per entry', () {
    final json = encodeCaptureAsJson(entries);

    expect(json, contains('"direction": "outgoing"'));
    expect(json, contains('"bytes": "F0 43 10 F7"'));
    expect(json, contains('"type": "Control Change"'));
  });

  test('encodeCaptureAsText reads TX/RX with the same hex bytes as the Monitor', () {
    final text = encodeCaptureAsText(entries);

    expect(text, contains('TX  SysEx  F0 43 10 F7'));
    expect(text, contains('RX  Control Change  B0 50 01'));
  });

  test('carries the reason a send was refused into both readable formats', () {
    // Without this, an exported capture of a failing run is indistinguishable
    // from one where the app never transmitted at all.
    final refused = [
      MidiLogEntry(
        direction: MidiDirection.outgoing,
        message: const SysExMessage(payload: [0x43, 0x10]),
        timestamp: DateTime.utc(2026, 1, 1, 11, 31, 2),
        failure: 'Bad state: Cannot send a MIDI message while disconnected.',
      ),
    ];

    expect(encodeCaptureAsJson(refused), contains('"failure": "Bad state: Cannot send'));
    expect(encodeCaptureAsText(refused), contains('NOT SENT: Bad state: Cannot send'));
    // The frame never left, but it is still what was attempted.
    expect(encodeCaptureAsSyx(refused), [0xF0, 0x43, 0x10, 0xF7]);
  });

  test('leaves the failure key out entirely for a send that worked', () {
    expect(encodeCaptureAsJson(entries), isNot(contains('"failure"')));
    expect(encodeCaptureAsText(entries), isNot(contains('NOT SENT')));
  });

  test('encodeCaptureAsSyx keeps SysEx frames only, in capture order', () {
    final bytes = encodeCaptureAsSyx(entries);

    // The Control Change entry is left out: a .syx file with C0/B0 bytes
    // between frames is not readable by any SysEx tool.
    expect(bytes, [0xF0, 0x43, 0x10, 0xF7]);
  });

  group('parseHexBytes', () {
    test('parses space-separated hex pairs', () {
      expect(parseHexBytes('F0 43 10 F7'), [0xF0, 0x43, 0x10, 0xF7]);
    });

    test('accepts hex with no separators at all', () {
      expect(parseHexBytes('F04310F7'), [0xF0, 0x43, 0x10, 0xF7]);
    });

    test('rejects an odd number of hex digits', () {
      expect(() => parseHexBytes('F0 4'), throwsFormatException);
    });

    test('rejects non-hex characters', () {
      expect(() => parseHexBytes('ZZ'), throwsFormatException);
    });

    test('rejects an empty string', () {
      expect(() => parseHexBytes(''), throwsFormatException);
    });
  });
}
