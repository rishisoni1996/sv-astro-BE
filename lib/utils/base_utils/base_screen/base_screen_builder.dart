import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/utils/base_utils/base_screen/base_screen.dart';
import 'package:flutter_app/utils/res/app_colors.dart';
import 'package:provider/provider.dart';
import '../base_provider.dart';

class BaseScreenBuilder<PV extends BaseProvider> extends StatefulWidget {
  final BaseScreen baseScreen;
  final Function(PV provider) setProvider;

  const BaseScreenBuilder(this.baseScreen, this.setProvider, {super.key});

  @override
  State<BaseScreenBuilder<PV>> createState() => _BaseScreenBuilderState<PV>();
}

class _BaseScreenBuilderState<PV extends BaseProvider> extends State<BaseScreenBuilder<PV>> {
  @override
  Widget build(BuildContext context) {
    PV provider = Provider.of<PV>(context, listen: false);

    // Initialize presenter if not already done
    if (!widget.baseScreen.isPresenterInitialized) {
      widget.setProvider(provider);
      widget.baseScreen.isPresenterInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.baseScreen.basePresenter.initPresenter();
      });
    }

    return widget.baseScreen.createScaffoldView() ??
        AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            systemNavigationBarColor: AppColors.bgDeep,
            systemNavigationBarIconBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: PopScope(
            canPop: widget.baseScreen.isBackEnabled,
            child: _buildScaffold(context),
          ),
        );
  }

  Scaffold _buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.baseScreen.backgroundColor ?? AppColors.bgDeep,
      appBar: getAppBar(context),
      body: widget.baseScreen.createView(),
      floatingActionButton: widget.baseScreen.appFloatingActionButton?.button,
      floatingActionButtonLocation:
          widget.baseScreen.appFloatingActionButton?.location,
      bottomNavigationBar: getBottomNavigationBar(),
    );
  }

  Widget? getBottomNavigationBar() {
    return widget.baseScreen.bottomNavBarItems != null
        ? Consumer<PV>(
            builder: (context, value, child) => NavigationBar(
                  onDestinationSelected: (int index) =>
                      value.updateNavigationIndex(index),
                  selectedIndex: value.selectedNavigationIndex,
                  destinations: widget.baseScreen.bottomNavBarItems!,
                ))
        : widget.baseScreen.bottomAppBar;
  }

  AppBar? getAppBar(BuildContext context) {
    if (!widget.baseScreen.hasAppBar) {
      return null;
    }
    return widget.baseScreen.customAppBar ??
        AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            systemNavigationBarColor: AppColors.bgDeep,
            statusBarIconBrightness: Brightness.light,
          ),
          leading: widget.baseScreen.isBackEnabled ? IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ) : null,
          titleSpacing: 0,
          title: widget.baseScreen.titleWidget ?? _titleWidget(widget.baseScreen.title ?? "base_screen", context),
          actions: widget.baseScreen.actionButtons,
          // bottom: PreferredSize(preferredSize: Size(5, 1), child: Divider(color: AppColors.black[400], height: 1),),
        );
  }

  Widget _titleWidget(String title, BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 20
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
