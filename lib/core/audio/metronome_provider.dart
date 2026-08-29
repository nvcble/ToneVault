import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'looping_metronome.dart';
import 'metronome.dart';

/// The one metronome the app counts with.
///
/// Its own player rather than the tone player's, because the two are heard together: an
/// exercise counts while a chord is played to check it against, and one player can only
/// hold one sound. A test overrides this and no sound device is opened.
final Provider<Metronome> metronomeProvider = Provider<Metronome>((ref) {
  final metronome = LoopingMetronome();
  ref.onDispose(metronome.dispose);
  return metronome;
});
