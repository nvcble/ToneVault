/// Which preset-dump layouts ToneVault knows, and how each stores its name.
///
/// Kept apart from the decoder itself because this is the part that changes
/// whenever a new firmware is captured: which byte lengths exist, and where
/// the fields sit in each. See `nux_mg30_v5_sysex.dart` for the frame header.
library;

/// One dump length this app can read, and how to read it.
///
/// 218 bytes is firmware v4.0.3, reverse-engineered by the GPL-3.0
/// `mg30-controller` project; 222 is what a physical MG-30 V5 replies with
/// (**verified**, ToneVault MIDI Capture, 2026-09-15).
///
/// On V5 the name grid sits one byte later *and* starts on the encoded half of
/// a character pair rather than the plain one ([nameStartsOnPair]); with both
/// applied, all five captured presets decode to the names the unit displays.
///
/// [v403FieldOffsets] says whether the rest of the v4.0.3 offsets - tempo,
/// chain order, parallel flags, per-block model codes and per-scene bypass -
/// can be read as well. On V5 they cannot: no shift of 0 to 5 bytes makes the
/// chain-order bytes a permutation of the 12 blocks in any captured preset, so
/// the decoder reports that whole region unsupported rather than guessing. The
/// raw dump is stored whole, so a later evidence-backed layout can decode it
/// without needing the hardware again.
typedef NuxMg30V5PresetLayout = ({
  int length,
  int nameOffset,
  bool nameStartsOnPair,
  bool v403FieldOffsets,
});

const List<NuxMg30V5PresetLayout> nuxMg30V5PresetLayouts = [
  (
    length: 218,
    nameOffset: 165,
    nameStartsOnPair: false,
    v403FieldOffsets: true,
  ),
  (
    length: 222,
    nameOffset: 167,
    nameStartsOnPair: true,
    v403FieldOffsets: false,
  ),
];

/// The layout for a dump of [length] bytes, or null if that length is unknown.
NuxMg30V5PresetLayout? nuxMg30V5PresetLayoutFor(int length) {
  for (final layout in nuxMg30V5PresetLayouts) {
    if (layout.length == length) {
      return layout;
    }
  }
  return null;
}

/// Longest name window read out of a dump; the terminating zero usually ends
/// it well before this.
const _nameWindow = 24;

/// Unpacks the patch name [bytes] holds, per [layout].
///
/// A name is a run of alternating plain and encoded characters: a plain one is
/// a single byte as-is, an encoded one is two bytes worth `(second ~/ 2)`,
/// +0x40 when `first == 1`. That is a 7-bit-safe packing, so a full ASCII value
/// survives inside SysEx data bytes, which must stay under 0x80. A zero
/// character ends the name. Reverse-engineered by `mg30-controller`'s
/// `_convertProgramName`, reimplemented independently here.
String decodeNuxMg30V5PresetName(
  List<int> bytes,
  NuxMg30V5PresetLayout layout,
) {
  final data = bytes.sublist(
    layout.nameOffset,
    layout.nameOffset + _nameWindow,
  );
  final result = StringBuffer();
  var i = 0;
  var pair = layout.nameStartsOnPair;
  while (i + (pair ? 1 : 0) < data.length) {
    final char = pair ? data[i + 1] ~/ 2 + (data[i] == 1 ? 0x40 : 0) : data[i];
    if (char == 0) break;
    result.writeCharCode(char);
    i += pair ? 2 : 1;
    pair = !pair;
  }
  return result.toString();
}
