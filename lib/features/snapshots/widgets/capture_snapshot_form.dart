import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/daos/pedalboard_dao.dart';
import '../data/snapshot_draft.dart';
import '../data/snapshot_validator.dart';
import 'pedal_configuration_choice.dart';

/// What the form hands back: the snapshot's own details, and which configuration
/// each pedal was on. A pedal left on "Not recorded" is absent from the map.
typedef SnapshotCapture = ({
  SnapshotDraft draft,
  Map<int, int> configurationChoices,
});

/// Names a snapshot and asks where each pedal on the rig was set.
///
/// Owns field state only: it hands a [SnapshotCapture] to [onSubmit] and knows
/// nothing about saving.
class CaptureSnapshotForm extends StatefulWidget {
  const CaptureSnapshotForm({
    required this.chain,
    required this.onSubmit,
    this.isSaving = false,
    super.key,
  });

  /// The rig in signal order, which is the order the pedals are asked about.
  final List<ChainSlot> chain;

  /// Disables the form while a save is in flight, so one tap cannot become two
  /// snapshots.
  final bool isSaving;
  final ValueChanged<SnapshotCapture> onSubmit;

  @override
  State<CaptureSnapshotForm> createState() => _CaptureSnapshotFormState();
}

class _CaptureSnapshotFormState extends State<CaptureSnapshotForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  /// Pedal id to the configuration chosen for it. A pedal only appears here once
  /// something has been picked for it.
  final Map<int, int> _choices = {};

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _choose(int pedalId, int? configurationId) {
    setState(() {
      if (configurationId == null) {
        _choices.remove(pedalId);
      } else {
        _choices[pedalId] = configurationId;
      }
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    widget.onSubmit((
      draft: SnapshotDraft(
        name: _nameController.text,
        notes: _notesController.text,
      ),
      // A copy: the form goes on holding its own map after handing this over.
      configurationChoices: Map<int, int>.of(_choices),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          TextFormField(
            controller: _nameController,
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
          Text('Where each pedal was set', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'The readings are copied as they are now, and stay as they were '
            'whatever you change later.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final (position, entry) in widget.chain.indexed)
            PedalConfigurationChoice(
              key: ValueKey<int>(entry.pedal.id),
              pedal: entry.pedal,
              position: position,
              configurationId: _choices[entry.pedal.id],
              onChanged: (configurationId) =>
                  _choose(entry.pedal.id, configurationId),
            ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            onPressed: widget.isSaving ? null : _submit,
            child: widget.isSaving
                ? const SizedBox.square(
                    dimension: AppSpacing.lg,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Take snapshot'),
          ),
        ],
      ),
    );
  }
}
