import 'package:flutter/material.dart';
import 'package:flutter_app/router/app_router.dart';
import 'package:flutter_app/utils/res/app_colors.dart';
import 'package:flutter_app/utils/res/app_strings.dart';
import 'package:flutter_app/widgets/lumen_app_bar.dart';
import 'package:flutter_app/widgets/lumen_button.dart';
import 'package:flutter_app/widgets/lumen_moon_glyph.dart';
import 'package:flutter_app/widgets/lumen_starfield.dart';
import 'package:go_router/go_router.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  void _advance(BuildContext context) => context.go(AppRoutes.homeToday);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          const Positioned.fill(child: LumenStarfield(starCount: 80)),
          SafeArea(
            child: Column(
              children: [
                const LumenAppBar(title: ''),
                const Spacer(flex: 2),
                const LumenMoonGlyph(size: 56),
                const SizedBox(height: 24),
                Text(AppStrings.signInHeading,
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 8),
                Text(AppStrings.signInSubheading,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center),
                const Spacer(flex: 3),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      LumenButton(
                        label: AppStrings.signInApple,
                        variant: LumenButtonVariant.light,
                        leadingIcon: Icons.apple,
                        onPressed: () => _advance(context),
                      ),
                      const SizedBox(height: 12),
                      LumenButton(
                        label: AppStrings.signInGoogle,
                        variant: LumenButtonVariant.dark,
                        leadingIcon: Icons.g_mobiledata,
                        onPressed: () => _advance(context),
                      ),
                      const SizedBox(height: 12),
                      LumenButton(
                        label: AppStrings.signInEmail,
                        variant: LumenButtonVariant.dark,
                        leadingIcon: Icons.mail_outline,
                        onPressed: () => _advance(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () => context.go('${AppRoutes.quiz}/1'),
                  child: Text(
                    AppStrings.signInNewHere,
                    style: const TextStyle(
                      color: AppColors.accentPurple,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
