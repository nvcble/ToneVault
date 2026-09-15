import '../../midi_message.dart';
import 'nux_mg30_v5_preset_layout.dart';
import 'nux_mg30_v5_sysex.dart';

/// One block's raw state inside a decoded MG-30 preset dump.
///
/// [modelCode] is the byte the device itself stores, not a resolved model
/// name: NUX has published no name table for these codes for V5, and the
/// GPL-3.0 `mg30-controller` project's own table is confirmed only on
/// firmware v4.0.3, so copying it in would be exactly the kind of
/// unverified fabrication the diagnostic brief forbids. Resolving names is
/// future work once a real code-to-name table is confirmed for this unit.
class DecodedNuxMg30V5Block {
  const DecodedNuxMg30V5Block({
    required this.label,
    required this.modelCode,
    required this.bypassPerScene,
    this.isParallel,
  });

  final String label;
  final int modelCode;

  /// Whether this block is on for Pro Scene 1, 2 and 3, in that order.
  final List<bool> bypassPerScene;

  /// Only meaningful for MOD/DLY/RVB, which can run in parallel rather than
  /// in series; null for every other block.
  final bool? isParallel;
}

/// One MG-30 preset dump, decoded as far as the reverse-engineered layout
/// supports - see [NuxMg30V5SysEx] for where that layout comes from, and
/// [NuxMg30V5PresetLayout] for which fields survive on a real V5 dump (the slot
/// number and the patch name) and which do not.
///
/// Never throws over one bad field: anything that could not be decoded is
/// named in [unsupportedFields] instead, so one unexpected byte does not
/// lose the rest of the preset.
class DecodedNuxMg30V5Preset {
  const DecodedNuxMg30V5Preset({
    required this.programNumber,
    this.name,
    this.tempoBpm,
    this.signalChainOrder = const [],
    this.blocks = const [],
    this.unsupportedFields = const {},
  });

  final int programNumber;
  final String? name;
  final int? tempoBpm;

  /// Block labels in signal-chain order, decoded from the dump itself -
  /// distinct from `nuxMg30V5Capabilities[MidiFeature.signalChainEditing]`,
  /// which is about editing chain order live over CC, not reading it back
  /// from a preset dump.
  final List<String> signalChainOrder;
  final List<DecodedNuxMg30V5Block> blocks;

  /// Human-readable names of fields this decoder does not (yet, or ever
  /// without more information) attempt - knob/parameter values chief among
  /// them. Always non-empty: no MG-30 preset dump is fully decoded today.
  final Set<String> unsupportedFields;
}

class _BlockSpec {
  const _BlockSpec(this.label, this.modelByteOffset, this.bypassMask, this.sceneByteOffset);
  final String label;
  final int modelByteOffset;
  final int bypassMask;
  final int sceneByteOffset;
}

/// Fixed per-block-type byte offsets, reverse-engineered by
/// `mg30-controller` (`device.dart`'s `_getSingleCodeTypeBlock`/
/// `_getDualCodeTypeBlock` call sites) - the same 12 block types (11 audio
/// blocks plus a Volume block the CC protocol does not expose as a typed
/// block) as `nuxMg30V5BlockDefinitions`, in the dump's own byte order.
const List<_BlockSpec> _blockSpecs = [
  _BlockSpec('Wah', 8, 2, 1),
  _BlockSpec('Compressor', 9, 4, 1),
  _BlockSpec('Effect', 11, 8, 1),
  _BlockSpec('Amp', 12, 16, 1),
  _BlockSpec('EQ', 14, 32, 1),
  _BlockSpec('Noise Gate', 15, 64, 1),
  _BlockSpec('Modulation', 17, 1, 0),
  _BlockSpec('Delay', 18, 2, 0),
  _BlockSpec('Reverb', 20, 1, 2),
  _BlockSpec('IR', 21, 2, 2),
  _BlockSpec('Send/Return', 22, 4, 2),
  _BlockSpec('Volume', 24, 8, 2),
];

/// Chain-order byte offsets and whether each is halved before use - see
/// `mg30-controller`'s `_getEffectTypeChain`. Each decoded value is a block
/// index into [_blockSpecs] (0-11), naming which block sits at that position
/// in the signal chain.
const List<(int offset, bool halved)> _chainOrderOffsets = [
  (147, false),
  (149, true),
  (150, false),
  (152, true),
  (153, false),
  (155, true),
  (156, false),
  (158, true),
  (159, false),
  (161, true),
  (162, false),
  (164, true),
];

