import 'package:flutter/material.dart';
import 'package:flutter_app/utils/res/app_colors.dart';
import 'package:go_router/go_router.dart';

class LumenAppBar extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final bool showBack;
  final IconData backIcon;
  final List<Widget> actions;
  final VoidCallback? onBack;

  const LumenAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showBack = true,
    this.backIcon = Icons.arrow_back_ios_new,
    this.actions = const [],
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          if (showBack)
            _IconBtn(
              icon: backIcon,
              onTap: onBack ?? () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  Navigator.of(context).maybePop();
                }
              },
            )
          else
            const SizedBox(width: 40),
          Expanded(
            child: Center(
              child: titleWidget ??
                  (title == null
                      ? const SizedBox.shrink()
                      : Text(
                          title!,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                        )),
            ),
          ),
          if (actions.isEmpty)
            const SizedBox(width: 40)
          else
            Row(mainAxisSize: MainAxisSize.min, children: actions),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class LumenAppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const LumenAppBarAction({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => _IconBtn(icon: icon, onTap: onTap);
}
