import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_app/data/mock_data.dart';
import 'package:flutter_app/models/lumen_models.dart';
import 'package:flutter_app/router/app_router.dart';
import 'package:flutter_app/utils/res/app_colors.dart';
import 'package:flutter_app/utils/res/app_strings.dart';
import 'package:flutter_app/widgets/lumen_app_bar.dart';
import 'package:flutter_app/widgets/lumen_card.dart';
import 'package:flutter_app/widgets/painters/pie_chart_painter.dart';
import 'package:go_router/go_router.dart';

class PatternsScreen extends StatelessWidget {
  const PatternsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = MockData.weeklyPatterns;
    final isPremium = MockData.currentUser.isPremium;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            const LumenAppBar(showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                children: [
                  Text(AppStrings.patternsTitle,
                      style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 8),
                  Text(AppStrings.patternsSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 26),
                  Text(AppStrings.patternsSymbols,
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 138,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: p.recurringSymbols.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => _SymbolTile(p.recurringSymbols[i]),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(AppStrings.patternsThemes,
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 16),
                  LumenCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        PieChart(
                          segments: p.themes
                              .map((t) => PieSegment(
                                  label: t.label,
                                  percent: t.percent,
                                  color: t.color))
                              .toList(),
                          size: 150,
                          strokeWidth: 22,
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: p.themes
                                .map((t) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: _LegendRow(theme: t),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _WeeklySummary(
                    summary: p.weeklySummary,
                    locked: !isPremium,
                    onUnlock: () => context.push(AppRoutes.paywallA),
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

class _SymbolTile extends StatelessWidget {
  final DreamSymbol symbol;
  const _SymbolTile(this.symbol);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: symbol.gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(symbol.emoji, style: const TextStyle(fontSize: 24)),
          const Spacer(),
          Text(symbol.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text('${symbol.count}×',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              )),
          Text(symbol.lastSeen,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 10,
              )),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final EmotionalTheme theme;
  const _LegendRow({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: theme.color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Text(theme.label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            )),
        const Spacer(),
        Text('${theme.percent.toInt()}%',
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 12,
            )),
      ],
    );
  }
}

class _WeeklySummary extends StatelessWidget {
  final String summary;
  final bool locked;
  final VoidCallback? onUnlock;
  const _WeeklySummary({
    required this.summary,
    required this.locked,
    this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    final card = LumenCard(
      gradient: AppColors.cardOverlay,
      border: AppColors.accentPurple.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.patternsWeekly,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.accentPurple,
                  letterSpacing: 1.1)),
          const SizedBox(height: 12),
          Text(summary,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.55)),
        ],
      ),
    );

    if (!locked) return card;

    return Stack(
      children: [
        card,
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: GestureDetector(
                onTap: onUnlock,
                child: Container(
                  color: AppColors.bgDeep.withValues(alpha: 0.4),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline,
                          size: 22, color: AppColors.accentGold),
                      const SizedBox(height: 6),
                      Text(AppStrings.patternsLocked,
                          style: const TextStyle(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: 1.2,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
