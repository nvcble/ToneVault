/// Where things sit in an MG-30 V5 patch, and how well each is established.
///
/// Read out of a `MG30AllPatch.mg30patch` exported by QuickTone 2.4.12.27 from a
/// physical MG-30 on firmware **V5.0.2**, 2026-10-06 - see
/// `docs/nux_mg30_v5_patch_format.md` for the evidence behind every line and
/// `tools/quicktone/inspect_all_patch.js` to reproduce it.
///
/// Firmware applicability: V5 only. The 218-byte firmware v4.0.3 layout is a
/// different shape and is kept apart in `nux_mg30_v5_preset_decoder.dart`.
library;

/// One patch as the export writes it: a four-byte header, three complete scenes,
/// then the user IR that patch carries, if any.
///
/// VERIFIED across all 128 records of one export.
abstract final class Mg30V5PatchRecord {
  static const int size = 9902;

  /// Slot 0-127. Equals the record's own index in every record read so far.
  static const int slotOffset = 0;

  static const int firstSceneOffset = 4;
  static const int sceneCount = 3;

  /// 1 when the patch carries a user IR, 0 when it does not.
  static const int userIrFlagOffset = 430;

  /// ASCII, NUL-padded.
  static const int userIrNameOffset = 434;
  static const int userIrNameLength = 32;

  /// A whole RIFF/WAVE file: 48 kHz mono PCM, around 8.2 KB.
  static const int userIrWaveOffset = 466;

  /// How many patches a file of [bytes] length holds, or null when it is not a
  /// whole number of records - which is the only check that tells a truncated
  /// download from a patch file.
  static int? patchCount(int bytes) =>
      bytes > 0 && bytes % size == 0 ? bytes ~/ size : null;
}

/// Where things sit inside one 142-byte scene - a complete sound, which is what
/// lets V5 Pro Scene hold a different model per scene.
abstract final class Mg30V5SceneLayout {
  static const int size = 142;

  /// VERIFIED: cross-checked against all 128 patch names in one export, where
  /// `CT-RectoBeast` reads 16 (DUAL RECT) and `LT UBER CHUNK` reads 25 (UBER).
  /// 0 is bypass, 1-35 index the amp catalog.
  static const int ampModelOffset = 3;

  /// VERIFIED as a permutation of 0-11 in 128/128 records, varying per patch.
  ///
  /// Which block each index names is INFERRED (strong): read through the block
  /// order the V5 MIDI chart and firmware v4.0.3 both use, every record decodes
  /// to a sensible chain - gate or wah first, cabinet after the amp, volume last.
  static const int chainOrderOffset = 94;
  static const int chainOrderLength = 12;

  /// VERIFIED: every one of 128 records decodes to a readable name.
  static const int nameOffset = 106;
  static const int nameLength = 16;

  /// Per-block enable, model and parameter values. INFERRED only: the values
  /// sit in 0-100, which is the range `MG30_DisplayConfig.json` gives every
  /// knob, but which byte belongs to which block is not established. Nothing
  /// reads individual bytes out of here - the raw block is kept whole instead.
  static const int blockDataOffset = 0;
  static const int blockDataLength = 94;

  /// UNKNOWN: ends in three identical 16-bit little-endian values.
  static const int tailOffset = 122;
}
