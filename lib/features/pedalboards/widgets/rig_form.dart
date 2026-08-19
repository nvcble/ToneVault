import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../data/pedalboard_draft.dart';
import '../data/pedalboard_validator.dart';

/// Editable rig fields, shared by the add and edit screens.
///
/// Owns field state only: it hands a [PedalboardDraft] to [onSubmit] and knows
/// nothing about saving, so both screens reuse it unchanged.
class RigForm extends StatefulWidget {
  const RigForm({
    required this.submitLabel,
    required this.onSubmit,
    this.initialDraft,
    this.isSaving = false,
    super.key,
  });

  final PedalboardDraft? initialDraft;
  final String submitLabel;

  /// Disables the form while a save is in flight, so one tap cannot become two
  /// rigs.
  final bool isSaving;
  final ValueChanged<PedalboardDraft> onSubmit;

  @override
  State<RigForm> createState() => _RigFormState();
}

class _RigFormState extends State<RigForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final draft = widget.initialDraft;
    _nameController = TextEditingController(text: draft?.name ?? '');
    _descriptionController = TextEditingController(
      text: draft?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    widget.onSubmit(
      PedalboardDraft(
        name: _nameController.text,
        description: _descriptionController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              helperText: 'Such as "Hybrid Worship Rig" or "Home Practice"',
            ),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: PedalboardValidator.name,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              helperText: 'Optional',
              alignLabelWithHint: true,
            ),
            minLines: 3,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
          ),
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
}
