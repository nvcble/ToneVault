import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/enums/bookmark_target.dart';
import '../../academy/data/bookmark_keys.dart';
import '../../academy/widgets/bookmark_button.dart';
import '../data/progression_chart.dart';
import '../providers/theory_providers.dart';

/// The progressions worth knowing, in the key that is chosen.
///
/// Three lines each, because a progression gets written down three ways and a player who
/// has only met one of them cannot follow the other two: the numerals a book uses, the
/// Nashville numbers a band calls, and the chords a guitarist plays.
class ProgressionList extends ConsumerWidget {
  const ProgressionList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charts = ref.watch(theoryProgressionsProvider);

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: charts.length,
      itemBuilder: (context, index) => _Chart(chart: charts[index]),
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.chart});

  final ProgressionChart chart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(chart.name, style: theme.textTheme.titleSmall),
                ),
                // Named after the key it is read in, which for a minor progression is
                // the minor key of the same root rather than the major one chosen.
                Text(
                  chart.key.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                // Kept as the key and the numbers, because numbers without a key are
                // not chords: the same two strings a lesson would have written.
                BookmarkButton(
                  target: BookmarkTarget.progression,
                  targetKey: theoryKeysKey([chart.key.label, chart.numerals]),
                  label: '${chart.name} in ${chart.key.label}',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(chart.symbols, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${chart.numerals}   ·   ${chart.numbers}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
