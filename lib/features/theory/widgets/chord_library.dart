import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/enums/bookmark_target.dart';
import '../../../core/music/chord.dart';
import '../../academy/widgets/bookmark_button.dart';
import '../providers/theory_providers.dart';
import 'chord_voicing_card.dart';
import 'theory_fact_row.dart';

/// Every quality the engine knows, on the key's root, each opening onto the ways a hand
/// can hold it.
///
/// Nineteen-odd chord types is a long list and most of a player's questions are about one
/// of them, so it is a list of names that opens rather than a wall of diagrams. The
/// fingerings behind each name are worked out when it is opened, by the same shape library
/// the lessons draw from - there is no table of chord diagrams in this app, and so no
/// table of chord diagrams to disagree with the theory.
class ChordLibrary extends ConsumerWidget {
  const ChordLibrary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chords = ref.watch(chordLibraryProvider);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: chords.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) => _ChordTile(chord: chords[index]),
    );
  }
}

/// One quality: what it is called, what it spells, and the shapes for it once asked.
class _ChordTile extends ConsumerWidget {
  const _ChordTile({required this.chord});

  final Chord chord;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ExpansionTile(
      title: Text(chord.symbol, style: theme.textTheme.titleMedium),
      subtitle: Text('${chord.type.label} · ${_spelling(chord)}'),
      childrenPadding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      children: [
        // The formula is the chord in every key at once - `1 3 5 b7` is a dominant
        // seventh wherever it is played - and the intervals say why it sounds the way
        // it does. The spelling in the subtitle is only this key's worth of that.
        TheoryFactRow(label: 'Formula', value: chord.type.formula),
        TheoryFactRow(
          label: 'Intervals',
          value: chord.type.intervalNames.join(' · '),
        ),
        Align(
          alignment: Alignment.centerRight,
          // Its symbol is all the engine needs to spell and draw it again, so a kept
          // chord costs one string and no row of its own.
          child: BookmarkButton(
            target: BookmarkTarget.chord,
            targetKey: chord.symbol,
            label: chord.symbol,
          ),
        ),
        _Voicings(chord: chord),
      ],
    );
  }

  String _spelling(Chord chord) => [
    for (final note in chord.notes) note.name(flats: chord.notesPreferFlats),
  ].join(' ');
}

class _Voicings extends ConsumerWidget {
  const _Voicings({required this.chord});

  final Chord chord;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voicings = ref.watch(chordVoicingsProvider(chord.type));

    if (voicings.isEmpty) {
      // Only from a shape that needs more neck than the window has - the notes are still
      // right, and saying so is better than an empty space that reads as a bug.
      return Text(
        'No shape for this one fits the first twelve frets in this key.',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final voicing in voicings) ChordVoicingCard(voicing: voicing),
      ],
    );
  }
}
