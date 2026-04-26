import 'package:flutter/material.dart';

class FrozenUserScreen extends StatelessWidget {
  const FrozenUserScreen({super.key});

  static void show(BuildContext? context) {}

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Frozen user')));
}
