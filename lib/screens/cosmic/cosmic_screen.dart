import 'package:flutter/material.dart';
import 'package:flutter_app/data/mock_data.dart';
import 'package:flutter_app/models/lumen_models.dart';
import 'package:flutter_app/router/app_router.dart';
import 'package:flutter_app/utils/res/app_colors.dart';
import 'package:flutter_app/utils/res/app_strings.dart';
import 'package:flutter_app/widgets/lumen_app_bar.dart';
import 'package:flutter_app/widgets/lumen_button.dart';
import 'package:flutter_app/widgets/lumen_card.dart';
import 'package:flutter_app/widgets/lumen_chip.dart';
import 'package:flutter_app/widgets/lumen_starfield.dart';
import 'package:flutter_app/widgets/lumen_zodiac_glyph.dart';
import 'package:go_router/go_router.dart';

class CosmicScreen extends StatelessWidget {
  const CosmicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          const Positioned.fill(child: LumenStarfield(starCount: 90)),
          SafeArea(
            child: Column(
              children: [
                const LumenAppBar(showBack: true),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    children: [
                      Text(AppStrings.cosmicGreeting,
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 10),
                      Text(AppStrings.cosmicSubheading,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 24),
                      ...MockData.signReveals.map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SignRevealCard(reveal: s),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AppStrings.cosmicTraits
                            .map((t) => LumenChip(
                                  label: t,
                                  selected: true,
                                  tone: LumenChipTone.purple,
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: LumenButton(
                    label: AppStrings.cosmicCta,
                    onPressed: () => context.go(AppRoutes.homeToday),
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

class _SignRevealCard extends StatelessWidget {
  final SignReveal reveal;
  const _SignRevealCard({required this.reveal});

  @override
  Widget build(BuildContext context) {
    return LumenCard(
      gradient: reveal.gradient,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentPurple.withValues(alpha: 0.18),
              border: Border.all(
                color: AppColors.accentPurple.withValues(alpha: 0.5),
              ),
            ),
            child: LumenZodiacGlyph(sign: reveal.sign, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reveal.label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTertiary,
                      letterSpacing: 1.4,
                    )),
                const SizedBox(height: 2),
                Text(reveal.signName,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(reveal.description,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
