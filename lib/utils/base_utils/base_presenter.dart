import 'package:flutter/widgets.dart';
import 'base_provider.dart';

class BasePresenter<PV extends BaseProvider> {
  late PV provider;
  late BuildContext context;

  BasePresenter(this.provider, this.context);

  void initPresenter() {
    // Override in child classes if needed
  }
}