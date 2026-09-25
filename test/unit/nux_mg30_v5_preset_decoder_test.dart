import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/midi_message.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_preset_decoder.dart';

import '../support/captured_nux_mg30_v5_preset.dart';

/// Builds a synthetic 218-byte "get preset data" response, indexed exactly
/// the way `mg30-controller`'s `device.dart` comments describe (`bytes[0]`
/// is the leading `0xF0`), so the fixture below reads the same as the
/// reference project's own offsets rather than a re-translated version of
/// them.
SysExMessage _fixture(void Function(List<int> bytes) configure) {
  final bytes = List<int>.filled(218, 0);
  bytes[0] = 0xF0;
  bytes[217] = 0xF7;
  bytes[1] = 0x43;
  bytes[2] = 0x58;
  bytes[3] = 0x70;
  bytes[4] = 0x0B;
  bytes[5] = 0x02;
  configure(bytes);
  return SysExMessage(payload: bytes.sublist(1, 217));
}

void main() {
  test('decodes program number, name and tempo', () {
    final message = _fixture((bytes) {
      bytes[6] = 5;
      // "AB", packed 2 chars per 3 bytes; a zero third byte ends the name.
      bytes[165] = 0x41; // 'A'
      bytes[166] = 1; // carries +0x40 into the second char
      bytes[167] = 4; // (4 ~/ 2) + 0x40 = 'B'
      bytes[168] = 0;
      bytes[143] = 1;
      bytes[144] = 20; // tempo = 1*64 + 20 = 84
    });

    final decoded = decodeNuxMg30V5Preset(message);

    expect(decoded.programNumber, 5);
    expect(decoded.name, 'AB');
    expect(decoded.tempoBpm, 84);
  });

  test(
    'decodes per-scene bypass for two blocks sharing the same scene bytes',
    () {
      final message = _fixture((bytes) {
        bytes[8] = 7; // Wah model code
        bytes[9] = 3; // Compressor model code
        // Wah mask=2, Compressor mask=4, both sceneByteOffset=1 -> bytes 209/212/215.
        bytes[209] = 6; // scene 1: both on (2|4)
        bytes[212] = 0; // scene 2: both off
        bytes[215] = 6; // scene 3: both on
      });

      final decoded = decodeNuxMg30V5Preset(message);
      final wah = decoded.blocks.firstWhere((b) => b.label == 'Wah');
      final compressor = decoded.blocks.firstWhere(
        (b) => b.label == 'Compressor',
      );

      expect(wah.modelCode, 7);
      expect(wah.bypassPerScene, [true, false, true]);
      expect(compressor.modelCode, 3);
      expect(compressor.bypassPerScene, [true, false, true]);
    },
  );

  test('decodes signal chain order as block labels', () {
    final message = _fixture((bytes) {
      bytes[147] = 0;
      bytes[149] = 2; // halved -> 1
      bytes[150] = 2;
      bytes[152] = 6; // halved -> 3
      bytes[153] = 4;
      bytes[155] = 10; // halved -> 5
      bytes[156] = 6;
      bytes[158] = 14; // halved -> 7
      bytes[159] = 8;
      bytes[161] = 18; // halved -> 9
      bytes[162] = 10;
      bytes[164] = 22; // halved -> 11
    });

    final decoded = decodeNuxMg30V5Preset(message);

    expect(decoded.signalChainOrder, [
      'Wah',
      'Compressor',
      'Effect',
      'Amp',
      'EQ',
      'Noise Gate',
      'Modulation',
      'Delay',
      'Reverb',
      'IR',
      'Send/Return',
      'Volume',
    ]);
  });

  test(
    'Delay is parallel if either the MOD/DLY bit or the DLY/RVB bit is set',
    () {
      final modDlyOnly = decodeNuxMg30V5Preset(
        _fixture((bytes) => bytes[146] = 2),
      );
      final dlyRvbOnly = decodeNuxMg30V5Preset(
        _fixture((bytes) => bytes[146] = 4),
      );
      final neither = decodeNuxMg30V5Preset(_fixture((bytes) {}));

      bool? parallelOf(DecodedNuxMg30V5Preset preset, String label) =>
          preset.blocks.firstWhere((b) => b.label == label).isParallel;

      expect(parallelOf(modDlyOnly, 'Modulation'), isTrue);
      expect(parallelOf(modDlyOnly, 'Delay'), isTrue);
      expect(parallelOf(modDlyOnly, 'Reverb'), isFalse);

      expect(parallelOf(dlyRvbOnly, 'Delay'), isTrue);
      expect(parallelOf(dlyRvbOnly, 'Reverb'), isTrue);
      expect(parallelOf(dlyRvbOnly, 'Modulation'), isFalse);

      expect(parallelOf(neither, 'Modulation'), isFalse);
      expect(parallelOf(neither, 'Delay'), isFalse);
      expect(parallelOf(neither, 'Reverb'), isFalse);
    },
  );

  test('always reports unsupported fields - no dump is fully decoded', () {
    final decoded = decodeNuxMg30V5Preset(_fixture((bytes) {}));

    expect(decoded.unsupportedFields, isNotEmpty);
  });

  test('rejects a response whose length matches no known dump layout', () {
    const shortMessage = SysExMessage(payload: [0x43, 0x58]);

    expect(() => decodeNuxMg30V5Preset(shortMessage), throwsArgumentError);
  });

  group('a real 222-byte dump off the physical MG-30 V5', () {
    test('decodes the slot number and the patch name the unit displays', () {
      final decoded = decodeNuxMg30V5Preset(capturedNuxMg30V5Preset());

      expect(decoded.programNumber, 0);
      // The unit really does store the " - HH" suffix: all five captured
      // presets carry it, so it is name data and not an over-read.
      expect(decoded.name, 'Core Lead - HH');
    });

    test(
      'reports the v4.0.3-only fields as unsupported instead of guessing',
      () {
        // These decode at offsets confirmed on firmware v4.0.3 alone, and no
        // shift of them holds on V5 - a plausible-looking wrong tempo or chain
        // order is worse than an honest gap.
        final decoded = decodeNuxMg30V5Preset(capturedNuxMg30V5Preset());

        expect(decoded.tempoBpm, isNull);
        expect(decoded.signalChainOrder, isEmpty);
        expect(decoded.blocks, isEmpty);
        expect(decoded.unsupportedFields, contains('tempo'));
        expect(decoded.unsupportedFields, contains('signal chain order'));
      },
    );
  });
}
