import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../data/scale_uses.dart';
import '../providers/theory_providers.dart';
import 'theory_fact_row.dart';

/// The reading of a scale that the notes and the neck cannot give: its formula, where it
/// comes from, the note it leans on, the chords it fits over, and what it is for.
///
/// One card of facts rather than a screen of its own, so a player choosing between
/// seventeen scales sees why they would choose this one without leaving the list.
class ScaleFactsCard extends ConsumerWidget {
  const ScaleFactsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final facts = ref.watch(theoryScaleFactsProvider);
    final scale = facts.scale;
    final parent = facts.parent;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TheoryFactRow(label: 'Formula', value: scale.type.formula),
            TheoryFactRow(
              label: 'Intervals',
              value: scale.type.intervalNames.join(' · '),
            ),
            if (parent != null)
              TheoryFactRow(
                // A mode is the same notes started elsewhere; a pentatonic is a scale
                // with notes taken out. Both have a parent and they do not mean the
                // same thing by it, so the label says which.
                label: facts.isRotationOfParent ? 'Parent scale' : 'Comes from',
                value: parent.label,
              ),
            if (facts.characteristicTones.isNotEmpty)
              TheoryFactRow(
                label: 'Leans on',
                value: facts.characteristicTones.join(' and '),
              ),
            if (facts.chords.isNotEmpty)
              TheoryFactRow(
                label: 'Fits over',
                value: [
                  for (final chord in facts.chords)
                    chord.spell(flats: scale.prefersFlats),
                ].join('   '),
              ),
            const SizedBox(height: AppSpacing.sm),
            Text(scaleUse(scale.type), style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
