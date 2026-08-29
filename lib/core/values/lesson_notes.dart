import 'dart:convert';

/// The short lists a lesson carries beside its text - what players get wrong, and
/// what to do about it - stored as a JSON array of strings in one nullable TEXT
/// column.
///
/// A table of its own would buy ordering and querying, and neither is wanted: these
/// are read as a list under one lesson and never searched across lessons. The same
/// reasoning as `theory_keys.dart`, which stores what a lesson points at the same way.

/// Reads one of the note columns. Never throws: a lesson written by an older build
/// or edited by hand reads as saying nothing rather than taking the screen down.
List<String> decodeLessonNotes(String? stored) {
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

/// Writes one of the note columns, or null where the lesson says nothing.
///
/// An empty list encodes as null, so `[]` and "this lesson lists no mistakes" are
/// not two spellings of the same thing.
String? encodeLessonNotes(List<String> notes) =>
    notes.isEmpty ? null : jsonEncode(notes);
