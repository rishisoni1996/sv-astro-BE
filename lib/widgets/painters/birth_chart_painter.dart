import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/res/app_colors.dart';

class BirthChart extends StatelessWidget {
  final double size;
  const BirthChart({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BirthChartPainter()),
    );
  }
}

class _BirthChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outer = size.width / 2 - 2;
    final inner = outer * 0.58;
    final core = outer * 0.18;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.accentPurple.withValues(alpha: 0.45);

    canvas.drawCircle(center, outer, stroke);
    canvas.drawCircle(center, inner, stroke);
    canvas.drawCircle(
      center,
      core,
      Paint()..color = AppColors.accentPurple.withValues(alpha: 0.35),
    );

    // 12 radial lines
    final lineStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = AppColors.accentPurple.withValues(alpha: 0.3);
    for (int i = 0; i < 12; i++) {
      final a = -math.pi / 2 + i * (math.pi / 6);
      final p1 = Offset(center.dx + math.cos(a) * inner, center.dy + math.sin(a) * inner);
      final p2 = Offset(center.dx + math.cos(a) * outer, center.dy + math.sin(a) * outer);
      canvas.drawLine(p1, p2, lineStroke);
    }

    // 4 axis lines across
    final axisStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.accentPurple.withValues(alpha: 0.55);
    canvas.drawLine(
      Offset(center.dx - inner, center.dy),
      Offset(center.dx + inner, center.dy),
      axisStroke,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - inner),
      Offset(center.dx, center.dy + inner),
      axisStroke,
    );

    // Planet marker dots
    final dotPaint = Paint()..color = AppColors.accentGold;
    final positions = [
      -math.pi / 2 + 0.6,
      -math.pi / 2 + 2.1,
      -math.pi / 2 + 4.5,
    ];
    for (final a in positions) {
      final r = (inner + outer) / 2;
      canvas.drawCircle(
        Offset(center.dx + math.cos(a) * r, center.dy + math.sin(a) * r),
        2.2,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
