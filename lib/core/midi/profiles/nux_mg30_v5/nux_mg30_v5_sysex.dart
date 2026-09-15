import '../../midi_message.dart';

/// NUX MG-30 SysEx request/response shapes, reverse-engineered by the
/// GPL-3.0 community project `mg30-controller`
/// (github.com/sirosss/mg30-controller, `lib/models/device.dart`) against a
/// physical MG-30 on **firmware v4.0.3** - not against this app's V5 unit.
/// Reimplemented independently here from that project's observed byte
/// layout, not copied from its source.
///
/// Each request/response pair below carries its own status. Except where a
/// paragraph says "verified against the physical MG-30 V5", treat it as
/// needing hardware verification: it is v4.0.3 community evidence, and nothing
/// here may be presented to a user as a confirmed NUX protocol. NUX has
/// published no SysEx spec at all - see
/// `nuxMg30V5Capabilities[MidiFeature.patchTransfer]`.
///
/// Header: every message is `F0 43 58 ...F7`. `0x43` is Yamaha's registered
/// manufacturer ID, reused by NUX without a distinct ID of its own; `0x58`
/// is a NUX/product sub-id.
///
/// **Captured from a physical MG-30 V5** (ToneVault MIDI Capture, 2026-09-15):
/// the unit sends 15-byte frames of the shape
/// `F0 43 58 70 7E 02 <value> 00 00 00 00 00 00 00 F7` unprompted, with
/// `<value>` observed as `0x14` and `0x03`. That confirms the 15-byte
/// `43 58 70 <command> <00 request | 02 reply> ...` frame layout below is real
/// on V5, and that `0x02` marks a reply. Command `0x7E` and its value are
/// **unknown-unverified**: nothing here decodes them, and no meaning may be
/// claimed for them. The same capture shows the unit sending Program Change,
/// CC 7 and CC 0x4F (79) on channel 1; whether CC 79 is the Scene control is
/// still unverified, since the observed values (0x5B, 0x5E) are not scene
/// indices.
///
/// **Verified against the physical MG-30 V5** (ToneVault MIDI Capture,
/// 2026-09-15): [getPresetDataRequest] works. Five reads of slots 0-4 each drew
/// a `F0 43 58 70 0B 02 <slot> ... F7` reply 58-150 ms later, with the slot byte
/// echoed back correctly - so the command, the reply header and
/// [presetResponseProgramNumber] are real on V5. The replies are 222 bytes, not
/// the 218 of v4.0.3; see [presetDumpLengths].
///
/// Still unverified even so: whether this read is non-disruptive while playing,
/// and what most of the 222 bytes mean - only the slot number and the patch name
/// decode reliably, see `nux_mg30_v5_preset_decoder.dart`.
abstract final class NuxMg30V5SysEx {
  /// The frame lengths a preset dump has actually been seen with.
  ///
  /// 222 is **verified against the physical MG-30 V5**; 218 is
  /// `mg30-controller`'s figure, kept because v4.0.3 is the only firmware it
  /// was ever confirmed on. Matching on 218 alone is what made every real V5
  /// read fail: the unit replied correctly and promptly, and the reply was
  /// rejected on length alone until the request timed out.
  static const Set<int> presetDumpLengths = {218, 222};

  /// "Who are you" - `F0 43 58 00 F7`. v4.0.3 replies with a 45-byte frame
  /// whose bytes 4-9 spell its firmware version in ASCII (e.g. "v4.0.3").
  /// What a V5 unit replies with - if it replies to this at all - is unknown.
  static SysExMessage identifyRequest() => const SysExMessage(payload: [0x43, 0x58, 0x00]);

  /// Which program number (and Pro Scene) is currently loaded -
  /// `F0 43 58 70 15 00 F7`.
  static SysExMessage getCurrentProgramNumberRequest() =>
      const SysExMessage(payload: [0x43, 0x58, 0x70, 0x15, 0x00]);

  /// The full state of whichever preset is currently loaded -
  /// `F0 43 58 70 0C 00 F7`. Same response shape as [getPresetDataRequest].
  static SysExMessage getCurrentEffectStateRequest() =>
      const SysExMessage(payload: [0x43, 0x58, 0x70, 0x0C, 0x00]);

  /// Reads preset [programNo] (0-127) by number, without requiring it to be
  /// the currently loaded one - the command milestone 1 of the diagnostic
  /// brief needs: "read preset 01A" without disturbing playback. Whether it
  /// is actually non-disruptive on real hardware is unverified; see the
  /// class doc.
  static SysExMessage getPresetDataRequest(int programNo) => SysExMessage(
    payload: [0x43, 0x58, 0x70, 0x0B, 0x00, programNo, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
  );

  /// True for a 45-byte identify reply, `F0 43 58 10 ...`.
  static bool isIdentifyResponse(MidiMessage message) {
    final bytes = message.toBytes();
    return bytes.length == 45 && _prefixMatches(bytes, const [0x43, 0x58, 0x10]);
  }

  /// The identify reply's firmware string, e.g. "v4.0.3" - not assumed to be
  /// "v5.x" for this app's unit; read it and compare rather than guessing.
  static String identifyFirmwareVersion(MidiMessage message) =>
      String.fromCharCodes(message.toBytes().sublist(4, 10));

  /// True for a "get preset data" reply, `F0 43 58 70 0B 02 ...`.
  static bool isPresetDataResponse(MidiMessage message) => _isPresetDump(message, 0x0B);

  /// True for a "get current effect state" reply, `F0 43 58 70 0C 02 ...` -
  /// the same frame shape [isPresetDataResponse] matches and the same layout
  /// the preset decoder reads.
  static bool isCurrentEffectStateResponse(MidiMessage message) => _isPresetDump(message, 0x0C);

  static bool _isPresetDump(MidiMessage message, int command) {
    final bytes = message.toBytes();
    return presetDumpLengths.contains(bytes.length) &&
        _prefixMatches(bytes, [0x43, 0x58, 0x70, command, 0x02]);
  }

  /// True for a "get current program number" reply,
  /// `F0 43 58 70 15 02 ...`, 15 bytes.
  static bool isCurrentProgramNumberResponse(MidiMessage message) {
    final bytes = message.toBytes();
    return bytes.length == 15 && _prefixMatches(bytes, const [0x43, 0x58, 0x70, 0x15, 0x02]);
  }

  /// The program number a "get preset data" or "get current effect state"
  /// reply is for - byte 6, verified on V5 by the slot echoing the request.
  static int presetResponseProgramNumber(MidiMessage message) => message.toBytes()[6];

  static bool _prefixMatches(List<int> bytes, List<int> prefix) {
    for (var i = 0; i < prefix.length; i++) {
      if (bytes[i + 1] != prefix[i]) {
        return false;
      }
    }
    return true;
  }
}
