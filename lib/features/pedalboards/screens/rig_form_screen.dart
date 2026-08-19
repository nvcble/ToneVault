import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/pedalboard_draft.dart';
import '../providers/pedalboard_providers.dart';
import '../providers/rig_editor.dart';
import '../widgets/rig_form.dart';

/// Adds a rig, or edits [pedalboardId] when one is given.
class RigFormScreen extends ConsumerStatefulWidget {
  const RigFormScreen({this.pedalboardId, super.key});

  final int? pedalboardId;

  @override
  ConsumerState<RigFormScreen> createState() => _RigFormScreenState();
}

class _RigFormScreenState extends ConsumerState<RigFormScreen> {
  bool _isSaving = false;

  bool get _isEditing => widget.pedalboardId != null;

  Future<void> _save(PedalboardDraft draft) async {
    setState(() => _isSaving = true);

    try {
      await ref
          .read(rigEditorProvider)
          .save(draft, pedalboardId: widget.pedalboardId);
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

  /// Goes to wherever the rig now lives: its own screen after an edit, the list
  /// after adding one.
  void _leave() {
    final pedalboardId = widget.pedalboardId;
    context.go(
      pedalboardId == null ? Routes.rigs : Routes.rigDetail(pedalboardId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit rig' : 'Add rig')),
      body: _isEditing ? _buildEditBody(widget.pedalboardId!) : _buildAddBody(),
    );
  }

  Widget _buildAddBody() {
    return RigForm(
      submitLabel: 'Add rig',
      isSaving: _isSaving,
      onSubmit: _save,
    );
  }

  Widget _buildEditBody(int pedalboardId) {
    return ref
        .watch(pedalboardProvider(pedalboardId))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: 'Could not open this rig',
            message: failureMessage(error),
          ),
          data: (pedalboard) {
            if (pedalboard == null) {
              return const EmptyState(
                icon: Icons.help_outline,
                title: 'That rig no longer exists',
              );
            }

            return RigForm(
              // Rebuilding for a different rig has to start the fields over; the
              // same rig keeps whatever is half-typed.
              key: ValueKey<int>(pedalboard.id),
              initialDraft: PedalboardDraft.fromPedalboard(pedalboard),
              submitLabel: 'Save changes',
              isSaving: _isSaving,
              onSubmit: _save,
            );
          },
        );
  }
}
