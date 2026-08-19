import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/control_draft.dart';
import '../providers/control_editor.dart';
import '../providers/control_providers.dart';
import '../widgets/control_form.dart';

/// Adds a control to [pedalId], or edits [controlId] when one is given.
class ControlFormScreen extends ConsumerStatefulWidget {
  const ControlFormScreen({required this.pedalId, this.controlId, super.key});

  final int pedalId;
  final int? controlId;

  @override
  ConsumerState<ControlFormScreen> createState() => _ControlFormScreenState();
}

class _ControlFormScreenState extends ConsumerState<ControlFormScreen> {
  bool _isSaving = false;

  bool get _isEditing => widget.controlId != null;

  Future<void> _save(ControlDraft draft) async {
    setState(() => _isSaving = true);

    try {
      await ref
          .read(controlEditorProvider)
          .save(draft, pedalId: widget.pedalId, controlId: widget.controlId);
      if (mounted) {
        _leave();
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        showFailureSnackBar(context, error);
      }
    }
  }

  /// Both adding and editing end up back on the pedal, which is where the
  /// controls are listed.
  void _leave() => context.go(Routes.pedalDetail(widget.pedalId));

  Future<void> _confirmDelete(int controlId) async {
    final name =
        ref.read(controlProvider(controlId)).valueOrNull?.name ??
        'this control';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove control?'),
        content: Text(
          'Every configuration of this pedal loses the value it had stored for '
          '$name. Its own history entries are kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await ref.read(controlEditorProvider).delete(controlId);
      if (mounted) {
        _leave();
      }
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controlId = widget.controlId;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit control' : 'Add control'),
        actions: controlId == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove',
                  onPressed: _isSaving ? null : () => _confirmDelete(controlId),
                ),
              ],
      ),
      body: controlId == null ? _buildAddBody() : _buildEditBody(controlId),
    );
  }

  Widget _buildAddBody() {
    return ControlForm(
      submitLabel: 'Add control',
      isSaving: _isSaving,
      onSubmit: _save,
    );
  }

  Widget _buildEditBody(int controlId) {
    return ref
        .watch(controlProvider(controlId))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: 'Could not open this control',
            message: failureMessage(error),
          ),
          data: (control) {
            if (control == null) {
              return const EmptyState(
                icon: Icons.help_outline,
                title: 'That control no longer exists',
              );
            }

            return ControlForm(
              // A different control has to start the fields over; the same one
              // keeps whatever is half-typed.
              key: ValueKey<int>(control.id),
              initialDraft: ControlDraft.fromControl(control),
              submitLabel: 'Save changes',
              isSaving: _isSaving,
              onSubmit: _save,
            );
          },
        );
  }
}
