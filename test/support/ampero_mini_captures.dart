import 'package:tone_vault/core/midi/midi_message.dart';

/// Byte strings copied verbatim from captures taken off the user's own Hotone
/// Ampero Mini, kept in one place so tests assert against real hardware
/// traffic rather than against bytes composed to match the decoder.
///
/// Two ticks, one from each capture: `04 <hi> <lo>` is a 14-bit counter the
/// pedal emits with every status broadcast, so these are 131 and 1.
///
/// The capture of 20:08 ran 130..140 and the capture of 23:17 ran 1..10, the
/// pedal having been restarted in between. They were first read as current-patch
/// broadcasts because the 20:08 capture happened to be ten footswitch presses
/// made about a second apart; the 23:17 capture disproved that, advancing ten
/// times while at most two patches changed.
const String amperoMiniTick0103 =
    'F0 21 25 7F 4D 50 2D 32 12 00 02 06 04 01 03 F7';
const String amperoMiniTick0001 =
    'F0 21 25 7F 4D 50 2D 32 12 00 02 06 04 00 01 F7';

/// The once-a-second status broadcast, and the single outlier payload seen
/// across both captures.
const String amperoMiniStatus =
    'F0 21 25 7F 4D 50 2D 32 12 00 02 06 05 00 00 00 78 F7';
const String amperoMiniStatusOutlier =
    'F0 21 25 7F 4D 50 2D 32 12 00 02 06 05 00 00 01 16 F7';

/// Builds the [SysExMessage] a transport would deliver for [hex], which is
/// written with its 0xF0/0xF7 framing as a capture shows it - `payload` is
/// what sits between them.
SysExMessage amperoMiniSysEx(String hex) {
  final bytes = parseHexBytes(hex);
  return SysExMessage(payload: bytes.sublist(1, bytes.length - 1));
}
