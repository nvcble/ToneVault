import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/enums/control_type.dart';
import '../data/control_draft.dart';
import '../data/control_number_text.dart';
import '../data/control_validator.dart';
import 'control_domain_fields.dart';
import 'control_options_field.dart';

/// Editable control fields, shared by the add and edit screens.
///
/// Which fields exist is decided by the chosen [ControlType] and nothing else -
/// never by the pedal the control belongs to. A clock knob has no bounds to
/// enter, a selection has positions instead of bounds, and only a numeric
/// control has a unit.
class ControlForm extends StatefulWidget {
  const ControlForm({
    required this.submitLabel,
    required this.onSubmit,
    this.initialDraft,
    this.isSaving = false,
    super.key,
  });

  final ControlDraft? initialDraft;
  final String submitLabel;

  /// Disables the form while a save is in flight, so one tap cannot become two
  /// controls.
  final bool isSaving;
  final ValueChanged<ControlDraft> onSubmit;

  @override
  State<ControlForm> createState() => _ControlFormState();
}

class _ControlFormState extends State<ControlForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _minController;
  late final TextEditingController _maxController;
  late final TextEditingController _stepController;
  late final TextEditingController _unitController;

  /// Starts empty on a new control: the type decides the rest of the form, so
  /// guessing it would put the wrong fields on screen.
  ControlType? _type;
  List<String> _options = const [];
  String? _optionsProblem;

  /// Carried through untouched. Where a control sits by default is set with the
  /// value editor that comes with configurations, not here.
  double? _defaultValue;

  @override
  void initState() {
    super.initState();
    final draft = widget.initialDraft;
    _type = draft?.type;
    _nameController = TextEditingController(text: draft?.name ?? '');
    _minController = TextEditingController(
      text: controlNumberText(draft?.minValue),
    );
    _maxController = TextEditingController(
      text: controlNumberText(draft?.maxValue),
    );
    _stepController = TextEditingController(
      text: controlNumberText(draft?.step),
    );
    _unitController = TextEditingController(text: draft?.unit ?? '');
    _options = draft?.options ?? const [];
    _defaultValue = draft?.defaultValue;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _minController.dispose();
    _maxController.dispose();
    _stepController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _changeType(ControlType type) {
    final defaults = ControlDraft.ofType(type);

    setState(() {
      _type = type;
      _minController.text = controlNumberText(defaults.minValue);
      _maxController.text = controlNumberText(defaults.maxValue);
      _stepController.text = controlNumberText(defaults.step);
      _unitController.clear();
      _optionsProblem = null;
      // Bounds, a unit and a default from the previous type mean nothing under
      // the new one: 0.5 is halfway on a clock knob and off on a toggle.
      _defaultValue = null;
    });
  }

  void _submit() {
    final type = _type;
    if (!(_formKey.currentState?.validate() ?? false) || type == null) {
      return;
    }

    final draft = _buildDraft(type).normalized();
    if (type == ControlType.selection) {
      // How many positions there are is not something any one field can report.
      final problem = ControlValidator.options(draft.options);
      if (problem != null) {
        setState(() => _optionsProblem = problem);
        return;
      }
    }

    widget.onSubmit(draft);
  }

  ControlDraft _buildDraft(ControlType type) {
    final defaults = ControlDraft.ofType(type);
    final showsBounds = showsControlBounds(type);

    return ControlDraft(
      name: _nameController.text,
      type: type,
      minValue: parseControlNumber(_minController.text) ?? defaults.minValue,
      maxValue: parseControlNumber(_maxController.text) ?? defaults.maxValue,
      // A hidden field has nothing to say, so the type's own step stands.
      step: showsBounds
          ? parseControlNumber(_stepController.text)
          : defaults.step,
      defaultValue: _defaultValue,
      unit: showsControlUnit(type) ? _unitController.text : null,
      options: _options,
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = _type;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          TextFormField(
            controller: _nameController,
            enabled: !widget.isSaving,
            decoration: const InputDecoration(
              labelText: 'Name',
              helperText: 'As it is printed on the pedal',
            ),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: ControlValidator.name,
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<ControlType>(
            initialValue: type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: [
              for (final option in ControlType.values)
                DropdownMenuItem<ControlType>(
                  value: option,
                  child: Text(option.label),
                ),
            ],
            validator: (selected) =>
                selected == null ? 'Pick how this control works.' : null,
            onChanged: widget.isSaving
                ? null
                : (selected) {
                    if (selected != null) {
                      _changeType(selected);
                    }
                  },
          ),
          // The rest of the form only makes sense once the type is known.
          if (type != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(_typeHelp(type), style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.md),
            ControlDomainFields(
              type: type,
              minController: _minController,
              maxController: _maxController,
              stepController: _stepController,
              unitController: _unitController,
              enabled: !widget.isSaving,
            ),
            if (type == ControlType.selection)
              ControlOptionsField(
                initialOptions: _options,
                enabled: !widget.isSaving,
                errorText: _optionsProblem,
                onChanged: (options) => setState(() {
                  _options = options;
                  _optionsProblem = null;
                }),
              ),
          ],
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: widget.isSaving ? null : _submit,
            child: widget.isSaving
                ? const SizedBox.square(
                    dimension: AppSpacing.lg,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }

  String _typeHelp(ControlType type) => switch (type) {
    ControlType.clock =>
      'Positions read like a clock face: 7:00 fully back, 12:00 straight up, '
          '5:00 fully forward.',
    ControlType.fader =>
      'A sliding fader, read as the number printed beside it.',
    ControlType.percentage => 'A number read out of 100.',
    ControlType.numeric => 'A plain number, in whatever unit the pedal uses.',
    ControlType.toggle => 'Two states, off or on.',
    ControlType.selection => 'Named positions, such as a mode switch.',
  };
}
