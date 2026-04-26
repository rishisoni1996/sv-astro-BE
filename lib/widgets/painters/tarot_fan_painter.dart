import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/res/app_colors.dart';

class TarotFan extends StatelessWidget {
  final int cardCount;
  final double cardWidth;
  final double cardHeight;
  final double spreadDegrees;
  final ValueChanged<int>? onCardTap;

  const TarotFan({
    super.key,
    this.cardCount = 11,
    this.cardWidth = 90,
    this.cardHeight = 148,
    this.spreadDegrees = 70,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardHeight + 40,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final centerX = constraints.maxWidth / 2;
          final spreadRad = spreadDegrees * math.pi / 180;
          final step = spreadRad / (cardCount - 1);

          return Stack(
            alignment: Alignment.topCenter,
            children: List.generate(cardCount, (i) {
              final angle = -spreadRad / 2 + step * i;
              final arcRadius = 260.0;
              final x = centerX + math.sin(angle) * 80 - cardWidth / 2;
              final y = (1 - math.cos(angle)) * arcRadius * 0.15;
              return Positioned(
                left: x,
                top: y,
                child: Transform.rotate(
                  angle: angle,
                  child: _TarotCardBack(
                    width: cardWidth,
                    height: cardHeight,
                    onTap: () => onCardTap?.call(i),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _TarotCardBack extends StatelessWidget {
  final double width;
  final double height;
  final VoidCallback onTap;
  const _TarotCardBack({
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A0B3A), Color(0xFF0B0B1A)],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.5)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x80000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: CustomPaint(painter: _StarBack()),
        ),
      ),
    );
  }
}

class _StarBack extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentPurple.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.25;

    final path = Path();
    for (int i = 0; i < 5; i++) {
      final a1 = -math.pi / 2 + i * 2 * math.pi / 5;
      final a2 = a1 + math.pi * 4 / 5;
      final p1 = Offset(center.dx + r * math.cos(a1), center.dy + r * math.sin(a1));
      final p2 = Offset(center.dx + r * math.cos(a2), center.dy + r * math.sin(a2));
      if (i == 0) {
        path.moveTo(p1.dx, p1.dy);
      } else {
        path.lineTo(p1.dx, p1.dy);
      }
      path.lineTo(p2.dx, p2.dy);
    }
    path.close();
    canvas.drawPath(path, paint);

    // Ring
    canvas.drawCircle(center, r * 1.6, paint..strokeWidth = 0.7);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
