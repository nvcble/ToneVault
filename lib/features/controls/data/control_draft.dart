import '../../../core/database/app_database.dart';
import '../../../core/enums/control_type.dart';
import '../../../core/values/control_options.dart';

/// A control as the user described it, before it becomes a database row.
///
/// The control type decides everything about how the control behaves, which is
/// what lets one form define a knob on any pedal without the app knowing which
/// pedal it is.
class ControlDraft {
  const ControlDraft({
    required this.name,
    required this.type,
    required this.minValue,
    required this.maxValue,
    this.step,
    this.defaultValue,
    this.unit,
    this.options = const [],
  });

  /// A fresh control of [type], starting from that type's own domain and step.
  ///
  /// Used when the type is picked or changed in the form: the previous type's
  /// bounds mean nothing to the new one.
  factory ControlDraft.ofType(ControlType type, {String name = ''}) {
    final domain = type.defaultDomain;
    return ControlDraft(
      name: name,
      type: type,
      minValue: domain.min,
      maxValue: domain.max,
      step: type.defaultStep,
    );
  }

  factory ControlDraft.fromControl(PedalControl control) {
    return ControlDraft(
      name: control.name,
      type: control.controlType,
      minValue: control.minValue,
      maxValue: control.maxValue,
      step: control.step,
      defaultValue: control.defaultValue,
      unit: control.unit,
      options: decodeControlOptions(control.options),
    );
  }

  final String name;
  final ControlType type;
  final double minValue;
  final double maxValue;
  final double? step;
  final double? defaultValue;
  final String? unit;

  /// Position names, for [ControlType.selection] only.
  final List<String> options;

  /// Trims text, drops blanks, and makes the domain agree with the type.
  ///
  /// Types with a fixed domain get theirs back regardless of what was passed:
  /// a clock knob that stored `0..10` would read every position wrong, and a
  /// toggle only ever has two states. A selection's bounds are its positions, so
  /// they are derived rather than entered.
  ControlDraft normalized() {
    final cleanOptions = type == ControlType.selection
        ? [
            for (final option in options)
              if (option.trim().isNotEmpty) option.trim(),
          ]
        : const <String>[];

    final domain = _domainFor(cleanOptions);

    return ControlDraft(
      name: name.trim(),
      type: type,
      minValue: domain.min,
      maxValue: domain.max,
      step: step,
      defaultValue: defaultValue,
      unit: _blankToNull(unit),
      options: cleanOptions,
    );
  }

  ({double min, double max}) _domainFor(List<String> cleanOptions) {
    if (type.hasFixedDomain) {
      return type.defaultDomain;
    }
    if (type == ControlType.selection) {
      // An empty or single-item list leaves max <= min, which the validator
      // reports as "needs at least two positions".
      return (min: 0, max: (cleanOptions.length - 1).toDouble());
    }
    return (min: minValue, max: maxValue);
  }
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
