import 'pitch_class.dart';
import 'scale.dart';
import 'scale_type.dart';

/// Every name a scale will answer to, and how to read one out of typed words.
///
/// Kept apart from `theory_query.dart` because it is a table rather than a decision: the
/// resolver there reads whatever a lesson or a player wrote and works out which kind of
/// thing it is, while this only knows the words. Both a search matching `aeolian` against
/// the scales and a lesson naming its key come through here, which is what stops them
/// disagreeing about what a word means.

/// The names, for anything matching a typed word against the scales rather than reading a
/// whole reference.
///
/// Unmodifiable, because a caller adding a name here would be teaching the engine a word
/// only that caller knows.
Map<String, ScaleType> get scaleTypeNames => Map.unmodifiable(_scaleTypes);

/// `G major`, `A minor pentatonic`, `E dorian`, `A blues scale`, or null where those
/// words name no scale.
///
/// The root is everything up to the first space, so anything with no space in it is left
/// for a chord to read - which is what keeps `Am` a chord and `A minor` a scale.
Scale? scaleFromName(String written) {
  final text = written.trim();
  final space = text.indexOf(' ');
  if (space < 0) {
    return null;
  }

  final type = _scaleTypes[_normalise(text.substring(space + 1))];
  if (type == null) {
    return null;
  }

  try {
    return Scale(PitchClass.parse(text.substring(0, space)), type);
  } on Object {
    return null;
  }
}

/// Every scale's own name, plus the names players use for the same thing.
final Map<String, ScaleType> _scaleTypes = {
  for (final type in ScaleType.values) _normalise(type.label): type,
  'ionian': ScaleType.major,
  'aeolian': ScaleType.minor,
  'natural minor': ScaleType.minor,
  // A bare `pentatonic` means the major one: a lesson that means the other says so.
  'pentatonic': ScaleType.majorPentatonic,
  'super locrian': ScaleType.altered,
  'altered dominant': ScaleType.altered,
  'whole-tone': ScaleType.wholeTone,
  'octatonic': ScaleType.diminished,
  'whole half': ScaleType.diminished,
};

/// Case and a trailing `scale` do not change which scale is meant.
String _normalise(String text) {
  final lower = text.trim().toLowerCase();
  return lower.endsWith(' scale')
      ? lower.substring(0, lower.length - ' scale'.length)
      : lower;
}
