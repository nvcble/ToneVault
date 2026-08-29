import 'dart:convert';

/// What a lesson points at in the theory engine, stored as a JSON array of
/// strings in one nullable TEXT column.
///
/// A key is something the engine can resolve on demand - `Cmaj7`, `A dorian`,
/// `I-V-vi-IV` - rather than a row in a table, because there is no table of every
/// chord in music and there is not going to be one. The same reasoning as
/// `control_options.dart`, which stores the position names of a selection control
/// the same way.

/// Reads the `theory_keys` column. Never throws: a lesson written by an older
/// build or edited by hand reads as pointing at nothing rather than taking the
/// screen down with it.
List<String> decodeTheoryKeys(String? stored) {
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

/// Writes the `theory_keys` column, or null where a lesson points at nothing.
///
/// An empty list encodes as null, so `[]` and "this lesson names no theory" are
/// not two spellings of the same thing.
String? encodeTheoryKeys(List<String> keys) =>
    keys.isEmpty ? null : jsonEncode(keys);
