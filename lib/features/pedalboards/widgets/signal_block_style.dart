import 'package:flutter/material.dart';

import '../../../core/enums/signal_block_type.dart';

/// How a block of a signal chain is drawn: its icon and its colour.
///
/// One place for the lot. A card that picked its own colour would drift from the
/// sheet that offers the type and from the diagram that draws it, and a new block
/// type would have to be found in three files instead of one.
///
/// The colours are hues rather than theme roles, because a chain is read by
/// shape: dirt is warm, time-based effects are cool, and the ends of the chain
/// are grey so the effects between them stand out. Each is a mid-tone that holds
/// up on a light and a dark background alike.
class SignalBlockStyle {
  const SignalBlockStyle({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  /// How a block of [type] is drawn.
  static SignalBlockStyle of(SignalBlockType type) => switch (type) {
    SignalBlockType.input || SignalBlockType.output => const SignalBlockStyle(
      icon: Icons.electrical_services,
      color: Color(0xFF78909C),
    ),
    SignalBlockType.di || SignalBlockType.utility => const SignalBlockStyle(
      icon: Icons.settings_input_component,
      color: Color(0xFF78909C),
    ),
    SignalBlockType.tuner => const SignalBlockStyle(
      icon: Icons.tune,
      color: Color(0xFF26A69A),
    ),
    SignalBlockType.wah => const SignalBlockStyle(
      icon: Icons.waves,
      color: Color(0xFF8D6E63),
    ),
    SignalBlockType.compressor => const SignalBlockStyle(
      icon: Icons.compress,
      color: Color(0xFF5C6BC0),
    ),
    SignalBlockType.gate => const SignalBlockStyle(
      icon: Icons.block,
      color: Color(0xFF546E7A),
    ),
    SignalBlockType.boost => const SignalBlockStyle(
      icon: Icons.trending_up,
      color: Color(0xFFFFA726),
    ),
    SignalBlockType.overdrive => const SignalBlockStyle(
      icon: Icons.local_fire_department,
      color: Color(0xFFEF6C00),
    ),
    SignalBlockType.distortion => const SignalBlockStyle(
      icon: Icons.flash_on,
      color: Color(0xFFE53935),
    ),
    SignalBlockType.fuzz => const SignalBlockStyle(
      icon: Icons.blur_on,
      color: Color(0xFFAD1457),
    ),
    SignalBlockType.eq => const SignalBlockStyle(
      icon: Icons.equalizer,
      color: Color(0xFF00897B),
    ),
    SignalBlockType.modulation ||
    SignalBlockType.chorus ||
    SignalBlockType.flanger ||
    SignalBlockType.phaser => const SignalBlockStyle(
      icon: Icons.water,
      color: Color(0xFF29B6F6),
    ),
    SignalBlockType.tremolo => const SignalBlockStyle(
      icon: Icons.graphic_eq,
      color: Color(0xFF26C6DA),
    ),
    SignalBlockType.pitch => const SignalBlockStyle(
      icon: Icons.swap_vert,
      color: Color(0xFF7E57C2),
    ),
    SignalBlockType.delay => const SignalBlockStyle(
      icon: Icons.repeat,
      color: Color(0xFF42A5F5),
    ),
    SignalBlockType.reverb => const SignalBlockStyle(
      icon: Icons.blur_circular,
      color: Color(0xFF5E35B1),
    ),
    SignalBlockType.amp => const SignalBlockStyle(
      icon: Icons.speaker,
      color: Color(0xFF6D4C41),
    ),
    SignalBlockType.cab || SignalBlockType.ir => const SignalBlockStyle(
      icon: Icons.speaker_group,
      color: Color(0xFF795548),
    ),
    SignalBlockType.multiEffect => const SignalBlockStyle(
      icon: Icons.dashboard_customize,
      color: Color(0xFF3949AB),
    ),
    SignalBlockType.looper => const SignalBlockStyle(
      icon: Icons.loop,
      color: Color(0xFF43A047),
    ),
    // Where the signal parts and where it comes back together. Structural, so
    // they are drawn in the same slate as the ends of the chain.
    SignalBlockType.split => const SignalBlockStyle(
      icon: Icons.call_split,
      color: Color(0xFF607D8B),
    ),
    SignalBlockType.merge => const SignalBlockStyle(
      icon: Icons.call_merge,
      color: Color(0xFF607D8B),
    ),
    // Out of the board and back into it, drawn as two arrows pointing opposite
    // ways so a pair reads as a round trip rather than as two dead ends.
    SignalBlockType.send => const SignalBlockStyle(
      icon: Icons.logout,
      color: Color(0xFF607D8B),
    ),
    SignalBlockType.fxReturn => const SignalBlockStyle(
      icon: Icons.login,
      color: Color(0xFF607D8B),
    ),
    SignalBlockType.custom => const SignalBlockStyle(
      icon: Icons.widgets_outlined,
      color: Color(0xFF757575),
    ),
  };
}
