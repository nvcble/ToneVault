import '../../../core/enums/control_type.dart';
import 'control_draft.dart';

/// Validation rules for control input.
///
/// Every rule is a `String?` function returning the problem or null, so the same
/// code backs both `TextFormField.validator` and the repository's own guard.
/// None of it depends on Flutter, and none of it depends on which pedal the
/// control belongs to - only on its [ControlType].
abstract final class ControlValidator {
  /// Mirrors the length limits declared on the `pedal_controls` columns.
  static const int nameMaxLength = 60;
  static const int unitMaxLength = 12;

  /// A selection position name. Nothing in the schema enforces this, but a
  /// label longer than this cannot be read in a list or on a chip.
  static const int optionMaxLength = 40;

  /// Two positions is the minimum that makes a selection a choice, and the
  /// upper bound keeps a mistyped paste from producing an unusable control.
  static const int minOptions = 2;
  static const int maxOptions = 24;

  static String? name(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Enter a control name.';
    }
    if (trimmed.length > nameMaxLength) {
      return 'Use at most $nameMaxLength characters.';
    }
    return null;
  }

  /// Unit is optional, so only its length is checked.
  static String? unit(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isNotEmpty && trimmed.length > unitMaxLength) {
      return 'Use at most $unitMaxLength characters.';
    }
    return null;
  }

  /// Checks a bound the user typed, before it is compared with the other one.
  static String? bound(double? value, {required String label}) {
    if (value == null) {
      return 'Enter a $label value.';
    }
    if (!value.isFinite) {
      return 'Enter a $label value as a plain number.';
    }
    return null;
  }

  /// Mirrors `CHECK (max_value > min_value)`.
  static String? domain({required double minValue, required double maxValue}) {
    return bound(minValue, label: 'minimum') ??
        bound(maxValue, label: 'maximum') ??
        (maxValue > minValue
            ? null
            : 'The maximum has to be greater than the minimum.');
  }

  /// Mirrors `CHECK (step IS NULL OR step > 0)`, plus the range check the
  /// database cannot express: a step wider than the domain leaves one position.
  static String? step(
    double? value, {
    required double minValue,
    required double maxValue,
  }) {
    if (value == null) {
      return null;
    }
    if (!value.isFinite || value <= 0) {
      return 'A step has to be greater than zero.';
    }
    if (value > maxValue - minValue) {
      return 'A step cannot be wider than the range itself.';
    }
    return null;
  }

  static String? defaultValue(
    double? value, {
    required double minValue,
    required double maxValue,
  }) {
    if (value == null) {
      return null;
    }
    if (!value.isFinite || value < minValue || value > maxValue) {
      return 'The default has to be within the range.';
    }
    return null;
  }

  /// Position names of a selection control.
  static String? options(List<String> values) {
    if (values.length < minOptions) {
      return 'Add at least $minOptions positions.';
    }
    if (values.length > maxOptions) {
      return 'Use at most $maxOptions positions.';
    }
    for (final option in values) {
      if (option.length > optionMaxLength) {
        return 'Keep each position under $optionMaxLength characters.';
      }
    }
    // Duplicates would make a stored position ambiguous to read back.
    final seen = <String>{};
    for (final option in values) {
      if (!seen.add(option.toLowerCase())) {
        return 'Two positions cannot share the name "$option".';
      }
    }
    return null;
  }

  /// First problem with [draft], or null when it can be stored.
  ///
  /// Expects a normalized draft: for a selection the bounds are derived from the
  /// positions, so the positions are reported first - "add at least two
  /// positions" is what the user can act on, where "the maximum has to be
  /// greater than the minimum" would be about a field they never filled in.
  static String? draft(ControlDraft draft) {
    return name(draft.name) ??
        unit(draft.unit) ??
        (draft.type == ControlType.selection ? options(draft.options) : null) ??
        domain(minValue: draft.minValue, maxValue: draft.maxValue) ??
        step(draft.step, minValue: draft.minValue, maxValue: draft.maxValue) ??
        defaultValue(
          draft.defaultValue,
          minValue: draft.minValue,
          maxValue: draft.maxValue,
        );
  }
}
