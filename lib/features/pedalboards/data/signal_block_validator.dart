import 'signal_block_draft.dart';

/// Validation rules for one block of a chain.
///
/// Each rule is a `String?` function returning the problem or null, so the same
/// code backs both `TextFormField.validator` and the repository's own guard.
/// None of it depends on Flutter.
abstract final class SignalBlockValidator {
  /// Mirrors the length limit declared on `signal_blocks.label`.
  static const int labelMaxLength = 80;

  /// A label is optional: a block is named by what it is for unless the user has
  /// something better to call it.
  static String? label(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.length > labelMaxLength) {
      return 'Use at most $labelMaxLength characters.';
    }
    return null;
  }

  static String? draft(SignalBlockDraft draft) => label(draft.label);
}
