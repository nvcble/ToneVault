import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/music/scale.dart';
import '../data/key_facts.dart';
import '../providers/theory_providers.dart';
import 'circle_key_card.dart';

/// The circle of fifths, as something to press rather than something to read.
///
/// Twelve keys, each a fifth clockwise from the last, and tapping one is how the whole
/// browser changes key: the wheel is the fastest way to get to a key, and using it that
/// way is also the lesson. Keys next to each other on it share six of their seven notes,
/// which is why a song moves between neighbours without anybody feeling it happen.
class CircleOfFifthsWheel extends ConsumerWidget {
  const CircleOfFifthsWheel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keys = ref.watch(circleKeysProvider);
    final chosen = ref.watch(theoryKeyProvider);
    final facts = ref.watch(theoryKeyFactsProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              for (var index = 0; index < keys.length; index++)
                Align(
                  alignment: _at(index, keys.length),
                  child: _KeyDot(
                    scale: keys[index],
                    chosen: keys[index] == chosen,
                    onTap: () => ref.read(theoryKeyProvider.notifier).state =
                        keys[index],
                  ),
                ),
              Center(child: _Middle(facts: facts)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
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
}

class _KeyDot extends StatelessWidget {
  const _KeyDot({
    required this.scale,
    required this.chosen,
    required this.onTap,
  });

  final Scale scale;
  final bool chosen;
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
          color: chosen ? scheme.primary : scheme.surfaceContainerHighest,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Text(
          _label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: chosen ? scheme.onPrimary : scheme.onSurface,
          ),
        ),
      ),
    );
  }

  /// The root as this key spells it, with an `m` where the key is minor: `Bb`, `Am`.
  String get _label {
    final root = scale.root.name(flats: scale.prefersFlats);
    return scale.type.isMinorSounding ? '${root}m' : root;
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
