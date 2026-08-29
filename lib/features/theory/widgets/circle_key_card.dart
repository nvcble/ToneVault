import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../providers/theory_providers.dart';
import 'theory_fact_row.dart';

/// The chosen key written out: its signature, the key that shares it, and its chords.
///
/// On the wheel rather than only on the chords tab, because the circle is where a player
/// asks what a key *is*. A dot on it says `Eb` and nothing else, and the three flats, the
/// relative minor and the seven chords that come with it are the answer to having pressed
/// it. All of them are counted from the key by the engine, so pressing another dot says
/// the same things about that one.
class CircleKeyCard extends ConsumerWidget {
  const CircleKeyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facts = ref.watch(theoryKeyFactsProvider);
    final chords = ref.watch(diatonicChordsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TheoryFactRow(label: 'Key', value: facts.key.label),
            TheoryFactRow(label: 'Signature', value: facts.signatureLabel),
            // Named for what it is to this key: a minor key's relative is the major one.
            TheoryFactRow(
              label: facts.key.type.isMinorSounding
                  ? 'Relative major'
                  : 'Relative minor',
              value: facts.relative.label,
            ),
            if (chords.isNotEmpty)
              TheoryFactRow(
                label: 'Its chords',
                value: chords.map((chord) => chord.triad.symbol).join('   '),
              ),
            if (chords.isNotEmpty)
              TheoryFactRow(
                label: 'Numbered',
                value: chords.map((chord) => chord.roman).join('   '),
              ),
          ],
        ),
      ),
    );
  }
}
