import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/music/caged.dart';
import '../../../core/music/chord_voicing.dart';
import '../providers/theory_providers.dart';
import 'chord_voicing_card.dart';

/// One chord of the key, in the five shapes that climb the neck with it.
///
/// The shapes tab answers "how do I hold this chord"; this one answers "and where else",
/// which is the question that turns a handful of chords into a neck. Every diagram here
/// comes out of the same shape library the rest of the app draws from, placed by
/// arithmetic - so a shape shown at the eighth fret is shown there because that is where
/// its root falls, not because a table said so.
class CagedShapes extends ConsumerWidget {
  const CagedShapes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final chords = ref.watch(diatonicChordsProvider);
    final degree = ref.watch(theoryDegreeProvider);
    final chord = ref.watch(theoryTriadProvider);
    final voicings = ref.watch(cagedVoicingsProvider);
    final flats = ref.watch(theoryKeyProvider).prefersFlats;

    if (chord == null) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Text('This scale has no numbered chords to put under a hand.'),
      );
    }

    final gaps = cagedGaps(chord.type);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // The chords of the key rather than the twelve roots: CAGED is learned on the
        // chords a player is already playing, and the degree is shared with the
        // substitutions tab so the two agree about which chord is being asked about.
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final each in chords)
              ChoiceChip(
                label: Text(each.roman),
                selected: each.degree == degree,
                onSelected: (_) =>
                    ref.read(theoryDegreeProvider.notifier).state = each.degree,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (voicings.isEmpty)
          // Which happens on a quality with one shape whose root lands high: a shape
          // needing frets past the fifteenth has nowhere on this neck to be drawn.
          Text(
            'No shape for ${chord.spell(flats: flats)} fits the neck: the ones this '
            'app has for a ${chord.type.label} chord would need frets past the '
            'fifteenth to carry this root.',
            style: theme.textTheme.bodyMedium,
          )
        else ...[
          _Order(chord: chord.spell(flats: flats), voicings: voicings),
          const SizedBox(height: AppSpacing.sm),
          for (final voicing in voicings) ChordVoicingCard(voicing: voicing),
          if (gaps.isNotEmpty)
            Text(
              'Not every quality can be held five ways. No ${gaps.join(', no ')} '
              'here: on a ${chord.type.label} chord those are awkward enough that '
              'players reach for the others instead.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ],
    );
  }
}

/// What the system is, and the order this chord's own shapes sit in.
class _Order extends StatelessWidget {
  const _Order({required this.chord, required this.voicings});

  final String chord;
  final List<ChordVoicing> voicings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$chord up the neck', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              // The first letter of each shape's name, which is what the word is spelled
              // out of: `C shape` is the C of CAGED.
              voicings.map((voicing) => voicing.name[0]).join('  →  '),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Every shape below is $chord - the same chord, held somewhere else. They '
              'follow each other up the neck in the order C A G E D and always in that '
              'order, wrapping round at the end, so the next shape up from any of them '
              'is the next letter along.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
