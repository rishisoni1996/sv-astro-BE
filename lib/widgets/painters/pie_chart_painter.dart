import 'dart:math' as math;
import 'package:flutter/material.dart';

class PieSegment {
  final String label;
  final double percent;
  final Color color;
  PieSegment({required this.label, required this.percent, required this.color});
}

class PieChart extends StatelessWidget {
  final List<PieSegment> segments;
  final double size;
  final double strokeWidth;
  const PieChart({
    super.key,
    required this.segments,
    this.size = 180,
    this.strokeWidth = 28,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PiePainter(segments, strokeWidth)),
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<PieSegment> segments;
  final double strokeWidth;
  _PiePainter(this.segments, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final total = segments.fold<double>(0, (sum, s) => sum + s.percent);
    double startAngle = -math.pi / 2; // start at 12 o'clock
    const gap = 0.02; // tiny gap between segments

    for (final s in segments) {
      final sweep = (s.percent / total) * (2 * math.pi) - gap;
      final paint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle + gap / 2, sweep, false, paint);
      startAngle += (s.percent / total) * (2 * math.pi);
    }
  }

  @override
  bool shouldRepaint(covariant _PiePainter old) =>
      old.segments != segments || old.strokeWidth != strokeWidth;
}
