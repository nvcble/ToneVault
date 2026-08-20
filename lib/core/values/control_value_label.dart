import '../enums/control_type.dart';
import 'clock_value.dart';

/// Turns stored control values into the text shown on screen.
///
/// Values are always plain numbers inside their control's own domain, so every
/// per-type reading rule lives here rather than in the widgets. That is what
/// lets a clock knob, a percentage and a mode switch be listed together without
/// the list knowing which is which.
String formatControlValue(
  double value, {
  required ControlType type,
  String? unit,
  List<String> options = const [],
}) {
  return switch (type) {
    // Clock and percentage carry their own notation, so a stored unit is
    // ignored for them rather than doubled up.
    ControlType.clock => ClockValue.fromNormalized(value).label,
    ControlType.percentage => '${formatControlNumber(value)}%',
    // A fader reads as the number printed beside it, with the pedal's own unit
    // when it has one.
    ControlType.fader ||
    ControlType.numeric => _withUnit(formatControlNumber(value), unit),
    ControlType.toggle => value >= 0.5 ? 'On' : 'Off',
    ControlType.selection => _optionLabel(value, options),
  };
}

/// The span a control accepts, for listing what a control is rather than where
/// it is currently set.
String formatControlRange({
  required ControlType type,
  required double minValue,
  required double maxValue,
  String? unit,
  List<String> options = const [],
}) {
  return switch (type) {
    ControlType.clock =>
      '${ClockValue.fromNormalized(minValue).label} – '
          '${ClockValue.fromNormalized(maxValue).label}',
    ControlType.percentage =>
      '${formatControlNumber(minValue)} – ${formatControlNumber(maxValue)}%',
    ControlType.fader || ControlType.numeric => _withUnit(
      '${formatControlNumber(minValue)} – ${formatControlNumber(maxValue)}',
      unit,
    ),
    ControlType.toggle => 'Off / On',
    ControlType.selection =>
      options.isEmpty ? 'No positions yet' : options.join(' / '),
  };
}

/// A control value without a pointless trailing `.0`, since most of them are
/// whole numbers.
String formatControlNumber(double value) {
  // Two decimals is finer than any pedal marking, and rounding here keeps
  // floating point noise such as 0.30000000000000004 off the screen.
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
}

String _withUnit(String text, String? unit) =>
    unit == null ? text : '$text $unit';

String _optionLabel(double value, List<String> options) {
  final index = value.round();
  if (index >= 0 && index < options.length) {
    return options[index];
  }
  // A control whose option list was shortened after a value was stored still
  // has to read as something.
  return 'Position ${index + 1}';
}
