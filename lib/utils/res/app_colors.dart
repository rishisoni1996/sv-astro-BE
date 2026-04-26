import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color bgDeep = Color(0xFF0B0B1A);
  static const Color bgCard = Color(0xFF151530);
  static const Color bgBorder = Color(0xFF252548);
  static const Color bgAccent = Color(0xFF1A0B3A);
  static const Color bgElevated = Color(0xFF1C1C3A);

  // Text
  static const Color textPrimary = Color(0xFFF5F3FF);
  static const Color textSecondary = Color(0xFFA9A5C7);
  static const Color textTertiary = Color(0xFF6E6A8A);

  // Accents
  static const Color accentPurple = Color(0xFFC9A7FF);
  static const Color accentPurpleDark = Color(0xFF8B6BC4);
  static const Color accentTeal = Color(0xFF7EE6D4);
  static const Color accentGold = Color(0xFFFFD89E);
  static const Color accentLight = Color(0xFFE5DDFA);

  // Tag tones
  static const Color tagPurpleBg = Color(0x33C9A7FF);
  static const Color tagPurpleBorder = Color(0x66C9A7FF);
  static const Color tagGoldBg = Color(0x33FFD89E);
  static const Color tagGoldBorder = Color(0x66FFD89E);
  static const Color tagTealBg = Color(0x337EE6D4);
  static const Color tagTealBorder = Color(0x667EE6D4);

  // Surface overlays
  static const Color overlayWhite05 = Color(0x0DFFFFFF);
  static const Color overlayWhite10 = Color(0x1AFFFFFF);

  // Buttons
  static const Color btnPrimary = accentPurple;
  static const Color btnPrimaryText = Color(0xFF1A0B3A);
  static const Color btnGhostBorder = Color(0x33C9A7FF);

  // Gradients
  static const LinearGradient moonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5F3FF), Color(0xFFC9A7FF), Color(0xFF8B6BC4)],
  );

  static const RadialGradient orbGradient = RadialGradient(
    colors: [Color(0xFFC9A7FF), Color(0xFF8B6BC4), Color(0x008B6BC4)],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient cardOverlay = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x1AC9A7FF), Color(0x0D8B6BC4)],
  );

  static const LinearGradient tealCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x337EE6D4), Color(0x1A7EE6D4)],
  );

  static const LinearGradient goldCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x33FFD89E), Color(0x1AFFD89E)],
  );

  // Avatar gradient (used for Maya monogram)
  static const LinearGradient avatarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC9A7FF), Color(0xFF8B6BC4)],
  );

  // Hero card dark gradient (HomeB)
  static const LinearGradient heroDarkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A0B3A), Color(0xFF0B0B1A)],
  );
}
