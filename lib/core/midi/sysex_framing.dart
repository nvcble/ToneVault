/// The bytes *between* a SysEx frame's `F0` start and `F7` end bytes, which is
/// what `SysExMessage.payload` means and what `SysExMessage.toBytes` puts the
/// framing back around.
///
/// Transports receive whole frames: `flutter_midi_command` assembles an
/// incoming SysEx complete with the `F0` it saw and an `F7` of its own. Passing
/// those bytes through as a payload framed them a second time, so an MG-30's
/// 218-byte reply became 220 bytes of `F0 F0 43 58 ... F7 F7`. That still
/// hex-dumps fine in a diagnostic capture, which is what made it so quiet -
/// but no response matcher recognised it, because both the length and the byte
/// after `F0` were wrong, and every preset read timed out against a device
/// that had in fact answered.
///
/// Either framing byte missing is left alone rather than treated as an error: a
/// transport that hands over an already-stripped payload, or a device whose
/// reply was cut short, should still round-trip whatever bytes did arrive.
List<int> sysExPayload(List<int> raw) {
  final start = raw.isNotEmpty && raw.first == 0xF0 ? 1 : 0;
  final end = raw.length > start && raw.last == 0xF7
      ? raw.length - 1
      : raw.length;
  return raw.sublist(start, end);
}
