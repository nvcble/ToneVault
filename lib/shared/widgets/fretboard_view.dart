import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/music/chord_voicing.dart';
import '../../core/music/fretboard.dart';
import '../../core/music/fretboard_diagram.dart';
import '../../core/music/pitch_class.dart';
import 'fret_cell.dart';

/// What to write inside the dots.
enum FretMarking {
  /// `1`, `b3`, `5` - the way a shape is taught, so it moves between keys.
  degree,

  /// `A`, `C`, `E` - the way a note is named, for learning the neck itself.
  note,

  /// `1`, `3`, `4` - which finger presses it, which only means anything when the neck is
  /// showing one hand's worth of chord rather than every note in a scale.
  finger,
}

/// The fretboard. There is one in the app, and everything that needs a neck drawn
/// hands it a [FretboardDiagram].
///
/// It knows no music. Which notes are on it, what they are called and which one is the
/// root are all decided before they get here, by the engine in `lib/core/music`; this
/// widget turns strings and frets into rows and columns. That division is what stops
/// scale shapes, chord voicings and ear-training answers from each growing a fretboard
/// of their own that draws the neck slightly differently.
///
/// The high string is drawn at the top, which is how a diagram is printed, while the
/// tuning is stored lowest-first, which is how a player names the strings. The reversal
/// happens here because it is a drawing decision.
class FretboardView extends StatelessWidget {
  const FretboardView({
    required this.diagram,
    this.fretboard = const Fretboard(),
    this.marking = FretMarking.degree,
    this.showTitle = true,
    this.voicing,
    super.key,
  });

  final FretboardDiagram diagram;

  /// Which stretch of which neck is being looked at.
  final Fretboard fretboard;

  /// One hand's way of holding the diagram's chord, if the neck is showing a chord box
  /// rather than a whole diagram.
  ///
  /// Without it every C, E and G in the window is marked, which is what a scale wants and
  /// the opposite of what a chord box is for: a chord box is six strings, pressed once
  /// each or not at all. So a voicing narrows the marks down to the ones the hand makes,
  /// and says which strings are left out.
  final ChordVoicing? voicing;

  final FretMarking marking;

  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tuning = fretboard.tuning;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTitle)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(diagram.title, style: theme.textTheme.titleSmall),
          ),
        for (var string = tuning.stringCount - 1; string >= 0; string--)
          Row(children: _cells(string)),
        _FretNumbers(fretboard: fretboard),
      ],
    );
  }

  /// One cell per fret in the window, marked where the diagram has that note.
  List<Widget> _cells(int string) => [
    for (var fret = fretboard.firstFret; fret <= fretboard.lastFret; fret++)
      Expanded(
        child: _cell(string: string, fret: fret),
      ),
  ];

  Widget _cell({required int string, required int fret}) {
    final note = fretboard.noteAt(string, fret);
    final held = voicing;

    return FretCell(
      // The strings are drawn thicker towards the bass, as they are on the guitar.
      stringWeight: 1 + (fretboard.tuning.stringCount - 1 - string) * 0.4,
      isNut: fret == 0,
      isRoot:
          note == diagram.root && (held == null || held.fretOn(string) == fret),
      isMuted: held != null && held.fretOn(string) == null,
      label: held == null
          ? _label(note)
          : _heldLabel(held, string: string, fret: fret, note: note),
    );
  }

  /// What the note at a fret is called, or nothing where the diagram has not got it.
  String? _label(PitchClass note) {
    final degree = diagram.degreeOf(note);
    if (degree == null) {
      return null;
    }
    return switch (marking) {
      FretMarking.degree => degree,
      FretMarking.note => diagram.nameOf(note),
      // Nothing is pressing anything, so a finger is not a question the neck can answer.
      FretMarking.finger => degree,
    };
  }

  /// The same, for a neck showing one chord: only the frets the hand is on, and an `x` at
  /// the near end of every string it leaves out.
  String? _heldLabel(
    ChordVoicing voicing, {
    required int string,
    required int fret,
    required PitchClass note,
  }) {
    if (voicing.fretOn(string) == null) {
      return fret == fretboard.firstFret ? '×' : null;
    }
    if (voicing.fretOn(string) != fret) {
      return null;
    }
    return switch (marking) {
      // An open string has no finger on it, and `0` is what a chord box writes there.
      FretMarking.finger => '${voicing.fingerOn(string) ?? 0}',
      FretMarking.degree => diagram.degreeOf(note) ?? diagram.nameOf(note),
      FretMarking.note => diagram.nameOf(note),
    };
  }
}

/// The fret numbers under the neck, on the frets a guitar has dots on.
///
/// Only those, because a number under every fret is a row of noise; the inlays are
/// what a player counts from, so those are the ones worth naming.
class _FretNumbers extends StatelessWidget {
  const _FretNumbers({required this.fretboard});

  final Fretboard fretboard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        children: [
          for (
            var fret = fretboard.firstFret;
            fret <= fretboard.lastFret;
            fret++
          )
            Expanded(
              child: Text(
                Fretboard.isInlaid(fret) ? '$fret' : '',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
