/// One read-only request, copied from what Hotone's own editor sends.
///
/// SOURCE: USB captures of Ampero Editor 1.6.0 on 2026-11-10 (see
/// `docs/ampero_mini_capture_1_findings.md`). While connecting, the editor
/// sends `11 00 02 08 00 <bank> <index>` once per slot, for all 198, and the
/// pedal answers each with `12 00 02 0C 00 <bank> <index> 07 18 01 40`.
///
/// What is NOT known: whether this message does anything beyond provoking that
/// acknowledgement, whether it is the request that makes the pedal send patch
/// data, and what the acknowledgement's last four bytes mean. This probe sends
/// the one message and shows exactly what comes back; it does not interpret
/// it, and nothing here may be presented as a working patch read.
library;

import '../../../../core/midi/midi_message.dart';

/// The bytes between F0 and the command byte, identical in every captured
/// message in both directions.
const List<int> amperoMiniSysExHeader = [
  0x21,
  0x25,
  0x7F,
  0x4D,
  0x50,
  0x2D,
  0x32,
];

/// The command byte of the request the editor sends (the pedal's replies use
/// 0x12).
const int _requestCommand = 0x11;
const int _replyCommand = 0x12;

/// The two banks seen in the captures: 0 held the factory half, 1 the user
/// half. Both OBSERVED, the meaning of 0/1 is inferred from the editor's own
/// Bank Select values when it selects F01-1 and P02-1.
const int amperoMiniProbeBankCount = 2;
const int amperoMiniProbeSlotsPerBank = 99;

/// The request for [bank] / [index]. Throws [RangeError] outside the 2 x 99
/// slots the editor was seen to address.
SysExMessage buildAmperoMiniReadProbe({required int bank, required int index}) {
  RangeError.checkValueInInterval(
    bank,
    0,
    amperoMiniProbeBankCount - 1,
    'bank',
  );
  RangeError.checkValueInInterval(
    index,
    0,
    amperoMiniProbeSlotsPerBank - 1,
    'index',
  );
  return SysExMessage(
    payload: [
      ...amperoMiniSysExHeader,
      _requestCommand,
      0x00,
      0x02,
      0x08,
      0x00,
      bank,
      index,
    ],
  );
}

/// True when [payload] is the acknowledgement the editor's request drew in the
/// captures: `12 00 02 0C 00 <bank> <index> ...` after the header.
bool isAmperoMiniProbeAck(List<int> payload, {int? bank, int? index}) {
  const prefixLength = 7;
  if (payload.length < prefixLength + 7) return false;
  for (var i = 0; i < prefixLength; i++) {
    if (payload[i] != amperoMiniSysExHeader[i]) return false;
  }
  final body = payload.sublist(prefixLength);
  final matches =
      body[0] == _replyCommand &&
      body[1] == 0x00 &&
      body[2] == 0x02 &&
      body[3] == 0x0C &&
      body[4] == 0x00;
  if (!matches) return false;
  return (bank == null || body[5] == bank) &&
      (index == null || body[6] == index);
}

/// What one probe run saw. [replies] is every SysEx that carried the Ampero
/// header during the listening window, in arrival order, payload bytes only.
class AmperoMiniReadProbeResult {
  const AmperoMiniReadProbeResult({
    required this.sent,
    required this.replies,
    required this.acknowledged,
  });

  final List<int> sent;
  final List<List<int>> replies;

  /// Whether one of [replies] matched the acknowledgement seen in the
  /// captures, for the same bank and index. Nothing more is implied.
  final bool acknowledged;
}
