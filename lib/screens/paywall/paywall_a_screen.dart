import 'package:flutter/material.dart';
import 'package:flutter_app/data/mock_data.dart';
import 'package:flutter_app/utils/res/app_colors.dart';
import 'package:flutter_app/utils/res/app_strings.dart';
import 'package:flutter_app/widgets/lumen_app_bar.dart';
import 'package:flutter_app/widgets/lumen_button.dart';
import 'package:flutter_app/widgets/lumen_orb.dart';
import 'package:flutter_app/widgets/lumen_plan_card.dart';
import 'package:flutter_app/widgets/lumen_starfield.dart';
import 'package:go_router/go_router.dart';

class PaywallAScreen extends StatefulWidget {
  const PaywallAScreen({super.key});

  @override
  State<PaywallAScreen> createState() => _PaywallAScreenState();
}

class _PaywallAScreenState extends State<PaywallAScreen> {
  String _selected = 'annual';

  @override
  Widget build(BuildContext context) {
    final plans = MockData.plans;

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
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    children: [
                      const SizedBox(height: 8),
                      const Center(child: LumenOrb(size: 140)),
                      const SizedBox(height: 28),
                      Text(AppStrings.paywallHeading,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text(AppStrings.paywallSubheading,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 24),
                      _feature(Icons.nightlight, AppStrings.paywallFeature1),
                      _feature(Icons.auto_awesome, AppStrings.paywallFeature2),
                      _feature(Icons.style_outlined, AppStrings.paywallFeature3),
                      _feature(Icons.insights_outlined,
                          AppStrings.paywallFeature4),
                      const SizedBox(height: 22),
                      Row(
                        children: plans.map((p) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: p == plans.last ? 0 : 10),
                              child: LumenPlanCard(
                                title: p.title,
                                price: p.price,
                                unit: p.unit,
                                badge: p.badge,
                                selected: _selected == p.id,
                                onTap: () => setState(() => _selected = p.id),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: LumenButton(
                    label: AppStrings.paywallCta,
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(AppStrings.paywallFinePrint,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _footerLink(AppStrings.paywallRestore),
                      _footerLink(AppStrings.paywallTerms),
                      _footerLink(AppStrings.paywallPrivacy),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _feature(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accentPurple.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.accentPurple.withValues(alpha: 0.4)),
            ),
            child: Icon(icon, size: 16, color: AppColors.accentPurple),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
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

  Widget _footerLink(String label) => GestureDetector(
        onTap: () {},
        child: Text(label,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.6,
            )),
      );
}
