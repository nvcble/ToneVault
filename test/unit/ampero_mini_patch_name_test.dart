import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/midi_connection_state.dart';
import 'package:tone_vault/core/midi/midi_engine.dart';
import 'package:tone_vault/core/midi/midi_message.dart';
import 'package:tone_vault/core/midi/profiles/hotone_ampero_mini/hotone_ampero_mini_profile.dart';
import 'package:tone_vault/features/midi/hotone_ampero_mini/data/ampero_mini_patch_name.dart';
import 'package:tone_vault/features/midi/hotone_ampero_mini/data/ampero_mini_patch_reader.dart';
import 'package:tone_vault/features/midi/hotone_ampero_mini/data/ampero_mini_read_probe.dart';

import '../support/fake_midi_transport.dart';

const _head = amperoMiniSysExHeader;

/// Nibble pairs for [text], then the `00 00` terminator.
List<int> _pairs(String text) => [
  for (final c in text.codeUnits) ...[c >> 4, c & 0xF],
  0,
  0,
];

/// First `0E` chunk for [slot]: 4 lead bytes, body bytes 0-12, then the name.
List<int> _frame(int slot, List<int> name, {int chunk = 0}) => [
  ..._head,
  0x12,
  0x00,
  0x02,
  0x0E,
  0x00,
  0x01,
  0x00,
  0x00,
  chunk,
  0x00,
  0x01,
  slot >> 4,
  slot & 0xF,
  0x00,
  0x00,
  0x06,
  0x03,
  ...name,
  ...List.filled(40, 0),
];

void main() {
  group('decodeAmperoMiniPatchName', () {
    test('decodes the editor-captured WelcomeToAmpero (space padded)', () {
      // From p02-1_read.pcapng frame 1708: pairs after the 13 body bytes.
      final name = [
        0x05, 0x07, 0x06, 0x05, 0x06, 0x0c, 0x06, 0x03, 0x06, 0x0f, 0x06, 0x0d,
        0x06, 0x05, 0x05, 0x04, 0x06, 0x0f, 0x04, 0x01, 0x06, 0x0d, 0x07, 0x00,
        0x06, 0x05, 0x07, 0x02, 0x06, 0x0f, 0x02, 0x00, //
      ];
      expect(
        decodeAmperoMiniPatchName(_frame(0, name), index: 0),
        'WelcomeToAmpero',
      );
    });

    test('decodes slot 17 (index 16), whose slot byte is a nibble pair', () {
      // Real reply from the pedal, 2026-11-10 hardware run: slot byte 7-8 = 01 00.
      const hex =
          '21 25 7f 4d 50 2d 32 12 00 02 0e 00 01 10 00 00 00 01 01 00 00 01 '
          '03 02 04 02 06 05 06 05 06 06 07 09 02 00 04 04 06 09 07 02 07 04 '
          '00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 '
          '00 00 00 00 00 01';
      final frame = [for (final b in hex.split(' ')) int.parse(b, radix: 16)];
      expect(decodeAmperoMiniPatchName(frame, index: 16), 'Beefy Dirt');
      expect(decodeAmperoMiniPatchName(frame, index: 0), isNull);
    });

    test('decodes a zero-padded name', () {
      expect(
        decodeAmperoMiniPatchName(_frame(6, _pairs('Slick Lead')), index: 6),
        'Slick Lead',
      );
    });

    test('refuses a reply for another slot (08/0D mismatch)', () {
      final f = _frame(3, _pairs('D.Classic 90s LD'));
      expect(decodeAmperoMiniPatchName(f, index: 6), isNull);
    });

    test('refuses later chunks, empty names and non-printable bytes', () {
      expect(
        decodeAmperoMiniPatchName(_frame(3, _pairs('X'), chunk: 1), index: 3),
        isNull,
      );
      expect(decodeAmperoMiniPatchName(_frame(3, [0, 0]), index: 3), isNull);
      expect(
        decodeAmperoMiniPatchName(_frame(3, [0, 1, 0, 0]), index: 3),
        isNull,
      );
      expect(decodeAmperoMiniPatchName(_head, index: 3), isNull);
    });
  });

  group('AmperoMiniPatchReader', () {
    late FakeMidiTransport transport;
    late MidiEngine engine;

    setUp(() {
      transport = FakeMidiTransport();
      engine = MidiEngine()
        ..attach(
          profile: const HotoneAmperoMiniProfile(),
          transportBuilder: () => transport,
        );
      transport.setState(MidiConnectionState.connected);
    });

    tearDown(() => engine.dispose());

    test(
      'sends 08, waits for the ack, then 0D, and returns the name',
      () async {
        final reader = AmperoMiniPatchReader(
          engine,
          timeout: const Duration(milliseconds: 200),
        );
        final run = reader.readName(6);
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(transport.sent, hasLength(1));
        transport.receive(
          SysExMessage(
            payload: [..._head, 0x12, 0, 2, 0x0C, 0, 1, 6, 7, 0x18, 1, 0x40],
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(transport.sent, hasLength(2));
        transport.receive(
          SysExMessage(payload: _frame(6, _pairs('Slick Lead'))),
        );
        expect((await run).name, 'Slick Lead');
      },
    );

    test(
      'a factory patch is asked for in bank 0 with its in-bank slot',
      () async {
        final reader = AmperoMiniPatchReader(
          engine,
          timeout: const Duration(milliseconds: 200),
        );
        final run = reader.readName(105); // F03-1 = bank 0, slot 6
        await Future<void>.delayed(const Duration(milliseconds: 10));
        // 11 00 02 08 00 <bank> <slot>
        expect((transport.sent.single as SysExMessage).payload.sublist(7), [
          0x11, 0, 2, 0x08, 0, 0, 6, //
        ]);
        transport.receive(
          SysExMessage(
            payload: [..._head, 0x12, 0, 2, 0x0C, 0, 0, 6, 7, 0x18, 1, 0x40],
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        transport.receive(
          SysExMessage(payload: _frame(6, _pairs('Slick Lead'))),
        );
        expect((await run).name, 'Slick Lead');
      },
    );

    test('a silent pedal stops the read with a failure', () async {
      final reader = AmperoMiniPatchReader(
        engine,
        timeout: const Duration(milliseconds: 30),
      );
      await expectLater(
        reader.readName(0),
        throwsA(isA<AmperoMiniReadFailure>()),
      );
      expect(transport.sent, hasLength(1));
    });
  });
}
