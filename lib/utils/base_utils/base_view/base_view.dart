import 'package:flutter/material.dart';

abstract class BaseView extends StatelessWidget {
  late final BuildContext viewContext;
  late final BuildContext baseContext;

  BaseView({super.key}) {
    return;
  }

  Widget createView();

  @override
  Widget build(BuildContext context) {
    viewContext = context;
    return createView();
  }
}
