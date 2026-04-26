import 'package:flutter/material.dart';
import 'package:flutter_app/utils/res/app_colors.dart';

class LumenMoonGlyph extends StatelessWidget {
  final double size;
  final bool withGlow;

  const LumenMoonGlyph({super.key, this.size = 140, this.withGlow = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.3),
          radius: 0.9,
          colors: [Color(0xFFF5F3FF), Color(0xFFC9A7FF), Color(0xFF8B6BC4)],
          stops: [0.0, 0.55, 1.0],
        ),
        boxShadow: withGlow
            ? [
                BoxShadow(
                  color: AppColors.accentPurple.withValues(alpha: 0.35),
                  blurRadius: size * 0.45,
                  spreadRadius: size * 0.08,
                ),
              ]
            : null,
      ),
    );
  }
}
