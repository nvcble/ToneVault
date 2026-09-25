import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/music/pitch_class.dart';

/// One note on the circle of fifths wheel.
///
/// Not its own tap target: the wheel around it reads the drag that connects notes into
/// a line, and a dot pressed alone is just a very short line.
class CircleNoteDot extends StatelessWidget {
  const CircleNoteDot({
    required this.note,
    required this.picked,
    required this.isKey,
    super.key,
  });

  final PitchClass note;

  /// Whether it is one of the notes being combined.
  final bool picked;

  /// Whether it is the note the browser's key is read from.
  final bool isKey;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
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
    );
  }
}
