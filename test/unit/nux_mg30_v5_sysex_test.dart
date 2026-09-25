import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/midi_message.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_sysex.dart';

import '../support/captured_nux_mg30_v5_preset.dart';

void main() {
  test('identifyRequest matches the reference project\'s exact bytes', () {
    expect(NuxMg30V5SysEx.identifyRequest().toBytes(), [
      0xF0,
      0x43,
      0x58,
      0x00,
      0xF7,
    ]);
  });

  test(
    'getCurrentProgramNumberRequest matches the reference project\'s exact bytes',
    () {
      expect(NuxMg30V5SysEx.getCurrentProgramNumberRequest().toBytes(), [
        0xF0,
        0x43,
        0x58,
        0x70,
        0x15,
        0x00,
        0xF7,
      ]);
    },
  );

  test(
    'getPresetDataRequest fills in the program number and pads to 15 bytes',
    () {
      expect(NuxMg30V5SysEx.getPresetDataRequest(21).toBytes(), [
        0xF0,
        0x43,
        0x58,
        0x70,
        0x0B,
        0x00,
        21,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0xF7,
      ]);
    },
  );

  test('accepts the 222-byte reply a real MG-30 V5 actually sends', () {
    // The regression that made every hardware read fail: this frame arrived
    // ~130 ms after the request, was rejected for being 4 bytes longer than
    // v4.0.3's dump, and the read then sat out its full 5-second timeout.
    final response = capturedNuxMg30V5Preset();

    expect(response.toBytes(), hasLength(222));
    expect(NuxMg30V5SysEx.isPresetDataResponse(response), isTrue);
    expect(NuxMg30V5SysEx.presetResponseProgramNumber(response), 0);
  });

  test(
    'isPresetDataResponse requires both the exact header and a known dump length',
    () {
      final bytes = List<int>.filled(218, 0);
      bytes[0] = 0xF0;
      bytes[217] = 0xF7;
      bytes[1] = 0x43;
      bytes[2] = 0x58;
      bytes[3] = 0x70;
      bytes[4] = 0x0B;
      bytes[5] = 0x02;
      bytes[6] = 21;
      final response = SysExMessage(payload: bytes.sublist(1, 217));

      expect(NuxMg30V5SysEx.isPresetDataResponse(response), isTrue);
      expect(NuxMg30V5SysEx.isCurrentEffectStateResponse(response), isFalse);
      expect(NuxMg30V5SysEx.presetResponseProgramNumber(response), 21);
    },
  );

  test(
    'isPresetDataResponse is false for a same-header response of the wrong length',
    () {
      const shortResponse = SysExMessage(
        payload: [0x43, 0x58, 0x70, 0x0B, 0x02],
      );

      expect(NuxMg30V5SysEx.isPresetDataResponse(shortResponse), isFalse);
    },
  );

  test(
    'isIdentifyResponse reads the ASCII firmware string out of the reply',
    () {
      final bytes = List<int>.filled(45, 0);
      bytes[0] = 0xF0;
      bytes[44] = 0xF7;
      bytes[1] = 0x43;
      bytes[2] = 0x58;
      bytes[3] = 0x10;
      bytes.setRange(4, 10, 'v4.0.3'.codeUnits);
      final response = SysExMessage(payload: bytes.sublist(1, 44));

      expect(NuxMg30V5SysEx.isIdentifyResponse(response), isTrue);
      expect(NuxMg30V5SysEx.identifyFirmwareVersion(response), 'v4.0.3');
    },
  );
}
