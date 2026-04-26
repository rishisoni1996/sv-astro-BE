import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_app/data/mock_data.dart';
import 'package:flutter_app/models/lumen_models.dart';
import 'package:flutter_app/router/app_router.dart';
import 'package:flutter_app/utils/res/app_colors.dart';
import 'package:flutter_app/utils/res/app_strings.dart';
import 'package:flutter_app/widgets/lumen_app_bar.dart';
import 'package:flutter_app/widgets/lumen_card.dart';
import 'package:flutter_app/widgets/lumen_chip.dart';
import 'package:go_router/go_router.dart';

class DreamInterpretationScreen extends StatelessWidget {
  const DreamInterpretationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dream = MockData.dreams.first;
    final interp = dream.interpretation!;
    final isPremium = MockData.currentUser.isPremium;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            LumenAppBar(
              title: 'Mar 14',
              actions: [
                LumenAppBarAction(icon: Icons.ios_share, onTap: () {}),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                children: [
                  Wrap(
                    spacing: 6,
                    children: dream.typeTags
                        .map((t) => LumenChip(
                              label: t,
                              selected: true,
                              tone: LumenChipTone.purple,
                              small: true,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  Text(dream.title,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  LumenCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dream.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                height: 1.5)),
                        const SizedBox(height: 10),
                        Text(AppStrings.interpReadFull,
                            style: const TextStyle(
                              color: AppColors.accentPurple,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  _Section(
                    icon: Icons.auto_awesome,
                    title: AppStrings.interpCoreMeaning,
                    body: interp.coreMeaning,
                    tint: AppColors.accentPurple,
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    icon: Icons.visibility_outlined,
                    title: AppStrings.interpReveals,
                    body: interp.whatReveals,
                    tint: AppColors.accentTeal,
                    blurred: !isPremium,
                    onUnlock: () => context.push(AppRoutes.paywallA),
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    icon: Icons.wb_sunny_outlined,
                    title: AppStrings.interpGuidance,
                    body: interp.guidance,
                    tint: AppColors.accentGold,
                    blurred: !isPremium,
                    onUnlock: () => context.push(AppRoutes.paywallA),
                  ),
                  const SizedBox(height: 24),
                  Text(AppStrings.interpSymbols,
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: interp.symbols.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => _SymbolCard(symbol: interp.symbols[i]),
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

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color tint;
  final bool blurred;
  final VoidCallback? onUnlock;
  const _Section({
    required this.icon,
    required this.title,
    required this.body,
    required this.tint,
    this.blurred = false,
    this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: tint, size: 18),
            const SizedBox(width: 10),
            Text(title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: tint,
                      fontWeight: FontWeight.w600,
                    )),
          ],
        ),
        const SizedBox(height: 12),
        Text(body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
                fontSize: 15,
                height: 1.55)),
      ],
    );

    if (!blurred) return content;

    return Stack(
      children: [
        content,
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bgDeep.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: onUnlock,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accentPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline,
                            size: 14, color: AppColors.bgDeep),
                        SizedBox(width: 6),
                        Text('Unlock',
                            style: TextStyle(
                              color: AppColors.bgDeep,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            )),
                      ],
                    ),
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

class _SymbolCard extends StatelessWidget {
  final DreamSymbol symbol;
  const _SymbolCard({required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: symbol.gradient,
        color: symbol.gradient == null ? AppColors.bgCard : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(symbol.emoji, style: const TextStyle(fontSize: 22)),
          const Spacer(),
          Text(symbol.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          Text('${symbol.count}×  ·  ${symbol.lastSeen}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              )),
        ],
      ),
    );
  }
}
