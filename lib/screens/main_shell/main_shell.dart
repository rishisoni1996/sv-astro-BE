import 'package:flutter/material.dart';
import 'package:flutter_app/utils/res/app_colors.dart';
import 'package:flutter_app/widgets/lumen_bottom_nav.dart';
import 'package:flutter_app/widgets/lumen_starfield.dart';

class MainShell extends StatelessWidget {
  final String location;
  final Widget child;
  const MainShell({super.key, required this.location, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          const Positioned.fill(child: LumenStarfield(starCount: 60)),
          SafeArea(bottom: false, child: child),
        ],
      ),
      bottomNavigationBar: LumenBottomNav(currentLocation: location),
    );
  }
}
