import 'package:flutter/material.dart';
import 'package:flutter_app/utils/res/app_colors.dart';
import 'package:flutter_app/utils/res/app_strings.dart';
import 'package:flutter_app/widgets/lumen_app_bar.dart';
import 'package:flutter_app/widgets/lumen_button.dart';
import 'package:flutter_app/widgets/lumen_card.dart';
import 'package:flutter_app/widgets/lumen_moon_glyph.dart';
import 'package:flutter_app/widgets/lumen_starfield.dart';
import 'package:go_router/go_router.dart';

class PaywallBScreen extends StatelessWidget {
  const PaywallBScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          const Positioned.fill(child: LumenStarfield(starCount: 70)),
          SafeArea(
            child: Column(
              children: [
                LumenAppBar(
                  showBack: false,
                  actions: [
                    LumenAppBarAction(
                        icon: Icons.close, onTap: () => context.pop()),
                  ],
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                    children: [
                      const Center(child: LumenMoonGlyph(size: 96)),
                      const SizedBox(height: 30),
                      Text('3 days free,\nthen unlimited',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayMedium),
                      const SizedBox(height: 14),
                      Text(
                          'Go deep. Unlock every interpretation, every reading, every pattern.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 28),
                      LumenCard(
                        gradient: AppColors.cardOverlay,
                        border: AppColors.accentPurple.withValues(alpha: 0.4),
                        child: Column(
                          children: [
                            _bullet('Unlimited dream interpretations'),
                            _bullet('Full pattern analysis'),
                            _bullet('Daily tarot & oracle readings'),
                            _bullet('Priority insights every morning'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      LumenCard(
                        gradient: AppColors.goldCardGradient,
                        border: AppColors.accentGold.withValues(alpha: 0.45),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            const Text('BEST VALUE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accentGold,
                                  letterSpacing: 1.5,
                                )),
                            const SizedBox(height: 6),
                            Text('Annual · \$49.99/yr',
                                style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 4),
                            Text('Equivalent to \$0.96/week',
                                style:
                                    Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                  child: LumenButton(
                    label: AppStrings.paywallCta,
                    onPressed: () => context.pop(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Text(AppStrings.paywallFinePrint,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            const Icon(Icons.check, color: AppColors.accentPurple, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  )),
            ),
          ],
        ),
      );
}
