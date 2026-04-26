import 'package:flutter/material.dart';
import 'package:flutter_app/utils/res/app_colors.dart';

enum LumenButtonVariant { primary, ghost, dark, light }

class LumenButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final LumenButtonVariant variant;
  final IconData? leadingIcon;
  final bool fullWidth;
  final double height;

  const LumenButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = LumenButtonVariant.primary,
    this.leadingIcon,
    this.fullWidth = true,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        );

    Color bg;
    Color fg;
    BoxBorder? border;
    List<BoxShadow>? shadow;
    switch (variant) {
      case LumenButtonVariant.primary:
        bg = AppColors.accentPurple;
        fg = AppColors.btnPrimaryText;
        shadow = [
          BoxShadow(
            color: AppColors.accentPurple.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ];
        break;
      case LumenButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.textPrimary;
        border = Border.all(color: AppColors.btnGhostBorder, width: 1);
        break;
      case LumenButtonVariant.dark:
        bg = AppColors.bgCard;
        fg = AppColors.textPrimary;
        border = Border.all(color: AppColors.bgBorder, width: 1);
        break;
      case LumenButtonVariant.light:
        bg = AppColors.textPrimary;
        fg = AppColors.bgDeep;
        break;
    }

    final child = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: border,
            boxShadow: shadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, color: fg, size: 18),
                const SizedBox(width: 10),
              ],
              Text(label, style: textStyle?.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: child) : child;
  }
}
