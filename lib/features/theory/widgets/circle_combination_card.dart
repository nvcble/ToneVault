import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../providers/theory_providers.dart';
import 'theory_fact_row.dart';

/// The notes combined on the wheel, what they spell, and the way round the circle onto it.
///
/// Every line here is worked out from the notes, including the name: the engine tries each
/// pressed note as the root, so what is shown is what the notes actually spell rather than
/// what a player was aiming for. Getting a chord they did not expect is the lesson.
///
/// Chords are written with their own spelling rather than the key's, so the symbol agrees
/// with the notes above it - Bb and Bbm, never Bb and A#m.
class CircleCombinationCard extends ConsumerWidget {
  const CircleCombinationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notes = ref.watch(combinedNotesProvider);
    final chords = ref.watch(combinedChordsProvider);
    final progression = ref.watch(combinedProgressionProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Combine notes',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                if (notes.isNotEmpty)
                  TextButton(
                    onPressed: () =>
                        ref.read(combinedNotesProvider.notifier).state =
                            const [],
                    child: const Text('Clear'),
                  ),
              ],
            ),
            if (notes.isEmpty)
              Text(
                'Press notes on the wheel to stack them up. Whatever they spell is '
                'named here, with the way round the circle onto it.',
                style: theme.textTheme.bodySmall,
              )
            else ...[
              TheoryFactRow(
                label: 'Notes',
                value: [
                  for (final note in notes) note.name(flats: note.prefersFlats),
                ].join('   '),
              ),
              TheoryFactRow(
                label: 'Spells',
                value: chords.isEmpty
                    ? _nothing(notes.length)
                    // More than one name is more than one honest answer, so all of them
                    // are given rather than the first being passed off as the chord.
                    : chords.map((chord) => chord.symbol).join('   or   '),
              ),
              if (progression.isNotEmpty) ...[
                TheoryFactRow(
                  label: 'Onto it',
                  value: progression.map((chord) => chord.symbol).join('   '),
                ),
                Text(
                  'Each of those is a fifth above the next, so every change falls a '
                  'fifth - the last steps anticlockwise round this wheel onto '
                  '${progression.last.symbol}.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  /// What to say when the notes have no chord in them, which is not the same thing as an
  /// error: two notes are usually on the way to one.
  String _nothing(int notes) => notes < 3
      ? 'not a chord yet - press another note'
      : 'no chord this app has a name for';
}
