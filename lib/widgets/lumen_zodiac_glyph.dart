import 'package:flutter/material.dart';
import 'package:flutter_app/utils/res/app_colors.dart';

enum ZodiacSign {
  aries, taurus, gemini, cancer, leo, virgo,
  libra, scorpio, sagittarius, capricorn, aquarius, pisces, sun,
}

class LumenZodiacGlyph extends StatelessWidget {
  final ZodiacSign sign;
  final double size;
  final Color color;
  const LumenZodiacGlyph({
    super.key,
    required this.sign,
    this.size = 24,
    this.color = AppColors.accentPurple,
  });

  String _glyph() {
    switch (sign) {
      case ZodiacSign.aries: return '♈';
      case ZodiacSign.taurus: return '♉';
      case ZodiacSign.gemini: return '♊';
      case ZodiacSign.cancer: return '♋';
      case ZodiacSign.leo: return '♌';
      case ZodiacSign.virgo: return '♍';
      case ZodiacSign.libra: return '♎';
      case ZodiacSign.scorpio: return '♏';
      case ZodiacSign.sagittarius: return '♐';
      case ZodiacSign.capricorn: return '♑';
      case ZodiacSign.aquarius: return '♒';
      case ZodiacSign.pisces: return '♓';
      case ZodiacSign.sun: return '☉';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _glyph(),
      style: TextStyle(fontSize: size, color: color, height: 1),
    );
  }
}
