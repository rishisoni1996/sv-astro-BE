import 'package:flutter/material.dart';
import 'package:flutter_app/utils/res/app_colors.dart';

class LumenOrb extends StatelessWidget {
  final double size;
  final Gradient gradient;
  final double glowRadius;
  final Color glowColor;

  const LumenOrb({
    super.key,
    this.size = 160,
    this.gradient = AppColors.orbGradient,
    this.glowRadius = 60,
    this.glowColor = const Color(0x66C9A7FF),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: glowRadius,
            spreadRadius: 6,
          ),
        ],
      ),
    );
  }
}
