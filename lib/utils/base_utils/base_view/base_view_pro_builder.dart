import 'package:flutter/widgets.dart';
import 'package:flutter_app/utils/base_utils/base_provider.dart';
import 'package:provider/provider.dart';
import 'base_view_pro.dart';

class BaseViewProBuilder<PV extends BaseProvider> extends StatelessWidget {
  final BaseViewPro baseView;
  final Function(PV provider) setViewProvider;

  const BaseViewProBuilder(this.baseView, this.setViewProvider, {super.key});

  @override
  Widget build(BuildContext context) {
    PV provider = Provider.of<PV>(context, listen: false);
    setViewProvider(provider);
    baseView.viewContext = context;
    baseView.viewPresenter = baseView.setViewPresenter();
    return baseView.createView();
  }
}