import 'package:flutter/material.dart';
import 'package:flutter_app/utils/res/app_colors.dart';

class LumenQuizOption extends StatelessWidget {
  final String label;
  final bool selected;
  final bool multiSelect;
  final VoidCallback onTap;

  const LumenQuizOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.multiSelect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: selected ? AppColors.tagPurpleBg : AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.accentPurple : AppColors.bgBorder,
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              _Indicator(selected: selected, multiSelect: multiSelect),
            ],
          ),
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final bool selected;
  final bool multiSelect;
  const _Indicator({required this.selected, required this.multiSelect});

  @override
  Widget build(BuildContext context) {
    final shape = multiSelect
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: selected ? AppColors.accentPurple : Colors.transparent,
            border: Border.all(
              color: selected ? AppColors.accentPurple : AppColors.bgBorder,
              width: 1.5,
            ),
          )
        : BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? AppColors.accentPurple : Colors.transparent,
            border: Border.all(
              color: selected ? AppColors.accentPurple : AppColors.bgBorder,
              width: 1.5,
            ),
          );
    return Container(
      width: 22,
      height: 22,
      decoration: shape,
      alignment: Alignment.center,
      child: selected
          ? Icon(
              multiSelect ? Icons.check : Icons.circle,
              size: multiSelect ? 14 : 8,
              color: multiSelect ? AppColors.bgDeep : AppColors.bgDeep,
            )
          : null,
    );
  }
}
