import 'package:flutter/material.dart';
import 'package:flutter_app/utils/base_utils/base_presenter.dart';
import 'package:flutter_app/utils/base_utils/base_provider.dart';
import 'package:provider/provider.dart';
import 'base_view.dart';
import 'base_view_pro_builder.dart';

abstract class BaseViewPro<PV extends BaseProvider, P extends BasePresenter>
    extends BaseView {
  late final BaseProvider bsProvider;
  late final BasePresenter bsPresenter;

  late final PV viewProvider;
  late final P viewPresenter;

  BaseViewPro({super.key});

  PV setViewProvider();

  P setViewPresenter();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PV>(
      create: (context) => setViewProvider(),
      builder: (context, child) {
        return BaseViewProBuilder<PV>(this, (provider) => viewProvider = provider);
      }
    );
  }
}
