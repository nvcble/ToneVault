import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/enums/signal_block_type.dart';
import '../../../shared/widgets/enum_dropdown_field.dart';
import '../data/signal_block_draft.dart';
import '../data/signal_block_validator.dart';

/// Editable fields of one block of a chain.
///
/// Owns field state only: it hands a [SignalBlockDraft] to [onSubmit] and knows
/// nothing about saving, so the screen above it stays about navigation.
///
/// The pedal in the block is not asked for here. It has a picker of its own on
/// the block's menu, and a second one on this form would be two ways to do the
/// same thing - as would a position, which is dragged.
class SignalBlockForm extends StatefulWidget {
  const SignalBlockForm({
    required this.initialDraft,
    required this.onSubmit,
    this.isSaving = false,
    super.key,
  });

  final SignalBlockDraft initialDraft;

  /// Disables the form while a save is in flight, so one tap cannot become two
  /// writes.
  final bool isSaving;
  final ValueChanged<SignalBlockDraft> onSubmit;

  @override
  State<SignalBlockForm> createState() => _SignalBlockFormState();
}

class _SignalBlockFormState extends State<SignalBlockForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _notesController;
  late SignalBlockType _blockType;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    final draft = widget.initialDraft;
    _labelController = TextEditingController(text: draft.label ?? '');
    _notesController = TextEditingController(text: draft.notes ?? '');
    _blockType = draft.blockType;
    _isEnabled = draft.isEnabled;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    widget.onSubmit(
      SignalBlockDraft(
        blockType: _blockType,
        label: _labelController.text,
        notes: _notesController.text,
        isEnabled: _isEnabled,
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
          EnumDropdownField<SignalBlockType>(
            label: 'Block',
            value: _blockType,
            // Enum order, which follows a conventional chain, so the list reads
            // the way a board is built.
            values: SignalBlockType.values,
            labelOf: (type) => type.label,
            emptyMessage: 'Choose what this block is for.',
            enabled: !widget.isSaving,
            onChanged: (type) => setState(() => _blockType = type),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _labelController,
            decoration: const InputDecoration(
              labelText: 'Label',
              helperText: 'Optional, such as "Always on" or "Solo boost"',
            ),
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            validator: SignalBlockValidator.label,
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile(
            value: _isEnabled,
            title: const Text('In the chain'),
            // Worth saying, because this switch is not how a block comes off the
            // board: a bypassed block keeps its place in the chain.
            subtitle: Text(
              _isEnabled
                  ? 'Passing signal'
                  : 'Bypassed, but still on the board',
            ),
            contentPadding: EdgeInsets.zero,
            onChanged: widget.isSaving
                ? null
                : (value) => setState(() => _isEnabled = value),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              helperText: 'Optional, such as what this block is for live',
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
                : const Text('Save changes'),
          ),
        ],
      ),
    );
  }
}
