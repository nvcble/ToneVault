import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../data/routing_advice.dart';

/// What is worth checking about a rig's wiring, under the chain it is about.
///
/// Collapsed to one line until it is opened, and absent entirely when there is
/// nothing to say - which is every rig that runs straight through. Nothing here
/// stops a write: a half-built rig is a normal thing to save and come back to, so
/// these are worded as observations rather than errors, and drawn in the ordinary
/// surface colours rather than in red.
class RoutingAdvicePanel extends StatelessWidget {
  const RoutingAdvicePanel({required this.notes, super.key});

  final List<RoutingNote> notes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (notes.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ExpansionTile(
        leading: const Icon(Icons.info_outline),
        title: Text(
          notes.length == 1
              ? '1 thing to check'
              : '${notes.length} things to check',
        ),
        subtitle: const Text('None of this stops you saving the rig'),
        childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
        children: [
          for (final note in notes)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(note.message, style: theme.textTheme.bodySmall),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
