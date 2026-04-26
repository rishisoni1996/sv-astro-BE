import 'package:flutter/material.dart';
import 'package:flutter_app/data/mock_data.dart';
import 'package:flutter_app/router/app_router.dart';
import 'package:flutter_app/utils/res/app_colors.dart';
import 'package:flutter_app/utils/res/app_strings.dart';
import 'package:flutter_app/widgets/lumen_card.dart';
import 'package:go_router/go_router.dart';

class HomeBScreen extends StatelessWidget {
  const HomeBScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        _HeroCard(initials: user.initials),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.mic_none_rounded,
                title: AppStrings.homeRecordCta,
                tint: AppColors.accentPurple,
                onTap: () => context.push(AppRoutes.dreamEntry),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.style_outlined,
                title: AppStrings.homeTarotCta,
                tint: AppColors.accentGold,
                onTap: () => context.go(AppRoutes.readings),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _WeeklyCard(onTap: () => context.push(AppRoutes.dreamPatterns)),
        const SizedBox(height: 16),
        LumenCard(
          onTap: () => context.go(AppRoutes.homeTodayAlt),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.swap_horiz,
                  color: AppColors.accentPurple, size: 18),
              const SizedBox(width: 10),
              Text('Switch layout (Home A)',
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
}

class _HeroCard extends StatelessWidget {
  final String initials;
  const _HeroCard({required this.initials});

  @override
  Widget build(BuildContext context) {
    return LumenCard(
      padding: const EdgeInsets.all(22),
      gradient: AppColors.heroDarkGradient,
      border: AppColors.accentPurple.withValues(alpha: 0.35),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x66C9A7FF), Color(0x00C9A7FF)],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.overlayWhite10,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(AppStrings.homeDateBadge,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.8,
                    )),
              ),
              const SizedBox(height: 18),
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.avatarGradient,
                ),
                child: Text(initials,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.bgDeep,
                    )),
              ),
              const SizedBox(height: 14),
              Text(AppStrings.homeGreeting,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(AppStrings.homeGuidance,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.55,
                      fontSize: 15)),
              const SizedBox(height: 10),
              Text(AppStrings.homeSubGuidance,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color tint;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.tint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LumenCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: tint.withValues(alpha: 0.4)),
            ),
            child: Icon(icon, color: tint, size: 18),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.35,
              )),
        ],
      ),
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  final VoidCallback onTap;
  const _WeeklyCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LumenCard(
      onTap: onTap,
      gradient: AppColors.tealCardGradient,
      border: AppColors.accentTeal.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_outlined,
                  color: AppColors.accentTeal, size: 18),
              const SizedBox(width: 8),
              Text(AppStrings.homeWeeklyTitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentTeal,
                    letterSpacing: 1.2,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          Text(AppStrings.homeWeeklyBody,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.5)),
        ],
      ),
    );
  }
}
