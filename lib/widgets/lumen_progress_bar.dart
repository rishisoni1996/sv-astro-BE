import 'package:flutter/material.dart';
import 'package:flutter_app/utils/res/app_colors.dart';

class LumenProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const LumenProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final active = i < currentStep;
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 4),
            decoration: BoxDecoration(
              color: active ? AppColors.accentPurple : AppColors.bgBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
