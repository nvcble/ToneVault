import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/formatting/app_date_format.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/pedal_editor.dart';
import '../providers/pedal_providers.dart';
import '../widgets/pedal_type_badge.dart';

/// Everything recorded about one pedal.
///
/// Controls, configurations and history get their own sections in later
/// phases; for now this is the overview and the way into editing.
class PedalDetailScreen extends ConsumerWidget {
  const PedalDetailScreen({required this.pedalId, super.key});

  final int pedalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pedalValue = ref.watch(pedalProvider(pedalId));
    final pedal = pedalValue.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(pedal?.name ?? 'Pedal'),
        actions: pedal == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: () => context.go(Routes.pedalEdit(pedalId)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: () => _confirmDelete(context, ref, pedal.name),
                ),
              ],
      ),
      body: pedalValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not open this pedal',
          message: failureMessage(error),
        ),
        data: (pedal) => pedal == null
            ? const EmptyState(
                icon: Icons.help_outline,
                title: 'That pedal no longer exists',
                message: 'It may have been deleted on another screen.',
              )
            : _PedalOverview(pedal: pedal),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete pedal?'),
        content: Text(
          'This removes $name and everything recorded about it. To keep its '
          'history, set its status to Sold or Replaced instead.',
        ),
        actions: [
          TextButton(
            // Dialogs are Navigator routes rather than go_router pages, so they
            // are dismissed through the Navigator.
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(pedalEditorProvider).delete(pedalId);
      if (context.mounted) {
        context.go(Routes.pedals);
      }
    } catch (error) {
      if (context.mounted) {
        showFailureSnackBar(context, error);
      }
    }
  }
}

class _PedalOverview extends StatelessWidget {
  const _PedalOverview({required this.pedal});

  final Pedal pedal;

  @override
  Widget build(BuildContext context) {
    final purchaseDate = pedal.purchaseDate;
    final notes = pedal.notes;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Row(
          children: [
            PedalTypeBadge(pedal.type),
            const SizedBox(width: AppSpacing.sm),
            Text(
              pedal.category.label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _DetailRow(label: 'Brand', value: pedal.brand),
        _DetailRow(label: 'Status', value: pedal.status.label),
        _DetailRow(
          label: 'Purchased',
          value: purchaseDate == null ? null : formatDate(purchaseDate),
        ),
        _DetailRow(label: 'Added', value: formatDate(pedal.createdAt)),
        if (notes != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text('Notes', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(notes, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;

  /// Rendered as a dash when null, so the layout does not shift depending on
  /// which optional fields were filled in.
  final String? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value ?? '—', style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
