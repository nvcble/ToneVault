import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/music/fretboard_diagram.dart';
import '../../../shared/widgets/fretboard_view.dart';

/// The theory a lesson points at, drawn on a neck.
///
/// A lesson stores the theory it teaches as a short list of names - `A minor
/// pentatonic`, `Cmaj7`, `ii-V-I` - and the engine works out the notes. Nothing is
/// written twice: the lesson says what it is about, and where those notes fall on a
/// guitar is derived, so the same lesson is right in any tuning the board is handed.
///
/// One diagram is on screen at a time, chosen from a row of chips. A lesson about a
/// progression names four or five chords, and five necks stacked up is a page of
/// scrolling for something a player wants to flick between.
class LessonTheory extends StatefulWidget {
  const LessonTheory({required this.theoryKeys, super.key});

  /// What the lesson claims to teach, as written in the curriculum file.
  final List<String> theoryKeys;

  @override
  State<LessonTheory> createState() => _LessonTheoryState();
}

class _LessonTheoryState extends State<LessonTheory> {
  int _selected = 0;
  FretMarking _marking = FretMarking.degree;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diagrams = diagramsForKeys(widget.theoryKeys);
    if (diagrams.isEmpty) {
      return const SizedBox.shrink();
    }

    // Clamped rather than trusted, because a lesson can be replaced by an import while
    // its card is open and the new one may name fewer things than the chip that was
    // tapped.
    final selected = _selected.clamp(0, diagrams.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          marking: _marking,
          onChanged: (marking) => setState(() => _marking = marking),
        ),
        if (diagrams.length > 1)
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (var index = 0; index < diagrams.length; index++)
                ChoiceChip(
                  label: Text(diagrams[index].title),
                  selected: index == selected,
                  onSelected: (_) => setState(() => _selected = index),
                ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: FretboardView(diagram: diagrams[selected], marking: _marking),
        ),
        Text(
          _hint(_marking),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// What the dots mean, said once under the neck rather than learned by guessing.
  String _hint(FretMarking marking) => switch (marking) {
    FretMarking.degree =>
      'The numbers are degrees, so the shape moves to any key.',
    FretMarking.note => 'The letters are the notes as they are played here.',
    // Not offered here: a lesson's theory is scales and progressions, and a whole
    // scale has no fingers on it. The chord browser is where a hand is drawn.
    FretMarking.finger => 'The numbers are which finger presses each string.',
  };
}

/// The title of the section and the one choice it offers.
class _Header extends StatelessWidget {
  const _Header({required this.marking, required this.onChanged});

  final FretMarking marking;
  final ValueChanged<FretMarking> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showingDegrees = marking == FretMarking.degree;

    return Row(
      children: [
        Expanded(child: Text('On the neck', style: theme.textTheme.titleSmall)),
        TextButton(
          onPressed: () =>
              onChanged(showingDegrees ? FretMarking.note : FretMarking.degree),
          child: Text(showingDegrees ? 'Note names' : 'Degrees'),
        ),
      ],
    );
  }
}