/// Decodes [response] - which must satisfy [NuxMg30V5SysEx.isPresetDataResponse]
/// or [NuxMg30V5SysEx.isCurrentEffectStateResponse] - as far as its
/// [NuxMg30V5PresetLayout] supports.
DecodedNuxMg30V5Preset decodeNuxMg30V5Preset(MidiMessage response) {
  final bytes = response.toBytes();
  final layout = nuxMg30V5PresetLayoutFor(bytes.length);
  if (layout == null) {
    throw ArgumentError(
      'Not an MG-30 preset dump this decoder knows (got ${bytes.length} bytes, '
      'expected ${nuxMg30V5PresetLayouts.map((l) => l.length).join(' or ')}).',
    );
  }

  final unsupported = <String>{
    'knob/parameter values (gain, EQ bands, delay time, and similar)',
    'block model names (only the raw model code is decoded)',
    'Wah expression-pedal enabled/disabled flag',
  };

  String? name;
  try {
    name = decodeNuxMg30V5PresetName(bytes, layout);
  } catch (_) {
    unsupported.add('patch name');
  }

  if (!layout.v403FieldOffsets) {
    // Everything below reads offsets confirmed on v4.0.3 only, and this is not
    // that frame - see [NuxMg30V5PresetLayout].
    unsupported.addAll(const [
      'tempo',
      'signal chain order',
      'parallel routing (MOD/DLY/RVB)',
      'per-block model codes and per-scene bypass',
    ]);
    return DecodedNuxMg30V5Preset(
      programNumber: bytes[6],
      name: name,
      unsupportedFields: unsupported,
    );
  }

  int? tempoBpm;
  try {
    tempoBpm = bytes[143] * 64 + bytes[144];
  } catch (_) {
    unsupported.add('tempo');
  }

  final blocks = <DecodedNuxMg30V5Block>[];
  for (final spec in _blockSpecs) {
    try {
      blocks.add(
        DecodedNuxMg30V5Block(
          label: spec.label,
          modelCode: bytes[spec.modelByteOffset],
          bypassPerScene: [
            bytes[208 + spec.sceneByteOffset] & spec.bypassMask == spec.bypassMask,
            bytes[211 + spec.sceneByteOffset] & spec.bypassMask == spec.bypassMask,
            bytes[214 + spec.sceneByteOffset] & spec.bypassMask == spec.bypassMask,
          ],
        ),
      );
    } catch (_) {
      unsupported.add('${spec.label} block');
    }
  }
  _applyParallelFlags(bytes, blocks, unsupported);

  var signalChainOrder = const <String>[];
  try {
    signalChainOrder = [
      for (final (offset, halved) in _chainOrderOffsets)
        _blockSpecs[halved ? bytes[offset] ~/ 2 : bytes[offset]].label,
    ];
  } catch (_) {
    unsupported.add('signal chain order');
  }

  return DecodedNuxMg30V5Preset(
    programNumber: bytes[6],
    name: name,
    tempoBpm: tempoBpm,
    signalChainOrder: signalChainOrder,
    blocks: blocks,
    unsupportedFields: unsupported,
  );
}

/// MOD/DLY/RVB can each run in parallel with its neighbor rather than in
/// series - byte 146, bits 2 and 4 - see `mg30-controller`'s
/// `_populateEffectChain`.
void _applyParallelFlags(
  List<int> bytes,
  List<DecodedNuxMg30V5Block> blocks,
  Set<String> unsupported,
) {
  try {
    final flags = bytes[146];
    final modDlyRvb = ['Modulation', 'Delay', 'Reverb']
        .map((label) => blocks.indexWhere((block) => block.label == label))
        .toList();
    if (modDlyRvb.every((index) => index != -1)) {
      final modParallel = flags & 2 == 2;
      final dlyParallel = modParallel || (flags & 4 == 4);
      final rvbParallel = flags & 4 == 4;
      blocks[modDlyRvb[0]] = _withParallel(blocks[modDlyRvb[0]], modParallel);
      blocks[modDlyRvb[1]] = _withParallel(blocks[modDlyRvb[1]], dlyParallel);
      blocks[modDlyRvb[2]] = _withParallel(blocks[modDlyRvb[2]], rvbParallel);
    }
  } catch (_) {
    unsupported.add('parallel routing (MOD/DLY/RVB)');
  }
}

DecodedNuxMg30V5Block _withParallel(DecodedNuxMg30V5Block block, bool isParallel) =>
    DecodedNuxMg30V5Block(
      label: block.label,
      modelCode: block.modelCode,
      bypassPerScene: block.bypassPerScene,
      isParallel: isParallel,
    );

