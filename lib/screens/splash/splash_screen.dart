import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/router/app_router.dart';
import 'package:flutter_app/utils/res/app_colors.dart';
import 'package:flutter_app/utils/res/app_strings.dart';
import 'package:flutter_app/widgets/lumen_moon_glyph.dart';
import 'package:flutter_app/widgets/lumen_starfield.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _barController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
    _timer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) context.go(AppRoutes.welcome);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          const Positioned.fill(child: LumenStarfield(starCount: 80)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LumenMoonGlyph(size: 84),
                const SizedBox(height: 28),
                Text(
                  AppStrings.appName,
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontSize: 52),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.tagline,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 160,
                  height: 3,
                  child: AnimatedBuilder(
                    animation: _barController,
                    builder: (_, __) => Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.bgBorder,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: _barController.value,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.moonGradient,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
