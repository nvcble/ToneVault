import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/enums/control_type.dart';
import '../../../core/values/control_options.dart';

/// Sets a control that is in one state or another: a switch or a mode selector.
///
/// The positions are the ones the control itself declares, so a three-way
/// selector nobody anticipated gets three radios without any per-pedal code.
class ChoiceValueEditor extends StatelessWidget {
  const ChoiceValueEditor({
    required this.control,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final PedalControl control;
  final double value;

  /// Null while a save is in flight, which leaves the choices visible but
  /// untouchable.
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    return control.controlType == ControlType.toggle
        ? _buildSwitch()
        : _buildOptions(context);
  }

  Widget _buildSwitch() {
    final isOn = value >= 0.5;

    return SwitchListTile(
      title: Text(isOn ? 'On' : 'Off'),
      value: isOn,
      onChanged: onChanged == null
          ? null
          : (turnedOn) =>
                onChanged!(turnedOn ? control.maxValue : control.minValue),
    );
  }

  Widget _buildOptions(BuildContext context) {
    final options = decodeControlOptions(control.options);
    if (options.isEmpty) {
      // Only reachable through a hand-edited row: the control form will not save
      // a selection without positions.
      return const ListTile(
        title: Text('This control has no positions to choose from.'),
      );
    }

    return RadioGroup<int>(
      groupValue: value.round(),
      onChanged: (index) {
        // A radio can report null when it is toggled off; these are not
        // toggleable, so there is nothing to store in that case.
        if (index != null) {
          onChanged?.call(index.toDouble());
        }
      },
      child: Column(
        children: [
          for (final (index, option) in options.indexed)
            RadioListTile<int>(
              value: index,
              title: Text(option),
              enabled: onChanged != null,
            ),
        ],
      ),
    );
  }
}
