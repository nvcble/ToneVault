import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/enums/bookmark_target.dart';
import '../../../core/music/substitution.dart';
import '../../academy/widgets/bookmark_button.dart';
import '../providers/theory_providers.dart';

/// What could be played instead of a chord of the key, and why.
///
/// The reason is the point. A list of swaps to memorise is worth nothing away from the
/// key it was memorised in, and every one of these is a sentence of harmony applied to
/// whichever chord is chosen - so the same reasoning works on a chord that is not on the
/// list.
class SubstitutionList extends ConsumerWidget {
  const SubstitutionList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final chords = ref.watch(diatonicChordsProvider);
    final degree = ref.watch(theoryDegreeProvider);
    final chord = ref.watch(theoryChordProvider);
    final substitutions = ref.watch(theorySubstitutionsProvider);
    final flats = ref.watch(theoryKeyProvider).prefersFlats;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final each in chords)
              ChoiceChip(
                label: Text(each.romanSeventh),
                selected: each.degree == degree,
                onSelected: (_) =>
                    ref.read(theoryDegreeProvider.notifier).state = each.degree,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (chord == null)
          const Text('This scale has no numbered chords to swap.')
        else ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Instead of ${chord.spell(flats: flats)}',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              // The chord as this key spells it, which is both what the player is
              // looking at and something [Chord.parse] can read back.
              BookmarkButton(
                target: BookmarkTarget.chord,
                targetKey: chord.spell(flats: flats),
                label: chord.spell(flats: flats),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final substitution in substitutions)
            _Swap(
              substitution: substitution,
              instead: chord.spell(flats: flats),
            ),
        ],
      ],
    );
  }
}

/// One swap, spelled the way the chord itself is written rather than the way the key
/// spells its notes: a substitution is borrowed from outside the key, and the tritone
/// substitute of G7 is written Db7 by everybody who plays it.
class _Swap extends StatelessWidget {
  const _Swap({required this.substitution, required this.instead});

  final Substitution substitution;

  /// The chord this one stands in for, which is half of what makes the swap worth
  /// keeping: `Db7` on its own is a chord, and `Db7 for G7` is a piece of harmony.
  final String instead;

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
                  child: Text(
                    substitution.chord.symbol,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                // Kept as the substitute's own symbol, so the sheet draws the chord
                // the player would actually play; the label carries what it replaces,
                // because that is the part a list of bookmarks cannot work out.
                BookmarkButton(
                  target: BookmarkTarget.substitution,
                  targetKey: substitution.chord.symbol,
                  label: '${substitution.chord.symbol} for $instead',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(substitution.reason, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
