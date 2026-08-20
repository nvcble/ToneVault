import 'patch_draft.dart';

/// Validation rules for patch and scene input.
///
/// Each rule is a `String?` function returning the problem or null, so the same
/// code backs both `TextFormField.validator` and the repository's own guard.
/// None of it depends on Flutter.
///
/// Where a control may be set to is not here: that rule is
/// `ConfigurationValidator.value`, which checks a position against the control's
/// own domain and so is the same rule for a scene as for a configuration.
abstract final class PatchValidator {
  /// Mirrors the length limit declared on `patches.name` and `scenes.name`.
  static const int nameMaxLength = 80;

  static String? patchName(String? value) => _name(value, 'patch');

  static String? sceneName(String? value) => _name(value, 'scene');

  static String? patchDraft(PatchDraft draft) => patchName(draft.name);

  static String? sceneDraft(SceneDraft draft) => sceneName(draft.name);

  /// One rule, with [what] naming the thing being named, so the message the user
  /// reads says which of the two they are in.
  static String? _name(String? value, String what) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Enter a $what name.';
    }
    if (trimmed.length > nameMaxLength) {
      return 'Use at most $nameMaxLength characters.';
    }
    return null;
  }
}
