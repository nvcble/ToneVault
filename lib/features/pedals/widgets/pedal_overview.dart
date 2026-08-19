import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/formatting/app_date_format.dart';
import 'pedal_type_badge.dart';

/// What was recorded about the pedal itself, as opposed to what it can be set
/// to.
class PedalOverview extends StatelessWidget {
  const PedalOverview({required this.pedal, super.key});

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
