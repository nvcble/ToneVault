import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/database/app_database.dart';
import '../../../core/values/control_value_label.dart';
import '../../controls/data/control_number_text.dart';

/// Sets a control that is read as a plain number, such as a delay time.
///
/// Typed rather than slid: ranges like 20–2000 ms are too wide to place a
/// fingertip on, and the number printed next to the knob is what gets written
/// down anyway. Reports null while the field holds something that is not a
/// number, so the sheet can keep Save out of reach instead of storing a guess.
class NumericValueEditor extends StatefulWidget {
  const NumericValueEditor({
    required this.control,
    required this.initialValue,
    required this.onChanged,
    this.errorText,
    super.key,
  });

  final PedalControl control;

  /// Read once. Afterwards the field is the source of truth, so typing is never
  /// interrupted by a rebuild.
  final double? initialValue;

  final ValueChanged<double?>? onChanged;
  final String? errorText;

  @override
  State<NumericValueEditor> createState() => _NumericValueEditorState();
}

class _NumericValueEditorState extends State<NumericValueEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: controlNumberText(widget.initialValue),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final control = widget.control;
    final onChanged = widget.onChanged;

    return TextField(
      controller: _controller,
      enabled: onChanged != null,
      autofocus: true,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))],
      decoration: InputDecoration(
        labelText: control.name,
        suffixText: control.unit,
        helperText:
            '${formatControlNumber(control.minValue)} to '
            '${formatControlNumber(control.maxValue)}',
        errorText: widget.errorText,
      ),
      onChanged: (text) => onChanged?.call(parseControlNumber(text)),
    );
  }
}
