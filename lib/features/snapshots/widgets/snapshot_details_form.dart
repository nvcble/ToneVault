import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../data/snapshot_draft.dart';
import '../data/snapshot_validator.dart';

/// What a snapshot is called, and what it says about the day.
///
/// Only these two things: where each pedal was set was recorded at capture and
/// is not up for editing, which is what makes a snapshot a record rather than a
/// guess. Taking a new one is `CaptureSnapshotForm`'s job, since that has to
/// ask about every pedal on the rig.
class SnapshotDetailsForm extends StatefulWidget {
  const SnapshotDetailsForm({
    required this.initialDraft,
    required this.onSubmit,
    this.isSaving = false,
    super.key,
  });

  final SnapshotDraft initialDraft;

  /// Disables the form while a save is in flight, so one tap cannot become two
  /// writes.
  final bool isSaving;
  final ValueChanged<SnapshotDraft> onSubmit;

  @override
  State<SnapshotDetailsForm> createState() => _SnapshotDetailsFormState();
}

class _SnapshotDetailsFormState extends State<SnapshotDetailsForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialDraft.name);
    _notesController = TextEditingController(
      text: widget.initialDraft.notes ?? '',
    );
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
      SnapshotDraft(
        name: _nameController.text,
        notes: _notesController.text,
      ).normalized(),
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
            enabled: !widget.isSaving,
            decoration: const InputDecoration(
              labelText: 'Name',
              helperText: 'Such as "Easter 2026" or "Friday rehearsal"',
            ),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: SnapshotValidator.name,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _notesController,
            enabled: !widget.isSaving,
            decoration: const InputDecoration(
              labelText: 'Notes',
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
                : const Text('Save changes'),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'The date it was taken, and where each pedal was set, stay as they '
            'were recorded.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
