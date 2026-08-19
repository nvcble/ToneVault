import 'dart:convert';

/// The position names of a selection control, stored as a JSON array of strings
/// in one nullable TEXT column.
///
/// The stored *value* of a selection control is still a number - the index into
/// this list - so only the labels live here. Keeping them on the control instead
/// of in a child table keeps the schema small and drops straight into the
/// planned JSON export.

/// Reads the `options` column. Never throws: a row that was hand-edited or
/// written by an older build reads as "no positions" rather than taking the
/// screen down with it.
List<String> decodeControlOptions(String? stored) {
  if (stored == null || stored.isEmpty) {
    return const [];
  }

  try {
    final decoded = jsonDecode(stored);
    if (decoded is! List) {
      return const [];
    }
    return [
      for (final entry in decoded)
        if (entry is String) entry,
    ];
  } on FormatException {
    return const [];
  }
}

/// Writes the `options` column, or null when there is nothing to store.
///
/// Every non-selection control stores null here, so an empty list has to encode
/// as null too - otherwise `[]` and "not applicable" would be two spellings of
/// the same thing.
String? encodeControlOptions(List<String> options) =>
    options.isEmpty ? null : jsonEncode(options);
