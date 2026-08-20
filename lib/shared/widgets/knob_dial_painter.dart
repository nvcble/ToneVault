import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'knob_dial.dart';

/// Draws a [KnobDial]: the end stops and 12:00 marked outside, and the knob
/// itself turned to [value].
///
/// Shaped like the knob on a pedal - a scalloped rim, a gloss across the body
/// and a slot cut towards the mark. The whole body turns, which is what makes a
/// change read as the knob being turned rather than a number changing. Painted
/// rather than photographed so it takes the theme's colours, stays sharp at any
/// size, and leaves no artwork to keep in step with the code.
class KnobDialPainter extends CustomPainter {
  const KnobDialPainter({
    required this.value,
    required this.face,
    required this.pointer,
    required this.marks,
  });

  /// `0..1` along the sweep.
  final double value;

  final Color face;
  final Color pointer;
  final Color marks;

  /// Bumps around the rim, as a knob has for grip.
  static const int _scallops = 9;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final bodyRadius = radius * 0.82;

    _paintScale(canvas, centre, radius);

    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.rotate(_radians(value));
    _paintBody(canvas, bodyRadius);
    _paintMark(canvas, bodyRadius);
    canvas.restore();
  }

  /// The three readings a player aims for, left where they are while the knob
  /// turns past them.
  void _paintScale(Canvas canvas, Offset centre, double radius) {
    final paint = Paint()
      ..color = marks
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (final along in const [0.0, 0.5, 1.0]) {
      final bearing = Offset(
        math.sin(_radians(along)),
        -math.cos(_radians(along)),
      );
      canvas.drawLine(
        centre + bearing * (radius * 0.88),
        centre + bearing * radius,
        paint,
      );
    }
  }

  /// The scalloped body, lit from the upper left so it reads as moulded plastic.
  void _paintBody(Canvas canvas, double radius) {
    final rim = Path();
    for (var step = 0; step <= 180; step++) {
      final angle = step / 180 * 2 * math.pi;
      final along = radius * (1 + 0.035 * math.cos(_scallops * angle));
      final point = Offset(math.sin(angle) * along, -math.cos(angle) * along);
      step == 0
          ? rim.moveTo(point.dx, point.dy)
          : rim.lineTo(point.dx, point.dy);
    }
    rim.close();

    canvas.drawPath(
      rim,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.5),
          radius: 1,
          colors: [Color.lerp(face, Colors.white, 0.16)!, face],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius)),
    );
    // A ring inside the rim, which is the moulding line on a real knob.
    canvas.drawCircle(
      Offset.zero,
      radius * 0.82,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Color.lerp(face, Colors.white, 0.08)!,
    );
  }

  /// The slot and the dot on the rim, both pointing at the reading.
  void _paintMark(Canvas canvas, double radius) {
    final paint = Paint()..color = pointer;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          -radius * 0.07,
          -radius * 0.7,
          radius * 0.07,
          radius * 0.1,
        ),
        Radius.circular(radius * 0.07),
      ),
      paint,
    );
    canvas.drawCircle(Offset(0, -radius * 0.87), radius * 0.055, paint);
  }

  /// Radians clockwise from straight up for a position along the sweep.
  double _radians(double along) =>
      (along * KnobDial.sweepDegrees - KnobDial.sweepDegrees / 2) *
      math.pi /
      180;

  @override
  bool shouldRepaint(KnobDialPainter old) =>
      old.value != value ||
      old.face != face ||
      old.pointer != pointer ||
      old.marks != marks;
}
