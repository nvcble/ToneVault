import '../../../core/enums/multi_effects_mode.dart';
import '../../../core/enums/pedal_type.dart';
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

  /// A multi-effects unit has to say how it is organised, because that is what
  /// decides which screen its own pedals and sounds are kept on. Nothing else
  /// may carry a mode, which would be a claim about a pedal that has no patches.
  static String? multiEffectsMode(MultiEffectsMode? value, PedalType type) {
    final isUnit = type == PedalType.multiEffects;
    if (isUnit && value == null) {
      return 'Pick whether this unit is used in stomp mode or scene mode.';
    }
    if (!isUnit && value != null) {
      return 'Only a multi-effects unit has a stomp or scene mode.';
    }
    return null;
  }

  /// First problem with [draft], or null when every field is acceptable.
  static String? draft(PedalDraft draft, {required DateTime now}) {
    return name(draft.name) ??
        brand(draft.brand) ??
        purchaseDate(draft.purchaseDate, now: now) ??
        multiEffectsMode(draft.multiEffectsMode, draft.type);
  }
}
