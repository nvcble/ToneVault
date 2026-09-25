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
import 'circle_neighbours_card.dart';
import 'circle_note_dot.dart';
import 'circle_wheel_painter.dart';

/// The circle of fifths, as something to draw on rather than something to read.
///
/// Twelve notes, each a fifth clockwise from the last. Dragging a finger across them
/// connects whichever ones it passes over, in the order it reaches them, and that is
/// one thing for a player: the notes stack up into a chord that is named underneath, and
/// the browser changes key to whatever they built. Touching one note alone is choosing a
/// key the fast way; drawing a line through three is asking what they have got, in the
/// key it is read in.
///
/// The circle itself is the lesson either way. Notes next to each other on it are the
/// chords that follow each other in songs, and keys next to each other share six of their
/// seven notes - which is why a song moves between neighbours without anybody feeling it.
class CircleOfFifthsWheel extends ConsumerStatefulWidget {
  const CircleOfFifthsWheel({super.key});

  @override
  ConsumerState<CircleOfFifthsWheel> createState() =>
      _CircleOfFifthsWheelState();
}

class _CircleOfFifthsWheelState extends ConsumerState<CircleOfFifthsWheel> {
  /// Where the finger is right now, while a line is being drawn - null once it lifts.
  Offset? _dragPoint;

  @override
  Widget build(BuildContext context) {
    final notes = circleNotes();
    final picked = ref.watch(combinedNotesProvider);
    final key = ref.watch(theoryKeyProvider);
    final facts = ref.watch(theoryKeyFactsProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest.shortestSide;
              final positions = [
                for (var index = 0; index < notes.length; index++)
                  _pointAt(index, notes.length, size),
              ];

              return Stack(
                children: [
                  CustomPaint(
                    size: Size.square(size),
                    painter: CircleWheelPainter(
                      points: [
                        for (final note in picked)
                          positions[notes.indexOf(note)],
                      ],
                      dragPoint: _dragPoint,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  for (var index = 0; index < notes.length; index++)
                    Align(
                      alignment: _at(index, notes.length),
                      // Each dot owns its own gesture: a line only starts from an actual
                      // note, so a drag anywhere else on the wheel is free to scroll the
                      // page instead. Once started, it still tracks the finger anywhere.
                      child: GestureDetector(
                        onPanDown: (_) =>
                            _startLine(notes[index], positions[index]),
                        onPanStart: (details) => _extendLine(
                          _localize(context, details.globalPosition),
                          notes,
                          positions,
                        ),
                        onPanUpdate: (details) => _extendLine(
                          _localize(context, details.globalPosition),
                          notes,
                          positions,
                        ),
                        onPanEnd: (_) => _endLine(),
                        // A tap that never moved enough to be recognised as a drag is
                        // cancelled rather than ended - still a line finished, just a
                        // one-note one.
                        onPanCancel: _endLine,
                        child: CircleNoteDot(
                          note: notes[index],
                          picked: picked.contains(notes[index]),
                          isKey: notes[index] == key.root,
                        ),
                      ),
                    ),
                  Center(child: _Middle(facts: facts)),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const CircleCombinationCard(),
        const SizedBox(height: AppSpacing.sm),
        const CircleKeyCard(),
        const SizedBox(height: AppSpacing.sm),
        CircleNeighboursCard(facts: facts),
      ],
    );
  }

  /// Twelve o'clock is where the wheel starts, and it turns clockwise, because that is
  /// the way it is printed on every chart a player will meet elsewhere.
  Alignment _at(int index, int count) {
    final angle = 2 * pi * index / count;
    return Alignment(sin(angle), -cos(angle));
  }

  /// The same point, in pixels rather than alignment - where [Align] actually puts a
  /// dot's centre once it has been squeezed in by the dot's own size.
  Offset _pointAt(int index, int count, double size) {
    final align = _at(index, count);
    final radius = (size - AppSpacing.minTouchTarget) / 2;
    return Offset(size / 2 + align.x * radius, size / 2 + align.y * radius);
  }

  /// A fresh line starting on the note whose own dot was touched: whatever was combined
  /// before is let go of, so a new drag is always a new chord rather than an addition to
  /// the last one.
  void _startLine(PitchClass note, Offset point) {
    ref.read(combinedNotesProvider.notifier).state = [note];
    setState(() => _dragPoint = point);
  }

  void _extendLine(Offset point, List<PitchClass> notes, List<Offset> positions) {
    setState(() => _dragPoint = point);
    _connect(point, notes, positions);
  }

  /// The line let go of: the key follows whatever the combination now spells.
  ///
  /// The root of the chord that was drawn, or the note itself where there is no chord
  /// yet - either way the key ends up where the player was looking. Which flavour it is
  /// stays with the picker above the tabs, because major or minor is a decision about
  /// the music and not something a line of notes can settle.
  void _endLine() {
    setState(() => _dragPoint = null);

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

  /// Adds whichever note the line has just reached, if it has reached one it had not
  /// already connected.
  void _connect(Offset point, List<PitchClass> notes, List<Offset> positions) {
    const hitRadius = AppSpacing.minTouchTarget / 1.6;

    for (var index = 0; index < notes.length; index++) {
      if ((point - positions[index]).distance > hitRadius) {
        continue;
      }

      final note = notes[index];
      final picked = ref.read(combinedNotesProvider);
      if (!picked.contains(note)) {
        ref.read(combinedNotesProvider.notifier).state = [...picked, note];
      }
      return;
    }
  }

  /// A drag callback's global position, translated into the square's own coordinates -
  /// the same space [positions] was computed in - so it keeps working once the finger
  /// has moved off the dot that started the line.
  Offset _localize(BuildContext context, Offset global) =>
      (context.findRenderObject()! as RenderBox).globalToLocal(global);
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
