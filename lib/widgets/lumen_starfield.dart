import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/res/app_colors.dart';

class LumenStarfield extends StatefulWidget {
  final int starCount;
  final Widget? child;
  const LumenStarfield({super.key, this.starCount = 90, this.child});

  @override
  State<LumenStarfield> createState() => _LumenStarfieldState();
}

class _LumenStarfieldState extends State<LumenStarfield>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(42);
    _stars = List.generate(widget.starCount, (_) {
      return _Star(
        dx: rng.nextDouble(),
        dy: rng.nextDouble(),
        radius: 0.4 + rng.nextDouble() * 1.4,
        phase: rng.nextDouble() * math.pi * 2,
        speed: 0.5 + rng.nextDouble() * 1.2,
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: AppColors.bgDeep),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _StarfieldPainter(_stars, _controller.value),
            );
          },
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _Star {
  final double dx;
  final double dy;
  final double radius;
  final double phase;
  final double speed;
  _Star({
    required this.dx,
    required this.dy,
    required this.radius,
    required this.phase,
    required this.speed,
  });
}

class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double t;
  _StarfieldPainter(this.stars, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.textPrimary;
    for (final s in stars) {
      final twinkle =
          (math.sin(t * math.pi * 2 * s.speed + s.phase) + 1) / 2; // 0..1
      final alpha = 0.25 + twinkle * 0.65;
      paint.color = AppColors.textPrimary.withValues(alpha: alpha);
      canvas.drawCircle(
        Offset(s.dx * size.width, s.dy * size.height),
        s.radius * (0.85 + twinkle * 0.3),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter old) => old.t != t;
}
