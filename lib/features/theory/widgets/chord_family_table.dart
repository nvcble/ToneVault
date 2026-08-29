import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/music/chord_family.dart';
import '../providers/theory_providers.dart';

/// The chords the key is built from, numbered three ways at once.
///
/// The number is what a band calls, the numeral is what a book writes and the symbol is
/// what gets played, so the three are on the same row: learning the key means learning
/// that they are the same thing.
///
/// A pentatonic or blues key has no seventh degree to stack a chord on, so there is
/// nothing to show rather than something wrong - which is why the empty case is said out
/// loud instead of drawn as seven blank rows.
class ChordFamilyTable extends ConsumerWidget {
  const ChordFamilyTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chords = ref.watch(diatonicChordsProvider);
    final key = ref.watch(theoryKeyProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(
          'The chords of ${key.label}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (chords.isEmpty)
          const Text('This scale has no seven chords to stack on its degrees.')
        else ...[
          const _Head(),
          for (final chord in chords)
            _Row(chord: chord, flats: key.prefersFlats),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Every one of these is the scale with every other note taken out: '
            'stack three and it is a triad, four and it is a seventh.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _Head extends StatelessWidget {
  const _Head();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text('No.', style: style)),
          Expanded(flex: 2, child: Text('Numeral', style: style)),
          Expanded(flex: 2, child: Text('Chord', style: style)),
          Expanded(flex: 2, child: Text('Seventh', style: style)),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.chord, required this.flats});

  final DiatonicChord chord;
  final bool flats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${chord.degree}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(flex: 2, child: Text(chord.roman)),
          Expanded(
            flex: 2,
            child: Text(
              chord.triad.spell(flats: flats),
              style: theme.textTheme.titleSmall,
            ),
          ),
          Expanded(flex: 2, child: Text(chord.seventh.spell(flats: flats))),
        ],
      ),
    );
  }
}
