import '../../../core/database/app_database.dart';

/// A patch's own details, before it becomes a database row.
///
/// Neither the scenes inside it nor the pedals those use are part of this: a
/// patch is named first and filled in afterwards, one edit at a time.
class PatchDraft {
  const PatchDraft({required this.name, this.notes});

  factory PatchDraft.fromPatch(Patch patch) =>
      PatchDraft(name: patch.name, notes: patch.notes);

  factory PatchDraft.fromScene(Scene scene) =>
      PatchDraft(name: scene.name, notes: scene.notes);

  final String name;
  final String? notes;

  /// Trims text and turns blank optional text into null, so a name entered as
  /// "  Worship Clean " does not become a second patch alongside "Worship
  /// Clean".
  PatchDraft normalized() {
    final trimmedNotes = notes?.trim();

    return PatchDraft(
      name: name.trim(),
      notes: trimmedNotes == null || trimmedNotes.isEmpty ? null : trimmedNotes,
    );
  }
}

/// A scene's own details, which are a name and notes - the same two fields.
///
/// An alias rather than a second class: the two drafts would be identical, and a
/// copy of [PatchDraft] would be one more place to keep the trimming rules in
/// step. The form that edits either one is the same form.
typedef SceneDraft = PatchDraft;
