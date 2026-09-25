import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../data/key_facts.dart';

/// The keys next door, and why they are worth knowing.
class CircleNeighboursCard extends StatelessWidget {
  const CircleNeighboursCard({required this.facts, super.key});

  final KeyFacts facts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Next door', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              facts.neighbours.map((key) => key.label).join(',  '),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Each of these shares six of its seven notes with '
              '${facts.key.label}, and ${facts.relative.label} shares all of '
              'them - the same notes, heard from somewhere else.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
