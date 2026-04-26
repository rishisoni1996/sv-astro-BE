import 'package:flutter/material.dart';
import 'package:flutter_app/utils/res/app_colors.dart';

class LumenCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Gradient? gradient;
  final Color? background;
  final Color? border;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;

  const LumenCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 20,
    this.gradient,
    this.background,
    this.border,
    this.onTap,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: gradient == null ? (background ?? AppColors.bgCard) : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border ?? AppColors.bgBorder, width: 1),
      boxShadow: boxShadow,
    );

    final inner = Container(padding: padding, child: child);

    if (onTap == null) {
      return Container(decoration: decoration, child: inner);
    }

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: decoration,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: inner,
        ),
      ),
    );
  }
}
