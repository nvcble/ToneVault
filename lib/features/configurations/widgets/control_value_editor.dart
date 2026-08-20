import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/enums/control_type.dart';
import '../data/control_value_range.dart';
import 'choice_value_editor.dart';
import 'knob_value_editor.dart';
import 'numeric_value_editor.dart';
import 'slider_value_editor.dart';

/// Picks the way [control] is set, from the control's own type.
///
/// This is the only place that maps a type to an input, and it maps the *type* -
/// never the pedal or the control's name. A pedal added tomorrow with a knob
/// nobody has heard of is editable the moment its control row exists.
class ControlValueEditor extends StatelessWidget {
  const ControlValueEditor({
    required this.control,
    required this.value,
    required this.onChanged,
    this.errorText,
    super.key,
  });

  final PedalControl control;

  /// Null when the field holds something unusable, which only a typed editor
  /// can produce.
  final double? value;

  /// Null disables the editor.
  final ValueChanged<double?>? onChanged;

  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final problem = errorText;

    // The typed editor shows a problem inside its own field decoration; the
    // others have nowhere to put one, which only comes up for a value that was
    // out of range before the sheet opened.
    if (problem == null || control.controlType == ControlType.numeric) {
      return _buildEditor();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildEditor(),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Text(
            problem,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditor() {
    // A callback that tolerates null is fine where a non-null value is reported,
    // so the sliders and choices below hand theirs straight through.
    return switch (control.controlType) {
      // A clock knob is turned rather than slid, since a pointer on a face is
      // how the position is read off the pedal. It shared the slider below until
      // the knob existed.
      ControlType.clock => KnobValueEditor(
        control: control,
        value: value ?? startingValueFor(control),
        onChanged: onChanged,
      ),
      ControlType.fader || ControlType.percentage => SliderValueEditor(
        control: control,
        value: value ?? startingValueFor(control),
        onChanged: onChanged,
      ),
      ControlType.numeric => NumericValueEditor(
        control: control,
        initialValue: value,
        onChanged: onChanged,
        errorText: errorText,
      ),
      ControlType.toggle || ControlType.selection => ChoiceValueEditor(
        control: control,
        value: value ?? startingValueFor(control),
        onChanged: onChanged,
      ),
    };
  }
}
