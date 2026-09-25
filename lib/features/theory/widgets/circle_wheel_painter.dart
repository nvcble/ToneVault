import 'package:flutter/material.dart';

/// The line a finger draws across the wheel, connecting the notes it has picked up
/// so far and reaching for whichever one it hasn't let go of yet.
class CircleWheelPainter extends CustomPainter {
  const CircleWheelPainter({
    required this.points,
    required this.dragPoint,
    required this.color,
  });

  /// The picked notes' centres, in the order the finger connected them.
  final List<Offset> points;

  /// Where the finger is now, while still dragging - null once it has lifted.
  final Offset? dragPoint;

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) {
      return;
    }

    final line = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], line);
    }

    final tip = dragPoint;
    if (tip != null) {
      canvas.drawLine(
        points.last,
        tip,
        line..color = color.withValues(alpha: 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CircleWheelPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.dragPoint != dragPoint ||
      oldDelegate.color != color;
}
