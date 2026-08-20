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
  const PedalFormScreen({this.pedalId, this.hostPedalId, super.key});

  final int? pedalId;

  /// The multi-effects unit the new pedal belongs inside, when it is a stomp or
  /// a block rather than a pedal of its own. Ignored on an edit, where the pedal
  /// already knows where it sits.
  final int? hostPedalId;

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

  /// Goes to wherever the pedal now lives: its own screen after an edit, and
  /// after adding one either the list it joined or the unit it went inside.
  void _leave() {
    final pedalId = widget.pedalId;
    if (pedalId != null) {
      context.go(Routes.pedalDetail(pedalId));
      return;
    }

    final hostPedalId = widget.hostPedalId;
    context.go(
      hostPedalId == null ? Routes.pedals : Routes.pedalDetail(hostPedalId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: _isEditing ? _buildEditBody(widget.pedalId!) : _buildAddBody(),
    );
  }

  String get _title {
    if (_isEditing) {
      return 'Edit pedal';
    }
    // Says which unit it is going into, so the form does not look like it is
    // about to add another pedal to the inventory.
    return widget.hostPedalId == null ? 'Add pedal' : 'Add to this unit';
  }

  Widget _buildAddBody() {
    return PedalForm(
      submitLabel: 'Add pedal',
      hostPedalId: widget.hostPedalId,
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
              // Kept as it is: an edit never moves a stomp to another unit.
              hostPedalId: pedal.hostPedalId,
              submitLabel: 'Save changes',
              isSaving: _isSaving,
              onSubmit: _save,
            );
          },
        );
  }
}
