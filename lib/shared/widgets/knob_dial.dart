import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'knob_dial_painter.dart';

/// A knob that turns the way the one on the pedal does: 7:00 fully back, 12:00
/// straight up, 5:00 fully forward.
///
/// Driven by a normalized `0..1` position and nothing else, so anything with a
/// sweep can use it without the knob knowing what it sets. Dragging anywhere on
/// the face turns the pointer to that bearing, and it animates the rest of the
/// way so a jump reads as a turn.
class KnobDial extends StatelessWidget {
  const KnobDial({
    required this.value,
    this.onChanged,
    this.divisions,
    this.size = 168,
    super.key,
  });

  /// `0..1`, where 0 is the 7:00 end stop and 1 the 5:00 one.
  final double value;

  /// Null leaves the knob read-only, which is how it greys out while a save is
  /// in flight.
  final ValueChanged<double>? onChanged;

  /// Notches across the sweep, or null to turn freely.
  final int? divisions;

  final double size;

  /// Degrees from one end stop to the other, going forwards through 12:00: ten
  /// hours of a clock face at 30 degrees each.
  static const double sweepDegrees = 300;

  /// How long the pointer takes to catch up with a new position.
  static const Duration turnDuration = Duration(milliseconds: 140);

  void _turnTo(Offset local) {
    final handler = onChanged;
    if (handler == null) {
      return;
    }

    final offset = local - Offset(size / 2, size / 2);
    // Measured clockwise from straight up, so 12:00 is zero and the end stops
    // sit at -150 and +150 degrees. The gap below the knob is not a position it
    // has, so a finger there is held at whichever end stop it is nearest.
    final degrees = math.atan2(offset.dx, -offset.dy) * 180 / math.pi;
    final double position = ((degrees + sweepDegrees / 2) / sweepDegrees).clamp(
      0,
      1,
    );

    handler(_snapped(position));
  }

  double _snapped(double position) {
    final notches = divisions;
    if (notches == null || notches <= 0) {
      return position;
    }
    return (position * notches).round() / notches;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isEditable = onChanged != null;

    return GestureDetector(
      onPanDown: (details) => _turnTo(details.localPosition),
      onPanUpdate: (details) => _turnTo(details.localPosition),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: value.clamp(0, 1)),
        duration: turnDuration,
        curve: Curves.easeOut,
        builder: (context, turned, _) => CustomPaint(
          size: Size.square(size),
          painter: KnobDialPainter(
            value: turned,
            face: scheme.surfaceContainerHighest,
            pointer: isEditable ? scheme.primary : scheme.onSurfaceVariant,
            marks: scheme.outlineVariant,
          ),
        ),
      ),
    );
  }
}
