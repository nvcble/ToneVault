import 'pedalboard_draft.dart';

/// Validation rules for rig input.
///
/// Each rule is a `String?` function returning the problem or null, so the same
/// code backs both `TextFormField.validator` and the repository's own guard.
/// None of it depends on Flutter.
abstract final class PedalboardValidator {
  /// Mirrors the length limit declared on `pedalboards.name`.
  static const int nameMaxLength = 80;

  static String? name(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Enter a rig name.';
    }
    if (trimmed.length > nameMaxLength) {
      return 'Use at most $nameMaxLength characters.';
    }
    return null;
  }

  static String? draft(PedalboardDraft draft) => name(draft.name);
}
