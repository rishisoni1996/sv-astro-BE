import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

ThemeData buildLumenTheme() {
  final base = ThemeData.dark(useMaterial3: true);

  final serif = GoogleFonts.frauncesTextTheme(base.textTheme);
  final sans = GoogleFonts.interTextTheme(base.textTheme);

  final textTheme = base.textTheme.copyWith(
    displayLarge: serif.displayLarge?.copyWith(
      fontSize: 52,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      letterSpacing: -1.0,
      height: 1.05,
    ),
    displayMedium: serif.displayMedium?.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      letterSpacing: -0.6,
      height: 1.1,
    ),
    displaySmall: serif.displaySmall?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      letterSpacing: -0.4,
      height: 1.15,
    ),
    headlineLarge: serif.headlineLarge?.copyWith(
      fontSize: 30,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      height: 1.2,
    ),
    headlineMedium: serif.headlineMedium?.copyWith(
      fontSize: 26,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      height: 1.25,
    ),
    headlineSmall: serif.headlineSmall?.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      height: 1.3,
    ),
    titleLarge: serif.titleLarge?.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    titleMedium: sans.titleMedium?.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleSmall: sans.titleSmall?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.6,
    ),
    bodyLarge: sans.bodyLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.5,
    ),
    bodyMedium: sans.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.5,
    ),
    bodySmall: sans.bodySmall?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.45,
    ),
    labelLarge: sans.labelLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    labelMedium: sans.labelMedium?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
      letterSpacing: 1.2,
    ),
    labelSmall: sans.labelSmall?.copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: AppColors.textTertiary,
      letterSpacing: 1.4,
    ),
  );

  return base.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgDeep,
    canvasColor: AppColors.bgDeep,
    primaryColor: AppColors.accentPurple,
    colorScheme: const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.accentPurple,
      onPrimary: AppColors.btnPrimaryText,
      secondary: AppColors.accentTeal,
      onSecondary: AppColors.bgDeep,
      tertiary: AppColors.accentGold,
      onTertiary: AppColors.bgDeep,
      surface: AppColors.bgCard,
      onSurface: AppColors.textPrimary,
      error: Color(0xFFFF8A9A),
      onError: AppColors.bgDeep,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.textPrimary,
      centerTitle: false,
    ),
    textTheme: textTheme,
    iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
    dividerColor: AppColors.bgBorder,
    splashColor: AppColors.overlayWhite05,
    highlightColor: AppColors.overlayWhite05,
  );
}
