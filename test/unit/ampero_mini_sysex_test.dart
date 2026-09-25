import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/midi_message.dart';
import 'package:tone_vault/features/midi/hotone_ampero_mini/data/ampero_mini_sysex.dart';

import '../support/ampero_mini_captures.dart';

void main() {
  group('decodeAmperoMiniReport', () {
    test('reads the tick as a 14-bit counter, not as a patch index', () {
      // `04 01 03` is 131, the counter's value - reading its last byte as
      // "patch 3" is the misreading this decoder was corrected from.
      final report = decodeAmperoMiniReport(
        amperoMiniSysEx(amperoMiniTick0103),
      );

      expect(report, isA<AmperoMiniTickReport>());
      expect((report! as AmperoMiniTickReport).counter, 131);
    });

    test('a tick with a zero high byte is the same message, low', () {
      // The later capture, taken after the pedal was restarted, ran 1..10.
      final report = decodeAmperoMiniReport(
        amperoMiniSysEx(amperoMiniTick0001),
      );

      expect((report! as AmperoMiniTickReport).counter, 1);
    });

    test(
      'keeps the status broadcast payload verbatim rather than decoding it',
      () {
        final report = decodeAmperoMiniReport(
          amperoMiniSysEx(amperoMiniStatus),
        );

        expect(report, isA<AmperoMiniStatusReport>());
        expect((report! as AmperoMiniStatusReport).payload, [
          0x00,
          0x00,
          0x00,
          0x78,
        ]);
      },
    );

    test('the one status broadcast with a different payload still decodes', () {
      // Observed exactly once across both captures; unexplained, so it must
      // not be mistaken for a patch change or dropped.
      final report = decodeAmperoMiniReport(
        amperoMiniSysEx(amperoMiniStatusOutlier),
      );

      expect((report! as AmperoMiniStatusReport).payload, [
        0x00,
        0x00,
        0x01,
        0x16,
      ]);
    });

    test('another manufacturer\'s SysEx is not ours', () {
      // The Ampero II Stomp envelope: same 21 25 start, no 7F, different body.
      final report = decodeAmperoMiniReport(
        amperoMiniSysEx('F0 21 25 4D 50 00 00 04 01 03 F7'),
      );

      expect(report, isNull);
    });

    test('non-SysEx traffic is ignored', () {
      expect(
        decodeAmperoMiniReport(
          const ProgramChangeMessage(channel: 0, program: 3),
        ),
        isNull,
      );
      expect(
        decodeAmperoMiniReport(
          const ControlChangeMessage(channel: 0, controller: 8, value: 0),
        ),
        isNull,
      );
    });

    test('the counter keeps decoding past its first high byte', () {
      // 0x02 has not been captured yet, but it is where a counter that keeps
      // running goes next, so it must not be treated as a stranger.
      final report = decodeAmperoMiniReport(
        amperoMiniSysEx('F0 21 25 7F 4D 50 2D 32 12 00 02 06 04 02 03 F7'),
      );

      expect((report! as AmperoMiniTickReport).counter, 259);
    });

    test(
      'an unknown message type carrying our prefix is kept, not dropped',
      () {
        final report = decodeAmperoMiniReport(
          amperoMiniSysEx('F0 21 25 7F 4D 50 2D 32 12 00 02 06 7E 11 22 F7'),
        );

        expect(report, isA<AmperoMiniUnrecognizedReport>());
        expect((report! as AmperoMiniUnrecognizedReport).body, [
          0x7E,
          0x11,
          0x22,
        ]);
      },
    );
  });
}
