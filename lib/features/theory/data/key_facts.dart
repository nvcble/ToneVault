import '../../../core/music/circle_of_fifths.dart';
import '../../../core/music/scale.dart';

/// What there is to say about a key beyond the notes in it.
///
/// All of it counted from the circle of fifths rather than looked up, so the browser
/// cannot disagree with the engine the lessons are drawn from. A key signature here is
/// the number of steps round the circle, which is what a key signature is.
class KeyFacts {
  const KeyFacts({
    required this.key,
    required this.signature,
    required this.relative,
    required this.neighbours,
  });

  factory KeyFacts.of(Scale key) => KeyFacts(
    key: key,
    signature: keySignature(key),
    relative: key.type.isMinorSounding
        ? relativeMajor(key)
        : relativeMinor(key),
    neighbours: neighbourKeys(key),
  );

  final Scale key;

  /// Sharps as a positive number, flats as a negative one, 0 for C major.
  final int signature;

  /// The minor key that shares this one's signature, or the major one for a minor key.
  final Scale relative;

  /// A fifth either way and the relative key: where a song goes without anybody
  /// feeling it happen.
  final List<Scale> neighbours;

  /// `No sharps or flats`, `1 sharp`, `3 flats`. Spelled out because a number on its
  /// own with a minus sign in front of it says nothing to a player.
  String get signatureLabel {
    if (signature == 0) {
      return 'No sharps or flats';
    }

    final count = signature.abs();
    final name = signature > 0 ? 'sharp' : 'flat';
    return '$count $name${count == 1 ? '' : 's'}';
  }

  /// How far another key is from this one, counted the short way round: 0 is here, 1
  /// is next door, 6 is as far as two keys get from each other.
  int distanceTo(Scale other) => fifthsBetween(key.root, other.root);
}
