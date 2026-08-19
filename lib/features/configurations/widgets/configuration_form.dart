import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../data/configuration_draft.dart';
import '../data/configuration_validator.dart';

/// A configuration's name and notes, shared by the add and edit screens.
///
/// Where the knobs go is not here: the settings themselves are edited one
/// control at a time on the configuration's own screen, so naming a
/// configuration stays a two-field job.
class ConfigurationForm extends StatefulWidget {
  const ConfigurationForm({
    required this.submitLabel,
    required this.onSubmit,
    this.initialDraft,
    this.isSaving = false,
    super.key,
  });

  final ConfigurationDraft? initialDraft;
  final String submitLabel;

  /// Disables the form while a save is in flight, so one tap cannot become two
  /// configurations.
  final bool isSaving;
  final ValueChanged<ConfigurationDraft> onSubmit;

  @override
  State<ConfigurationForm> createState() => _ConfigurationFormState();
}

class _ConfigurationFormState extends State<ConfigurationForm> {
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
      ConfigurationDraft(
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
              helperText: 'What this setting is for, such as Worship Lead',
            ),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: ConfigurationValidator.name,
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
          if (widget.initialDraft == null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'The new configuration starts at each control\'s default position, '
              'and every control without one starts out unset.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
