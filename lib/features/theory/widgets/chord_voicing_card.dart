import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/music/chord_voicing.dart';
import '../../../core/music/fretboard.dart';
import '../../../core/music/fretboard_diagram.dart';
import '../../../shared/widgets/fretboard_view.dart';
import '../data/voicing_words.dart';

/// One way of holding one chord: the box, where on the neck it sits, and the same thing
/// in words.
///
/// The window is cut to the shape rather than the shape drawn on a whole neck. A barre
/// chord at the eighth fret shown across twelve frets is four dots in the right-hand
/// third of a diagram of nothing, and a player has to count to find out where their hand
/// goes. Four frets starting one below the hand is the chord box a book would print.
class ChordVoicingCard extends StatelessWidget {
  const ChordVoicingCard({required this.voicing, super.key});

  final ChordVoicing voicing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(voicing.name, style: theme.textTheme.titleSmall),
                ),
                Text(
                  voicingPlace(voicing),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            FretboardView(
              diagram: diagramOfChord(voicing.chord),
              fretboard: _window,
              voicing: voicing,
              marking: FretMarking.finger,
              showTitle: false,
            ),
            const SizedBox(height: AppSpacing.xs),
            for (final line in voicingWords(voicing))
              Text(
                line,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// The stretch of neck this shape lives in: from a fret below the hand, or from the nut
  /// where a string rings open, since an open string is the nut and cannot be cropped
  /// out of the picture.
  Fretboard get _window {
    final from = voicing.isOpen ? 0 : voicing.lowestHeldFret - 1;
    return Fretboard(
      tuning: voicing.fretboard.tuning,
      firstFret: from < 0 ? 0 : from,
      fretCount: 4,
    );
  }
}
