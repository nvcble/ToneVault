import 'package:tone_vault/core/midi/midi_message.dart';

/// One real "get preset data" reply, captured from a physical NUX MG-30 V5
/// over USB MIDI on 2026-09-15: slot 0, patch name "Core Lead - HH".
///
/// Verbatim wire bytes, deliberately not a hand-built fixture. A synthetic
/// frame can only re-assert the offsets the decoder already assumes, so it
/// cannot catch the failure this frame did: the reply is 222 bytes, the
/// matcher demanded 218, and every read on real hardware timed out with a
/// perfectly good answer sitting in the log.
const capturedNuxMg30V5PresetHex =
    'F0 43 58 70 0B 02 00 00 01 02 41 01 0A 50 00 06 41 01 04 02 00 06 04 01 '
    '02 01 00 00 32 02 00 02 01 22 14 00 00 00 00 06 00 01 24 55 00 00 00 00 '
    '00 08 00 1E 38 00 7C 3B 00 7A 33 00 68 32 00 18 32 00 42 25 00 52 29 00 '
    '5A 37 00 76 37 00 52 21 00 64 02 00 28 33 00 00 00 00 06 20 00 31 56 00 '
    '00 00 00 00 04 00 28 19 00 51 55 00 00 00 00 00 00 00 04 19 00 1E 00 00 '
    '00 06 02 4D 11 00 66 00 01 48 00 00 06 32 00 65 00 00 04 00 01 48 32 00 '
    '00 00 01 44 00 00 0A 00 00 02 02 00 08 0A 00 0C 07 00 10 03 00 12 0B 01 '
    '06 6F 01 64 65 00 40 4C 01 4A 61 01 48 20 00 5A 20 01 10 48 00 00 00 00 '
    '14 08 00 12 01 00 0A 00 01 48 00 01 48 00 00 00 00 01 20 00 00 78 0A 00 '
    '78 0A 00 78 0A F7';

/// The captured frame as a [SysExMessage], with `F0`/`F7` stripped the way the
/// transport hands one to [MidiEngine].
SysExMessage capturedNuxMg30V5Preset() {
  final bytes = [
    for (final part in capturedNuxMg30V5PresetHex.split(' '))
      int.parse(part, radix: 16),
  ];
  return SysExMessage(payload: bytes.sublist(1, bytes.length - 1));
}
