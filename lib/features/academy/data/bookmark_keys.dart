import '../../../core/values/theory_keys.dart';

/// What a theory bookmark points at, read back out of the one string it is stored as.
///
/// A chord or a scale is stored as itself - `Cmaj7`, `A dorian` - because that is all
/// the engine needs to resolve it. A progression needs two things, the numbers and the
/// key they are read in, so it is stored as the same JSON array a lesson stores its
/// theory keys in and read back the same way.
///
/// One function rather than a target-specific branch at every call site: a bookmark is
/// drawn from whatever it points at, and the two shapes are told apart by whether the
/// string parses as an array.
List<String> theoryKeysOf(String targetKey) {
  final decoded = decodeTheoryKeys(targetKey);
  return decoded.isEmpty ? [targetKey] : decoded;
}

/// The other direction: the string to store for something that needs more than one key.
String theoryKeysKey(List<String> keys) =>
    keys.length == 1 ? keys.single : (encodeTheoryKeys(keys) ?? '');
