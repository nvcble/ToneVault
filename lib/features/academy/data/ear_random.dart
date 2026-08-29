import 'dart:math';

import '../../../core/music/pitch_class.dart';

/// The three ways an ear training question chooses what to ask.
///
/// In one place because every drill needs them and because a test hands in a
/// `Random` with a seed: the same seed then produces the same question, which is how a
/// drill can be checked at all without a listener in the room.

PitchClass anyRoot(Random random) => PitchClass(random.nextInt(12));

T oneOf<T>(Random random, List<T> from) => from[random.nextInt(from.length)];

/// [count] of [from], in an order nobody can predict, without repeats.
List<T> someOf<T>(Random random, List<T> from, int count) =>
    ([...from]..shuffle(random)).take(count).toList();
