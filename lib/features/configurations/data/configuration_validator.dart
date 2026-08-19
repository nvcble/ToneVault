import '../../../core/database/app_database.dart';
import '../../../core/enums/control_type.dart';
import 'configuration_draft.dart';

/// Validation rules for configuration input.
///
/// Each rule is a `String?` function returning the problem or null, so the same
/// code backs both `TextFormField.validator` and the repository's own guard.
/// None of it depends on Flutter.
abstract final class ConfigurationValidator {
  /// Mirrors the length limit declared on `configurations.name`.
  static const int nameMaxLength = 80;

  static String? name(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Enter a configuration name.';
    }
    if (trimmed.length > nameMaxLength) {
      return 'Use at most $nameMaxLength characters.';
    }
    return null;
  }

  static String? draft(ConfigurationDraft draft) => name(draft.name);

  /// Whether [value] is a position [control] can actually be in.
  ///
  /// Every control keeps its own domain, so this is the one rule that covers a
  /// clock knob, a percentage and a mode switch alike. The step is deliberately
  /// not enforced: it is a convenience for setting a knob, not a claim that no
  /// position between two steps exists.
  static String? value(double? value, {required PedalControl control}) {
    if (value == null) {
      return 'Enter a value for ${control.name}.';
    }
    if (!value.isFinite) {
      return 'Enter a value for ${control.name} as a plain number.';
    }
    if (value < control.minValue || value > control.maxValue) {
      return '${control.name} cannot be set to that.';
    }
    if (control.controlType == ControlType.selection &&
        value != value.roundToDouble()) {
      // A selection stores which position it is in, and there is no position
      // between the second and the third.
      return 'Pick one of ${control.name}\'s positions.';
    }
    return null;
  }
}
