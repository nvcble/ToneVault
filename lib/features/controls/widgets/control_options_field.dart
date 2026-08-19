import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../data/control_validator.dart';

/// The position names of a selection control, in order.
///
/// One text field per position rather than one field holding a delimited list:
/// a position called "Bass / Mid" has to be typeable.
class ControlOptionsField extends StatefulWidget {
  const ControlOptionsField({
    required this.initialOptions,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
    super.key,
  });

  final List<String> initialOptions;
  final ValueChanged<List<String>> onChanged;

  /// Set by the form when the positions themselves are the problem, since a
  /// count cannot be reported by any single field's validator.
  final String? errorText;
  final bool enabled;

  @override
  State<ControlOptionsField> createState() => _ControlOptionsFieldState();
}

class _ControlOptionsFieldState extends State<ControlOptionsField> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = [
      for (final option in widget.initialOptions)
        TextEditingController(text: option),
    ];
    // A selection needs at least two positions, so start with two empty rows
    // instead of an empty list nobody would know to add to.
    while (_controllers.length < ControlValidator.minOptions) {
      _controllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Blank rows and whitespace are left in: dropping them is
  /// `ControlDraft.normalized`'s job, and doing it here would delete a row the
  /// user is halfway through clearing.
  void _report() {
    widget.onChanged([for (final controller in _controllers) controller.text]);
  }

  void _add() {
    setState(() => _controllers.add(TextEditingController()));
    _report();
  }

  void _removeAt(int index) {
    setState(() => _controllers.removeAt(index).dispose());
    _report();
  }

  @override
  Widget build(BuildContext context) {
    final canRemove = _controllers.length > ControlValidator.minOptions;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Positions',
        errorText: widget.errorText,
        helperText: 'In the order they appear on the pedal',
      ),
      child: Column(
        children: [
          for (var index = 0; index < _controllers.length; index++)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controllers[index],
                    enabled: widget.enabled,
                    decoration: InputDecoration(
                      hintText: 'Position ${index + 1}',
                    ),
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => _report(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: 'Remove position ${index + 1}',
                  onPressed: widget.enabled && canRemove
                      ? () => _removeAt(index)
                      : null,
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed:
                  widget.enabled &&
                      _controllers.length < ControlValidator.maxOptions
                  ? _add
                  : null,
              icon: const Icon(Icons.add),
              label: const Text('Add position'),
            ),
          ),
        ],
      ),
    );
  }
}
