import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/formatting/app_date_format.dart';

/// What one rig is, above its signal chain.
class RigOverview extends StatelessWidget {
  const RigOverview({required this.pedalboard, super.key});

  final Pedalboard pedalboard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = pedalboard.description;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (description != null) ...[
          Text(description, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.md),
        ],
        Text(
          'Built ${formatDate(pedalboard.createdAt)} · '
          'last changed ${formatDate(pedalboard.updatedAt)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
