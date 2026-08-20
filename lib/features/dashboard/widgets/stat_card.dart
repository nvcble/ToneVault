import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

/// One count on the home screen, and the way through to what it counts.
class StatCard extends StatelessWidget {
  const StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  /// A line under the number saying something the number cannot.
  final String detail;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      // So the ripple stops at the rounded corner rather than squaring it off.
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(label, style: theme.textTheme.titleSmall),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(value, style: theme.textTheme.headlineMedium),
              Text(
                detail,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
