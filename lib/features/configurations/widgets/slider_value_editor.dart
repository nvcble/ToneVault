import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/values/control_options.dart';
import '../../../core/values/control_value_label.dart';
import '../data/control_value_range.dart';

/// Sets a control that sweeps, such as a knob or a percentage.
///
/// The notches, the ends and the reading all come from the control's own row, so
/// a knob nobody anticipated is as usable as a familiar one.
class SliderValueEditor extends StatelessWidget {
  const SliderValueEditor({
    required this.control,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final PedalControl control;
  final double value;

  /// Null while a save is in flight, which greys the slider out rather than
  /// letting a second position be set on the way.
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final endStyle = Theme.of(context).textTheme.bodySmall;

    return Column(
      children: [
        Slider(
          // A stored value can only fall outside the domain through a
          // hand-edited database, and a slider throws rather than clamping.
          value: value.clamp(control.minValue, control.maxValue),
          min: control.minValue,
          max: control.maxValue,
          divisions: sliderDivisionsFor(control),
          label: _reading(value),
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_reading(control.minValue), style: endStyle),
            Text(_reading(control.maxValue), style: endStyle),
          ],
        ),
      ],
    );
  }

  String _reading(double value) {
    return formatControlValue(
      value,
      type: control.controlType,
      unit: control.unit,
      options: decodeControlOptions(control.options),
    );
  }
}
