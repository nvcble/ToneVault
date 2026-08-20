import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../data/patch_draft.dart';

/// A name and notes, which is all a patch or a scene is entered with.
///
/// One form for both, because `SceneDraft` is a `PatchDraft`: only the words
/// change, and the caller passes those. What is inside a scene is not here - the
/// pedals it uses and where their knobs sit are set on the scene's own screen,
/// one edit at a time.
class PatchNameForm extends StatefulWidget {
  const PatchNameForm({
    required this.submitLabel,
    required this.onSubmit,
    required this.validator,
    required this.nameHelper,
    this.initialDraft,
    this.footnote,
    this.isSaving = false,
    super.key,
  });

  final PatchDraft? initialDraft;
  final String submitLabel;

  /// The rule the name is held to, which is the same one the repository applies.
  final String? Function(String?) validator;
  final String nameHelper;

  /// Shown under a new one only: what the user gets by saving it.
  final String? footnote;

  /// Disables the form while a save is in flight, so one tap cannot become two
  /// patches.
  final bool isSaving;
  final ValueChanged<PatchDraft> onSubmit;

  @override
  State<PatchNameForm> createState() => _PatchNameFormState();
}

class _PatchNameFormState extends State<PatchNameForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final draft = widget.initialDraft;
    _nameController = TextEditingController(text: draft?.name ?? '');
    _notesController = TextEditingController(text: draft?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    widget.onSubmit(
      PatchDraft(
        name: _nameController.text,
        notes: _notesController.text,
      ).normalized(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final footnote = widget.footnote;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          TextFormField(
            controller: _nameController,
            enabled: !widget.isSaving,
            decoration: InputDecoration(
              labelText: 'Name',
              helperText: widget.nameHelper,
            ),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: widget.validator,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _notesController,
            enabled: !widget.isSaving,
            decoration: const InputDecoration(
              labelText: 'Notes',
              helperText: 'Optional',
            ),
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
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
          if (footnote != null && widget.initialDraft == null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(footnote, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
