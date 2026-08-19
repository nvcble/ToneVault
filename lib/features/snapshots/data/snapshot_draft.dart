import '../../../core/database/app_database.dart';

/// What the user says about a snapshot: what to call it, and anything worth
/// remembering about the day.
///
/// The readings are not here. Those are read off the rig at capture, not typed,
/// and once frozen they are not editable at all - only the name and notes are.
class SnapshotDraft {
  const SnapshotDraft({required this.name, this.notes});

  factory SnapshotDraft.fromSnapshot(RigSnapshot snapshot) {
    return SnapshotDraft(name: snapshot.name, notes: snapshot.notes);
  }

  final String name;
  final String? notes;

  /// Trims text and turns blank notes into null, so an untouched notes field
  /// does not store an empty string that reads as "there is a note here".
  SnapshotDraft normalized() {
    final trimmedNotes = notes?.trim();

    return SnapshotDraft(
      name: name.trim(),
      notes: trimmedNotes == null || trimmedNotes.isEmpty ? null : trimmedNotes,
    );
  }
}
