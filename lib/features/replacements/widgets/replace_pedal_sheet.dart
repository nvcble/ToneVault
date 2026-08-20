import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/action_row.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../pedals/providers/pedal_providers.dart';
import '../data/replacement_choices.dart';
import '../providers/replacement_providers.dart';

/// Records which pedal took over from [pedal].
///
/// A sheet rather than a screen: this is one choice and one sentence, and the
/// pedal being retired stays in view behind it. The replacement is picked from
/// the inventory rather than typed, so a swap always names two pedals the user
/// actually owns.
class ReplacePedalSheet extends ConsumerStatefulWidget {
  const ReplacePedalSheet({required this.pedal, super.key});

  final Pedal pedal;

  @override
  ConsumerState<ReplacePedalSheet> createState() => _ReplacePedalSheetState();
}

class _ReplacePedalSheetState extends ConsumerState<ReplacePedalSheet> {
  final TextEditingController _reasonController = TextEditingController();
  int? _replacementId;
  String? _problem;
  bool _isSaving = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  /// Blank means the user chose not to explain themselves, which the history
  /// records as no reason rather than as an empty one.
  String? get _reason {
    final reason = _reasonController.text.trim();
    return reason.isEmpty ? null : reason;
  }

  Future<void> _save() async {
    final replacementId = _replacementId;
    if (replacementId == null) {
      setState(() => _problem = 'Choose the pedal that took over.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref
          .read(replacementRepositoryProvider)
          .replacePedal(
            outgoingPedalId: widget.pedal.id,
            incomingPedalId: replacementId,
            reason: _reason,
          );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      // A failed swap leaves the sheet open, so the choice is not lost with it.
      if (mounted) {
        setState(() => _isSaving = false);
        showFailureSnackBar(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final candidates = replacementCandidates(
      outgoing: widget.pedal,
      pedals: ref.watch(pedalListProvider).valueOrNull ?? const [],
    );

    return Padding(
      // Clears the keyboard the reason field brings up.
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.lg,
        bottom: AppSpacing.md + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Replace ${widget.pedal.name}',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'It stays in your inventory, marked Replaced, with its controls, '
            'configurations and history intact.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (candidates.isEmpty)
            _NothingToPick(theme: theme)
          else
            _buildPicker(candidates),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _reasonController,
            enabled: !_isSaving,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Why the change?',
              hintText: 'Wanted the amp models',
              helperText: 'Optional, and kept in this pedal\'s history',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildActions(candidates.isEmpty),
        ],
      ),
    );
  }

  Widget _buildPicker(List<Pedal> candidates) {
    return DropdownButtonFormField<int>(
      initialValue: _replacementId,
      decoration: InputDecoration(
        labelText: 'Replaced by',
        errorText: _problem,
      ),
      items: [
        for (final candidate in candidates)
          DropdownMenuItem<int>(
            value: candidate.id,
            child: Text(candidate.name, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: _isSaving
          ? null
          : (selected) => setState(() {
              _replacementId = selected;
              _problem = null;
            }),
    );
  }

  // The plain Row this replaced could not lay out: the app theme's
  // FilledButton has an infinite minimum width. See ActionRow.
  Widget _buildActions(bool nothingToPick) {
    return ActionRow(
      children: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving || nothingToPick ? null : _save,
          child: const Text('Replace'),
        ),
      ],
    );
  }
}

/// Shown instead of the picker when the inventory holds nothing that could take
/// over, since the swap names a pedal the user owns.
class _NothingToPick extends StatelessWidget {
  const _NothingToPick({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Add the pedal that took over to your inventory first, then replace this '
      'one.',
      style: theme.textTheme.bodyMedium,
    );
  }
}
