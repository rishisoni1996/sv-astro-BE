import 'package:flutter/material.dart';
import 'package:flutter_app/utils/res/app_colors.dart';

class RippleHalo extends StatefulWidget {
  final double size;
  final int ringCount;
  const RippleHalo({super.key, this.size = 240, this.ringCount = 5});

  @override
  State<RippleHalo> createState() => _RippleHaloState();
}

class _RippleHaloState extends State<RippleHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
          painter: _RipplePainter(t: _c.value, ringCount: widget.ringCount),
        ),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double t;
  final int ringCount;
  _RipplePainter({required this.t, required this.ringCount});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;
    for (int i = 0; i < ringCount; i++) {
      final p = ((t + i / ringCount) % 1);
      final r = maxR * p;
      final alpha = (1 - p) * 0.25;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = AppColors.accentPurple.withValues(alpha: alpha);
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter old) => old.t != t;
}
