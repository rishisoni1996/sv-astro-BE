import 'package:flutter/material.dart';
import 'package:flutter_app/utils/res/app_colors.dart';

enum LumenChipTone { purple, gold, teal }

class LumenChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final LumenChipTone tone;
  final bool small;

  const LumenChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.tone = LumenChipTone.purple,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color fg;
    switch (tone) {
      case LumenChipTone.purple:
        bg = selected ? AppColors.tagPurpleBg : Colors.transparent;
        border = selected ? AppColors.accentPurple : AppColors.bgBorder;
        fg = selected ? AppColors.accentPurple : AppColors.textSecondary;
        break;
      case LumenChipTone.gold:
        bg = selected ? AppColors.tagGoldBg : Colors.transparent;
        border = selected ? AppColors.accentGold : AppColors.bgBorder;
        fg = selected ? AppColors.accentGold : AppColors.textSecondary;
        break;
      case LumenChipTone.teal:
        bg = selected ? AppColors.tagTealBg : Colors.transparent;
        border = selected ? AppColors.accentTeal : AppColors.bgBorder;
        fg = selected ? AppColors.accentTeal : AppColors.textSecondary;
        break;
    }

    final radius = small ? 10.0 : 12.0;
    final padding = small
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
        : const EdgeInsets.symmetric(horizontal: 14, vertical: 8);
    const dur = Duration(milliseconds: 160);

    return AnimatedContainer(
      duration: dur,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.white.withValues(alpha: 0.04),
          child: Padding(
            padding: padding,
            child: AnimatedDefaultTextStyle(
              duration: dur,
              curve: Curves.easeOut,
              style: TextStyle(
                color: fg,
                fontSize: small ? 11 : 13,
                fontWeight: FontWeight.w500,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
