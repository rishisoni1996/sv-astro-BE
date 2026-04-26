import 'package:flutter/material.dart';
import 'package:flutter_app/router/app_router.dart';
import 'package:flutter_app/utils/res/app_colors.dart';
import 'package:flutter_app/utils/res/app_strings.dart';
import 'package:flutter_app/widgets/lumen_card.dart';
import 'package:flutter_app/widgets/lumen_moon_glyph.dart';
import 'package:go_router/go_router.dart';

class HomeAScreen extends StatelessWidget {
  const HomeAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Row(
          children: [
            const LumenMoonGlyph(size: 36, withGlow: false),
            const SizedBox(width: 12),
            Text(AppStrings.homeDateBadge,
                style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
        const SizedBox(height: 18),
        Text(AppStrings.homeGreeting,
            style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 14),
        Text(AppStrings.homeGuidance,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary, fontSize: 15)),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: LumenCard(
                onTap: () => context.push(AppRoutes.dreamEntry),
                padding: const EdgeInsets.all(18),
                gradient: AppColors.cardOverlay,
                child: _tileBody(
                    Icons.mic_none_rounded,
                    AppStrings.homeRecordCta,
                    AppColors.accentPurple),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LumenCard(
          onTap: () => context.go(AppRoutes.readings),
          padding: const EdgeInsets.all(18),
          gradient: AppColors.goldCardGradient,
          child: _tileBody(
              Icons.style_outlined, AppStrings.homeTarotCta, AppColors.accentGold),
        ),
        const SizedBox(height: 12),
        LumenCard(
          onTap: () => context.push(AppRoutes.dreamPatterns),
          gradient: AppColors.tealCardGradient,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.homeWeeklyTitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentTeal,
                    letterSpacing: 1.2,
                  )),
              const SizedBox(height: 10),
              Text(AppStrings.homeWeeklyBody,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary, fontSize: 15)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LumenCard(
          onTap: () => context.go(AppRoutes.homeToday),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.swap_horiz,
                  color: AppColors.accentPurple, size: 18),
              const SizedBox(width: 10),
              Text('Switch layout (Home B)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tileBody(IconData icon, String label, Color tint) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tint.withValues(alpha: 0.5)),
          ),
          child: Icon(icon, color: tint, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.35,
              )),
        ),
        const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      ],
    );
  }
}
