import 'package:flutter/material.dart';
import 'package:flutter_app/router/app_router.dart';
import 'package:flutter_app/utils/res/app_colors.dart';
import 'package:flutter_app/utils/res/app_strings.dart';
import 'package:go_router/go_router.dart';

class LumenBottomNav extends StatelessWidget {
  final String currentLocation;
  const LumenBottomNav({super.key, required this.currentLocation});

  @override
  Widget build(BuildContext context) {
    final items = <_NavItem>[
      _NavItem(
        route: AppRoutes.homeToday,
        altRoute: AppRoutes.homeTodayAlt,
        label: AppStrings.navToday,
        iconOutline: Icons.auto_awesome_outlined,
        iconFilled: Icons.auto_awesome,
      ),
      _NavItem(
        route: AppRoutes.dreams,
        label: AppStrings.navDreams,
        iconOutline: Icons.nightlight_outlined,
        iconFilled: Icons.nightlight,
      ),
      _NavItem(
        route: AppRoutes.readings,
        label: AppStrings.navReadings,
        iconOutline: Icons.style_outlined,
        iconFilled: Icons.style,
      ),
      _NavItem(
        route: AppRoutes.you,
        label: AppStrings.navYou,
        iconOutline: Icons.person_outline,
        iconFilled: Icons.person,
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgDeep,
        border: Border(
          top: BorderSide(color: AppColors.bgBorder, width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 6,
      ),
      child: Row(
        children: items.map((item) {
          final active = item.matches(currentLocation);
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.go(item.route),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? item.iconFilled : item.iconOutline,
                        size: 22,
                        color: active
                            ? AppColors.accentPurple
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                          color: active
                              ? AppColors.accentPurple
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem {
  final String route;
  final String? altRoute;
  final String label;
  final IconData iconOutline;
  final IconData iconFilled;
  _NavItem({
    required this.route,
    this.altRoute,
    required this.label,
    required this.iconOutline,
    required this.iconFilled,
  });

  bool matches(String location) =>
      location.startsWith(route) ||
      (altRoute != null && location.startsWith(altRoute!));
}
