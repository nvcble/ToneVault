/// Decoding the patch name out of the pedal's reply to request `0D`.
///
/// SOURCE: two probe replies on hardware (P02-1 "D.Classic 90s LD", P03-1
/// "Slick Lead", both matched against Hotone's editor) and the editor capture
/// of 2026-11-10 (`WelcomeToAmpero`). See `docs/ampero_mini_capture_1_findings.md`.
///
/// The reply is a run of `12 00 02 0E` frames. Only the first (chunk 0) is used.
/// After the `0E` byte, 0-based: byte 4 is the chunk counter, bytes 7-8 the slot
/// the data really belongs to (high nibble, low nibble - slot 17 is `01 00`), bytes 11-12 are two UNKNOWN bytes, and from byte
/// 13 the name follows as high-nibble / low-nibble pairs, ended by a `00 00`
/// pair or after 16 characters. Padding was `00` in two samples and spaces in
/// one, so trailing spaces are trimmed.
library;

import 'ampero_mini_read_probe.dart';

const int _headerLength = 7;
const int _bodyStart = _headerLength + 4; // 12 00 02 0E
const int _chunkOffset = 4;
const int _slotOffset = 7; // high nibble; low nibble follows
const int _nameOffset = 13;
const int _maxNameChars = 16;

/// The name in [payload], or null if [payload] is not the first `0E` frame, is
/// for a different [index] than asked for, or does not decode to printable
/// ASCII. A null must never be stored as a name.
String? decodeAmperoMiniPatchName(List<int> payload, {required int index}) {
  if (payload.length < _bodyStart + _nameOffset + 2) return null;
  for (var i = 0; i < _headerLength; i++) {
    if (payload[i] != amperoMiniSysExHeader[i]) return null;
  }
  const lead = [0x12, 0x00, 0x02, 0x0E];
  for (var i = 0; i < lead.length; i++) {
    if (payload[_headerLength + i] != lead[i]) return null;
  }
  if (payload[_bodyStart + _chunkOffset] != 0) return null;
  final slot =
      payload[_bodyStart + _slotOffset] << 4 |
      payload[_bodyStart + _slotOffset + 1];
  if (slot != index) return null;

  final chars = <int>[];
  var at = _bodyStart + _nameOffset;
  while (chars.length < _maxNameChars && at + 1 < payload.length) {
    final hi = payload[at];
    final lo = payload[at + 1];
    if (hi > 0x0F || lo > 0x0F) return null;
    final code = hi << 4 | lo;
    if (code == 0) break;
    if (code < 0x20 || code > 0x7E) return null;
    chars.add(code);
    at += 2;
  }
  final name = String.fromCharCodes(chars).trimRight();
  return name.isEmpty ? null : name;
}
