import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/pedal_draft.dart';
import '../providers/pedal_editor.dart';
import '../providers/pedal_providers.dart';
import '../widgets/pedal_form.dart';

/// Adds a pedal, or edits [pedalId] when one is given.
class PedalFormScreen extends ConsumerStatefulWidget {
  const PedalFormScreen({this.pedalId, super.key});

  final int? pedalId;

  @override
  ConsumerState<PedalFormScreen> createState() => _PedalFormScreenState();
}

class _PedalFormScreenState extends ConsumerState<PedalFormScreen> {
  bool _isSaving = false;

  bool get _isEditing => widget.pedalId != null;

  Future<void> _save(PedalDraft draft) async {
    setState(() => _isSaving = true);

    try {
      await ref.read(pedalEditorProvider).save(draft, pedalId: widget.pedalId);
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

  /// Goes to wherever the pedal now lives: its own screen after an edit, the
  /// list after adding one.
  void _leave() {
    final pedalId = widget.pedalId;
    context.go(pedalId == null ? Routes.pedals : Routes.pedalDetail(pedalId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit pedal' : 'Add pedal')),
      body: _isEditing ? _buildEditBody(widget.pedalId!) : _buildAddBody(),
    );
  }

  Widget _buildAddBody() {
    return PedalForm(
      submitLabel: 'Add pedal',
      isSaving: _isSaving,
      onSubmit: _save,
    );
  }

  Widget _buildEditBody(int pedalId) {
    return ref
        .watch(pedalProvider(pedalId))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: 'Could not open this pedal',
            message: failureMessage(error),
          ),
          data: (pedal) {
            if (pedal == null) {
              return const EmptyState(
                icon: Icons.help_outline,
                title: 'That pedal no longer exists',
              );
            }

            return PedalForm(
              // Rebuilding for a different pedal has to start the fields over; the
              // same pedal keeps whatever is half-typed.
              key: ValueKey<int>(pedal.id),
              initialDraft: PedalDraft.fromPedal(pedal),
              submitLabel: 'Save changes',
              isSaving: _isSaving,
              onSubmit: _save,
            );
          },
        );
  }
}
