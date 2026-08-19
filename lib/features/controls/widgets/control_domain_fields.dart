import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/enums/control_type.dart';
import '../data/control_number_text.dart';
import '../data/control_validator.dart';

/// Whether a control of [type] has bounds and a step the user enters.
///
/// Clock and toggle domains are fixed by the type, and a selection's are
/// derived from its positions.
bool showsControlBounds(ControlType type) =>
    !type.hasFixedDomain && type != ControlType.selection;

/// Only a numeric control has a unit. Clock and percentage carry their own
/// notation, and a toggle or selection reads as words.
bool showsControlUnit(ControlType type) => type == ControlType.numeric;

/// The minimum, maximum, step and unit of a control, for the types that have
/// them.
///
/// The controllers belong to the form; this widget only lays the fields out and
/// validates them. Being nested is fine: `TextFormField` finds the enclosing
/// `Form` through the tree.
class ControlDomainFields extends StatelessWidget {
  const ControlDomainFields({
    required this.type,
    required this.minController,
    required this.maxController,
    required this.stepController,
    required this.unitController,
    required this.enabled,
    super.key,
  });

  final ControlType type;
  final TextEditingController minController;
  final TextEditingController maxController;
  final TextEditingController stepController;
  final TextEditingController unitController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showsControlBounds(type)) ...[
          Row(
            children: [
              Expanded(
                child: _numberField(minController, 'Minimum', _validateMin),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _numberField(maxController, 'Maximum', _validateMax),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _numberField(stepController, 'Step', _validateStep, optional: true),
          const SizedBox(height: AppSpacing.md),
        ],
        if (showsControlUnit(type)) ...[
          TextFormField(
            controller: unitController,
            enabled: enabled,
            decoration: const InputDecoration(
              labelText: 'Unit',
              helperText: 'Optional, such as ms or dB',
            ),
            validator: ControlValidator.unit,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label,
    FormFieldValidator<String> validator, {
    bool optional = false,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        helperText: optional ? 'Optional' : null,
      ),
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      validator: validator,
    );
  }

  String? _validateMin(String? value) =>
      ControlValidator.bound(parseControlNumber(value), label: 'minimum');

  String? _validateMax(String? value) {
    final maxValue = parseControlNumber(value);
    final problem = ControlValidator.bound(maxValue, label: 'maximum');
    final minValue = parseControlNumber(minController.text);
    if (problem != null || minValue == null) {
      // A minimum that does not parse is reported by its own field.
      return problem;
    }
    return ControlValidator.domain(minValue: minValue, maxValue: maxValue!);
  }

  String? _validateStep(String? value) {
    final minValue = parseControlNumber(minController.text);
    final maxValue = parseControlNumber(maxController.text);
    if (minValue == null || maxValue == null || maxValue <= minValue) {
      // Nothing useful to say about a step until the range it divides is valid.
      return null;
    }
    return ControlValidator.step(
      parseControlNumber(value),
      minValue: minValue,
      maxValue: maxValue,
    );
  }
}
