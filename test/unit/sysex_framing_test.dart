import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/midi_message.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_sysex.dart';
import 'package:tone_vault/core/midi/sysex_framing.dart';

/// A whole 218-byte "get preset data" frame for [programNumber], `F0` and `F7`
/// included - the shape `flutter_midi_command` hands a transport for an
/// incoming SysEx, rather than the payload inside it.
List<int> presetDataFrame(int programNumber) {
  final bytes = List<int>.filled(218, 0);
  bytes[0] = 0xF0;
  bytes[1] = 0x43;
  bytes[2] = 0x58;
  bytes[3] = 0x70;
  bytes[4] = 0x0B;
  bytes[5] = 0x02;
  bytes[6] = programNumber;
  bytes[217] = 0xF7;
  return bytes;
}

void main() {
  test('strips the framing a transport receives around a payload', () {
    expect(sysExPayload([0xF0, 0x43, 0x58, 0x00, 0xF7]), [0x43, 0x58, 0x00]);
  });

  test('leaves an already-stripped payload alone', () {
    expect(sysExPayload([0x43, 0x58, 0x00]), [0x43, 0x58, 0x00]);
  });

  test('strips whichever framing byte is present when the other is not', () {
    expect(sysExPayload([0xF0, 0x43]), [0x43]);
    expect(sysExPayload([0x43, 0xF7]), [0x43]);
  });

  test('handles empty and framing-only input without throwing', () {
    expect(sysExPayload([]), isEmpty);
    expect(sysExPayload([0xF0, 0xF7]), isEmpty);
  });

  /// The regression that made every preset read time out against a device that
  /// had actually answered: the plugin's whole frame was stored as a payload,
  /// which `toBytes` framed a second time into 220 bytes of `F0 F0 ... F7 F7`.
  /// Both of `isPresetDataResponse`'s conditions then failed - the length, and
  /// the byte after `F0` being `0xF0` instead of `0x43`.
  test('a received frame round-trips to the same 218 bytes and is recognised', () {
    final frame = presetDataFrame(21);

    final message = SysExMessage(payload: sysExPayload(frame));

    expect(message.toBytes(), frame);
    expect(message.toBytes(), hasLength(218));
    expect(NuxMg30V5SysEx.isPresetDataResponse(message), isTrue);
    expect(NuxMg30V5SysEx.presetResponseProgramNumber(message), 21);
  });

  test('double-framing a received frame is what the matcher rejects', () {
    // Guards the fix by showing the old behaviour really was unrecognisable,
    // so a transport that forgets to strip cannot pass quietly again.
    final doubleFramed = SysExMessage(payload: presetDataFrame(21));

    expect(doubleFramed.toBytes(), hasLength(220));
    expect(NuxMg30V5SysEx.isPresetDataResponse(doubleFramed), isFalse);
  });
}
