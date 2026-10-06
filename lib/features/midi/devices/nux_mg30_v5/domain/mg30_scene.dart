import 'dart:typed_data';

import '../../../../../core/midi/profiles/nux_mg30_v5/nux_mg30_v5_block.dart';
import '../../../../../core/midi/profiles/nux_mg30_v5/nux_mg30_v5_model_names.dart';

/// One Pro Scene of an MG-30 V5 patch: a complete sound, not a set of bypass
/// switches over a shared one.
///
/// Only what the V5 layout establishes is given a field. Everything else stays
/// in [raw] rather than being guessed at, so a patch read today survives a
/// decoder that learns more tomorrow - which is also what makes a write
/// byte-faithful: a scene is sent back as the bytes it came from, with the
/// decoded fields written over them.
class Mg30Scene {
  const Mg30Scene({
    required this.name,
    required this.ampModelCode,
    required this.chainOrder,
    required this.raw,
  });

  /// The patch name, which every scene of a patch carries its own copy of.
  final String name;

  /// 0 for bypass, 1-35 for a model in the amp catalog.
  final int ampModelCode;

  /// The 12 blocks in the order signal reaches them.
  final List<NuxMg30Block> chainOrder;

  /// The whole 142-byte scene exactly as the device stored it.
  final Uint8List raw;

  /// What the unit calls this scene's amp, or null when the block is bypassed or
  /// the code is outside the catalog - which is how a future firmware adding a
  /// model reads, rather than as a wrong name.
  String? get ampModelName {
    final models = nuxMg30V5ModelNames[NuxMg30Block.amp] ?? const [];
    if (ampModelCode < 1 || ampModelCode > models.length) {
      return null;
    }
    return models[ampModelCode - 1];
  }

  bool get isAmpBypassed => ampModelCode == 0;
}
