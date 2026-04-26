import 'package:flutter/material.dart';
import 'package:flutter_app/utils/base_utils/base_presenter.dart';
import 'package:flutter_app/utils/base_utils/base_provider.dart';
import 'package:flutter_app/utils/base_utils/base_screen/base_screen_builder.dart';
import 'package:flutter_app/utils/fab_utils/app_floating_actiona_button.dart';
import 'package:provider/provider.dart';


abstract class BaseScreen<PV extends BaseProvider, P extends BasePresenter>
    extends StatelessWidget {
  late PV baseProvider;
  late P basePresenter;
  late BuildContext baseContext;
  bool isPresenterInitialized = false;

  BaseScreen({super.key}) {
    return;
  }

  PV setProvider();

  P setPresenter();

  Widget createView();

  bool get isBackEnabled => true;

  Widget? createScaffoldView() => null;

  String? get title => "base_screen";

  Widget? get titleWidget => null;

  bool get hasAppBar => true;

  AppBar? get customAppBar => null;

  List<Widget> get actionButtons => [];

  AppFloatingActionButton? get appFloatingActionButton => null;

  List<NavigationDestination>? get bottomNavBarItems => null;

  Widget? get bottomAppBar => null;

  Color? get backgroundColor => null;

  @override
  Widget build(BuildContext context) {
    baseContext = context;
    return ChangeNotifierProvider<PV>(
      create: (context) => setProvider(),
      builder: (context, child) => BaseScreenBuilder<PV>(
        this,
        (provider) {
          baseProvider = provider;
          basePresenter = setPresenter()
            ..provider = provider
            ..context = context;
        },
      ),
    );
  }
}
