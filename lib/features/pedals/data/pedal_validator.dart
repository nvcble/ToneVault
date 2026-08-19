import 'pedal_draft.dart';

/// Validation rules for pedal input.
///
/// Each rule is a `String?` function returning the problem or null, so the same
/// code backs both `TextFormField.validator` and the repository's own guard.
/// Neither direction depends on the other, and none of it depends on Flutter.
abstract final class PedalValidator {
  /// Mirrors the length limits declared on the `pedals` columns.
  static const int nameMaxLength = 100;
  static const int brandMaxLength = 60;

  static String? name(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Enter a pedal name.';
    }
    if (trimmed.length > nameMaxLength) {
      return 'Use at most $nameMaxLength characters.';
    }
    return null;
  }

  /// Brand is optional, so only its length is checked.
  static String? brand(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isNotEmpty && trimmed.length > brandMaxLength) {
      return 'Use at most $brandMaxLength characters.';
    }
    return null;
  }

  static String? purchaseDate(DateTime? value, {required DateTime now}) {
    if (value != null && value.isAfter(now)) {
      return 'A purchase date cannot be in the future.';
    }
    return null;
  }

  /// First problem with [draft], or null when every field is acceptable.
  static String? draft(PedalDraft draft, {required DateTime now}) {
    return name(draft.name) ??
        brand(draft.brand) ??
        purchaseDate(draft.purchaseDate, now: now);
  }
}
