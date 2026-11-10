import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/midi_connection_state.dart';
import 'package:tone_vault/core/midi/midi_engine.dart';
import 'package:tone_vault/core/midi/midi_message.dart';
import 'package:tone_vault/core/midi/profiles/hotone_ampero_mini/hotone_ampero_mini_profile.dart';
import 'package:tone_vault/features/midi/hotone_ampero_mini/data/ampero_mini_read_probe.dart';
import 'package:tone_vault/features/midi/hotone_ampero_mini/data/hotone_ampero_mini_midi_service.dart';

import '../support/fake_midi_transport.dart';

const _head = amperoMiniSysExHeader;

void main() {
  test(
    'the request is the bytes captured from the editor for bank 1, slot 3',
    () {
      final bytes = buildAmperoMiniReadProbe(bank: 1, index: 3).toBytes();
      expect(bytes, [
        0xF0, 0x21, 0x25, 0x7F, 0x4D, 0x50, 0x2D, 0x32, //
        0x11, 0x00, 0x02, 0x08, 0x00, 0x01, 0x03, 0xF7,
      ]);
    },
  );

  test('refuses a slot the editor was never seen to address', () {
    expect(() => buildAmperoMiniReadProbe(bank: 2, index: 0), throwsRangeError);
    expect(
      () => buildAmperoMiniReadProbe(bank: 0, index: 99),
      throwsRangeError,
    );
  });

  test('recognises the captured acknowledgement only for its own slot', () {
    final ack = [
      ..._head,
      0x12,
      0x00,
      0x02,
      0x0C,
      0x00,
      0x01,
      0x03,
      0x07,
      0x18,
      0x01,
      0x40,
    ];
    expect(isAmperoMiniProbeAck(ack, bank: 1, index: 3), isTrue);
    expect(isAmperoMiniProbeAck(ack, bank: 1, index: 4), isFalse);
    expect(isAmperoMiniProbeAck(ack, bank: 0, index: 3), isFalse);
  });

  group('probeRead', () {
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
      'sends once, keeps the reply, drops the broadcast, reports the ack',
      () async {
        final service = HotoneAmperoMiniMidiService(engine);
        final run = service.probeRead(
          bank: 1,
          index: 3,
          listenFor: const Duration(milliseconds: 50),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        transport.receive(
          const SysExMessage(
            payload: [
              0x21,
              0x25,
              0x7F,
              0x4D,
              0x50,
              0x2D,
              0x32,
              0x12,
              0x00,
              0x02,
              0x06,
              0x04,
              0x00,
              0x05,
            ],
          ),
        );
        transport.receive(
          const SysExMessage(
            payload: [
              ..._head,
              0x12,
              0x00,
              0x02,
              0x0C,
              0x00,
              0x01,
              0x03,
              0x07,
              0x18,
              0x01,
              0x40,
            ],
          ),
        );
        final result = await run;

        expect(transport.sent, hasLength(1));
        expect(result.replies, hasLength(1));
        expect(result.acknowledged, isTrue);
      },
    );

    test('the 0D and 0F steps build the captured bytes', () {
      final h = amperoMiniSysExHeader;
      expect(
        buildAmperoMiniReadProbe(
          bank: 1,
          index: 3,
          step: AmperoMiniProbeStep.request0D,
        ).payload,
        [...h, 0x12, 0x00, 0x02, 0x0D, 0x00, 0x01, 0x03, 0x01],
      );
      expect(
        buildAmperoMiniReadProbe(
          bank: 1,
          index: 3,
          step: AmperoMiniProbeStep.request0F,
        ).payload,
        [...h, 0x12, 0x00, 0x02, 0x0F, 0x00, 0x01, 0x03, 0x00, 0x00, 0x01],
      );
    });

    test('a silent pedal gives no replies and no acknowledgement', () async {
      final result = await HotoneAmperoMiniMidiService(engine).probeRead(
        bank: 1,
        index: 3,
        listenFor: const Duration(milliseconds: 20),
      );
      expect(result.replies, isEmpty);
      expect(result.acknowledged, isFalse);
    });
  });
}
