import '../../../core/values/control_value_label.dart';

/// Text field input for the numeric parts of a control definition.
///
/// Kept next to the draft rather than in a widget: the form and its field
/// widgets both need to read and write the same text, and neither owns it.
double? parseControlNumber(String? value) =>
    double.tryParse(value?.trim() ?? '');

/// Empty for a field with nothing in it, so a cleared bound stays cleared.
String controlNumberText(double? value) =>
    value == null ? '' : formatControlNumber(value);
