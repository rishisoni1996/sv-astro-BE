import 'package:flutter/material.dart';
import 'package:flutter_app/router/app_router.dart';
import 'package:flutter_app/utils/res/app_colors.dart';
import 'package:flutter_app/utils/res/app_strings.dart';
import 'package:flutter_app/widgets/lumen_button.dart';
import 'package:flutter_app/widgets/lumen_moon_glyph.dart';
import 'package:flutter_app/widgets/lumen_starfield.dart';
import 'package:flutter_app/widgets/painters/ripple_painter.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          const Positioned.fill(child: LumenStarfield(starCount: 90)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Stack(
                    alignment: Alignment.center,
                    children: const [
                      RippleHalo(size: 260),
                      LumenMoonGlyph(size: 140),
                    ],
                  ),
                  const Spacer(flex: 2),
                  Text(
                    AppStrings.welcomeHeading,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.welcomeBody,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const Spacer(flex: 3),
                  LumenButton(
                    label: AppStrings.welcomeCtaBegin,
                    onPressed: () => context.push('${AppRoutes.quiz}/1'),
                  ),
                  const SizedBox(height: 12),
                  LumenButton(
                    label: AppStrings.welcomeCtaSignIn,
                    variant: LumenButtonVariant.ghost,
                    onPressed: () => context.push(AppRoutes.signIn),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
