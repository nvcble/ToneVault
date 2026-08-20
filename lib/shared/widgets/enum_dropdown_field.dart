import 'package:flutter/material.dart';

/// A form field that picks one value of an enum.
///
/// Enum-backed fields differ only in their options and their label, so they share
/// one field rather than a near-identical block each. Nothing here knows which
/// enum it is showing: the caller says how to label a value, which is the only
/// part the enum itself decides.
///
/// Kept for tracking: `ControlForm` spells its own `ControlType` dropdown out
/// inline. It is left as it is rather than changed under working, tested code;
/// anything new uses this instead of adding another copy.
class EnumDropdownField<T extends Enum> extends StatelessWidget {
  const EnumDropdownField({
    required this.label,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.emptyMessage,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final String label;
  final T? value;
  final List<T> values;
  final String Function(T) labelOf;

  /// Reported when nothing is picked. Every such field stands for a fact about
  /// the thing being described, so none of them can be left empty.
  final String emptyMessage;
  final ValueChanged<T> onChanged;

  /// False while a save is in flight, so one tap cannot become two writes.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final option in values)
          DropdownMenuItem<T>(value: option, child: Text(labelOf(option))),
      ],
      validator: (selected) => selected == null ? emptyMessage : null,
      onChanged: enabled
          ? (selected) {
              if (selected != null) {
                onChanged(selected);
              }
            }
          : null,
    );
  }
}
