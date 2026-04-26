import 'package:flutter/material.dart';
import 'package:flutter_app/data/mock_data.dart';
import 'package:flutter_app/utils/res/app_colors.dart';
import 'package:flutter_app/utils/res/app_strings.dart';
import 'package:flutter_app/widgets/lumen_app_bar.dart';
import 'package:flutter_app/widgets/lumen_button.dart';
import 'package:flutter_app/widgets/lumen_card.dart';
import 'package:go_router/go_router.dart';

class TarotMeaningScreen extends StatelessWidget {
  const TarotMeaningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final card = MockData.todaysCard;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            LumenAppBar(
              showBack: true,
              backIcon: Icons.close,
              actions: [
                LumenAppBarAction(icon: Icons.ios_share, onTap: () {}),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                children: [
                  Center(child: _CardFace(card: card)),
                  const SizedBox(height: 24),
                  Text(card.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text(card.keywords.join('  ·  '),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.accentTeal,
                        letterSpacing: 1.6,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 28),
                  _Section(
                    label: AppStrings.tarotSection1,
                    body: card.whatShows,
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    label: AppStrings.tarotSection2,
                    body: card.appliesToToday,
                  ),
                  const SizedBox(height: 16),
                  LumenCard(
                    gradient: AppColors.cardOverlay,
                    border: AppColors.accentPurple.withValues(alpha: 0.35),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.tarotSection3,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: AppColors.accentPurple)),
                        const SizedBox(height: 10),
                        Text(card.questionToCarry,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 20,
                                    height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Row(
                children: [
                  Expanded(
                    child: LumenButton(
                      label: AppStrings.tarotSave,
                      variant: LumenButtonVariant.ghost,
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LumenButton(
                      label: AppStrings.tarotPullAnother,
                      onPressed: () => context.pop(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final dynamic card;
  const _CardFace({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 270,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B0F3A), Color(0xFF0B0B1A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withValues(alpha: 0.4),
            blurRadius: 60,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Text(card.numeral,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.accentGold,
                    letterSpacing: 1.4,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ),
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment(-0.2, -0.3),
                  colors: [
                    Color(0xFFF5F3FF),
                    Color(0xFFC9A7FF),
                    Color(0xFF6A4FA0),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          Text(card.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    color: AppColors.accentGold,
                  )),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final String body;
  const _Section({required this.label, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 10),
        Text(body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
                fontSize: 15,
                height: 1.55)),
      ],
    );
  }
}
