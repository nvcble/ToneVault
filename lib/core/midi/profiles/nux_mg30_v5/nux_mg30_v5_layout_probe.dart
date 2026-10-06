import 'nux_mg30_v5_block_specs.dart';
import 'nux_mg30_v5_preset_decoder.dart';

/// What a scan of saved preset dumps found of the block region - which block
/// each slot runs and in what order - in a frame whose layout is not known.
///
/// [chainOrderBases] and [modelCodeBases] are offsets the region *could* start
/// at, never offsets it does: a candidate is a lead to check against what the
/// unit shows, and one is only interesting when it holds for every dump.
typedef NuxMg30V5LayoutFindings = ({
  int dumps,
  Set<int> frameLengths,
  List<int> chainOrderBases,
  List<int> modelCodeBases,
});

/// Looks for the block region of [dumps] - raw `F0...F7` preset replies, as
/// `midi_preset_captures` stores them.
///
/// Why this exists: on a 222-byte V5 reply only the slot number and the patch
/// name decode, so an imported patch cannot say which pedals it used. The bytes
/// are in the dump; what is missing is where. The v4.0.3 layout is the one known
/// shape of that region, so this slides it over the whole frame and reports
/// every offset where it still makes sense:
///
/// - a chain-order candidate reads as a permutation of the 12 blocks, which is
///   what that region is - 12 distinct block indices, each under 12;
/// - a model-code candidate has every block's model byte inside the range the
///   MIDI chart gives that block, counting from either 0 or 1.
///
/// Only offsets that hold in *every* dump are returned: one preset can satisfy
/// either test by chance, twelve cannot. An empty list is a real answer too -
/// it says this region is not laid out as v4.0.3's is, and the next lead has to
/// come from somewhere else.
NuxMg30V5LayoutFindings probeNuxMg30V5BlockLayout(List<List<int>> dumps) {
  return (
    dumps: dumps.length,
    frameLengths: {for (final dump in dumps) dump.length},
    chainOrderBases: _sharedBases(dumps, _chainOrderBases),
    modelCodeBases: _sharedBases(dumps, _modelCodeBases),
  );
}

/// The offsets every dump agrees on, in order. Empty when [dumps] is.
List<int> _sharedBases(
  List<List<int>> dumps,
  Set<int> Function(List<int> bytes) basesOf,
) {
  if (dumps.isEmpty) {
    return const [];
  }
  final shared = basesOf(dumps.first);
  for (final dump in dumps.skip(1)) {
    shared.retainAll(basesOf(dump));
  }
  return shared.toList()..sort();
}

Set<int> _chainOrderBases(List<int> bytes) {
  final offsets = nuxMg30V5V403ChainOrderOffsets;
  final first = offsets.first.$1;
  final span = offsets.last.$1 - first;

  return _basesWhere(bytes, span, (base) {
    final blocks = {
      for (final (offset, halved) in offsets)
        _value(bytes, base + offset - first, halved: halved),
    };
    return blocks.length == offsets.length &&
        blocks.every((block) => block < offsets.length);
  });
}

Set<int> _modelCodeBases(List<int> bytes) {
  final offsets = [
    for (final spec in nuxMg30V5V403BlockSpecs) spec.modelByteOffset,
  ];
  final first = offsets.first;
  final span = offsets.last - first;

  return _basesWhere(bytes, span, (base) {
    var anySet = false;
    for (var index = 0; index < offsets.length; index++) {
      final code = bytes[base + offsets[index] - first];
      // Inclusive of both conventions: the chart's CC range is 1..modelCount,
      // and a byte the device stores could count from 0. Narrowing that guess
      // is how a probe comes to rule out the answer it was looking for.
      if (code > nuxMg30V5Blocks[index].modelCount) {
        return false;
      }
      anySet |= code != 0;
    }
    // A run of zeros passes every range there is, and a dump is mostly padding:
    // reporting those offsets would bury the ones worth checking.
    return anySet;
  });
}

Set<int> _basesWhere(
  List<int> bytes,
  int span,
  bool Function(int base) holds,
) {
  return {
    for (var base = 0; base + span < bytes.length; base++)
      if (holds(base)) base,
  };
}

/// Half of the byte where the layout packs two values into three - see
/// `nuxMg30V5V403ChainOrderOffsets`.
int _value(List<int> bytes, int offset, {required bool halved}) =>
    halved ? bytes[offset] ~/ 2 : bytes[offset];
