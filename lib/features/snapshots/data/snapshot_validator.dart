import 'snapshot_draft.dart';

/// Validation rules for snapshot input.
///
/// Each rule is a `String?` function returning the problem or null, so the same
/// code backs both `TextFormField.validator` and the repository's own guard.
/// None of it depends on Flutter.
abstract final class SnapshotValidator {
  /// Mirrors the length limit declared on `rig_snapshots.name`.
  static const int nameMaxLength = 80;

  /// Unlike a rig name, a snapshot name need not be unique: "Easter" comes round
  /// every year, and the date it was captured tells them apart.
  static String? name(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Enter a name for this snapshot.';
    }
    if (trimmed.length > nameMaxLength) {
      return 'Use at most $nameMaxLength characters.';
    }
    return null;
  }

  static String? draft(SnapshotDraft draft) => name(draft.name);
}
