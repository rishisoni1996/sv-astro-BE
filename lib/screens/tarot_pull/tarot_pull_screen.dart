import 'package:flutter/material.dart';
import 'package:flutter_app/router/app_router.dart';
import 'package:flutter_app/utils/res/app_colors.dart';
import 'package:flutter_app/utils/res/app_strings.dart';
import 'package:flutter_app/widgets/painters/tarot_fan_painter.dart';
import 'package:go_router/go_router.dart';

class TarotPullScreen extends StatelessWidget {
  const TarotPullScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Text(AppStrings.tarotPullHeading,
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 10),
              Text(AppStrings.tarotPullSubheading,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        const Spacer(),
        TarotFan(
          cardCount: 11,
          onCardTap: (_) => context.push(AppRoutes.tarotMeaning),
        ),
        const SizedBox(height: 18),
        Text(AppStrings.tarotDeckName,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 40),
      ],
    );
  }
}
