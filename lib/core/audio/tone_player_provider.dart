import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tone_player.dart';
import 'wav_tone_player.dart';

/// The one player the app sounds notes through.
///
/// One rather than one a screen, so leaving a drill mid-chord and opening another does
/// not leave two of them playing over each other. A test overrides this with a
/// recorder and never opens a sound device at all.
final Provider<TonePlayer> tonePlayerProvider = Provider<TonePlayer>((ref) {
  final player = WavTonePlayer();
  ref.onDispose(player.dispose);
  return player;
});
