import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/values/control_options.dart';
import '../../../core/values/control_value_label.dart';

/// One control in a pedal's list, summarised by what it accepts.
///
/// Everything shown comes from the row itself, so a pedal nobody anticipated
/// lists exactly as well as a familiar one.
class ControlTile extends StatelessWidget {
  const ControlTile({
    required this.control,
    this.onTap,
    this.trailing,
    super.key,
  });

  final PedalControl control;
  final VoidCallback? onTap;

  /// Supplied by the list, which is the only thing that knows about dragging.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(control.name),
      subtitle: Text(controlSummary(control)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

/// What a control accepts, and where it sits by default.
String controlSummary(PedalControl control) {
  final options = decodeControlOptions(control.options);
  final defaultValue = control.defaultValue;

  return [
    control.controlType.label,
    formatControlRange(
      type: control.controlType,
      minValue: control.minValue,
      maxValue: control.maxValue,
      unit: control.unit,
      options: options,
    ),
    if (defaultValue != null)
      'default ${formatControlValue(defaultValue, type: control.controlType, unit: control.unit, options: options)}',
  ].join(' · ');
}
