import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/music/circle_of_fifths.dart';
import '../../../core/music/pitch_class.dart';
import '../../../core/music/scale.dart';
import '../data/key_facts.dart';
import '../providers/theory_providers.dart';
import 'circle_combination_card.dart';
import 'circle_key_card.dart';

/// The circle of fifths, as something to press rather than something to read.
///
/// Twelve notes, each a fifth clockwise from the last. Pressing them does two things at
/// once, because for a player they are one thing: the notes stack up into a chord that is
/// named underneath, and the browser changes key to whatever they built. A player pressing
/// one note is choosing a key the fast way; a player pressing three is asking what they
/// have got, in the key it is read in.
///
/// The circle itself is the lesson either way. Notes next to each other on it are the
/// chords that follow each other in songs, and keys next to each other share six of their
/// seven notes - which is why a song moves between neighbours without anybody feeling it.
class CircleOfFifthsWheel extends ConsumerWidget {
  const CircleOfFifthsWheel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = circleNotes();
    final picked = ref.watch(combinedNotesProvider);
    final key = ref.watch(theoryKeyProvider);
    final facts = ref.watch(theoryKeyFactsProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              for (var index = 0; index < notes.length; index++)
                Align(
                  alignment: _at(index, notes.length),
                  child: _NoteDot(
                    note: notes[index],
                    picked: picked.contains(notes[index]),
                    isKey: notes[index] == key.root,
                    onTap: () => _press(ref, notes[index]),
                  ),
                ),
              Center(child: _Middle(facts: facts)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const CircleCombinationCard(),
        const SizedBox(height: AppSpacing.sm),
        const CircleKeyCard(),
        const SizedBox(height: AppSpacing.sm),
        _Neighbours(facts: facts),
      ],
    );
  }

  /// Twelve o'clock is where the wheel starts, and it turns clockwise, because that is
  /// the way it is printed on every chart a player will meet elsewhere.
  Alignment _at(int index, int count) {
    final angle = 2 * pi * index / count;
    return Alignment(sin(angle), -cos(angle));
  }

  /// A note pressed: into the combination or out of it again, and the key follows whatever
  /// the combination now spells.
  ///
  /// The root of the chord they built, or the note itself where there is no chord yet -
  /// either way the key ends up where the player is looking. Which flavour it is stays
  /// with the picker above the tabs, because major or minor is a decision about the music
  /// and not something three notes can settle.
  void _press(WidgetRef ref, PitchClass note) {
    final notes = ref.read(combinedNotesProvider);
    ref.read(combinedNotesProvider.notifier).state = notes.contains(note)
        ? [
            for (final picked in notes)
              if (picked != note) picked,
          ]
        : [...notes, note];

    final chords = ref.read(combinedChordsProvider);
    final picked = ref.read(combinedNotesProvider);
    final root = chords.isNotEmpty
        ? chords.first.root
        : (picked.length == 1 ? picked.single : null);

    if (root != null) {
      final key = ref.read(theoryKeyProvider);
      ref.read(theoryKeyProvider.notifier).state = Scale(root, key.type);
    }
  }
}

class _NoteDot extends StatelessWidget {
  const _NoteDot({
    required this.note,
    required this.picked,
    required this.isKey,
    required this.onTap,
  });

  final PitchClass note;

  /// Whether it is one of the notes being combined.
  final bool picked;

  /// Whether it is the note the browser's key is read from.
  final bool isKey;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkResponse(
      onTap: onTap,
      radius: AppSpacing.minTouchTarget,
      child: Container(
        width: AppSpacing.minTouchTarget,
        height: AppSpacing.minTouchTarget,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: picked ? scheme.primary : scheme.surfaceContainerHighest,
          // The key is ringed rather than filled, so a note can be both the key and part
          // of the chord being built without the two saying the same thing.
          border: Border.all(
            color: isKey ? scheme.primary : scheme.outlineVariant,
            width: isKey ? 2 : 1,
          ),
        ),
        child: Text(
          // Each note spelled the way it is usually written rather than the way the key
          // spells it: this is the whole circle, and the flat side of it reads as flats
          // on every chart a player has seen.
          note.name(flats: note.prefersFlats),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: picked ? scheme.onPrimary : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// What the chosen key is, in the middle of the wheel it is chosen on.
class _Middle extends StatelessWidget {
  const _Middle({required this.facts});

  final KeyFacts facts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(facts.key.label, style: theme.textTheme.titleLarge),
        Text(
          facts.signatureLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// The keys next door, and why they are worth knowing.
class _Neighbours extends StatelessWidget {
  const _Neighbours({required this.facts});

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
