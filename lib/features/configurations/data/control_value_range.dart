import '../../../core/database/app_database.dart';
import '../../../core/enums/control_type.dart';

/// The most divisions a slider is given before it is treated as continuous.
///
/// Past this the notches are closer together than a fingertip, so snapping
/// stops helping and only makes the reading jump.
const int maxSliderDivisions = 200;

/// Where the editor for [control] opens when nothing has been stored yet.
///
/// Nothing is written until the user saves, so this is a starting point rather
/// than a position the configuration claims. A knob opens at its declared
/// default, or halfway if it has none; a switch opens off, and a selection on
/// its first position.
double startingValueFor(PedalControl control) {
  final fallback = switch (control.controlType) {
    ControlType.toggle || ControlType.selection => control.minValue,
    _ => control.minValue + (control.maxValue - control.minValue) / 2,
  };

  return control.defaultValue ?? fallback;
}

/// How many notches a slider for [control] gets, or null to slide freely.
///
/// Derived from the control's own step, so a clock knob snaps to the half hour
/// and a percentage to whole numbers without either being a special case.
int? sliderDivisionsFor(PedalControl control) {
  final step = control.step;
  if (step == null || step <= 0) {
    return null;
  }

  final divisions = ((control.maxValue - control.minValue) / step).round();
  return divisions >= 1 && divisions <= maxSliderDivisions ? divisions : null;
}
