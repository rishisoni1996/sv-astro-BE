import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/router/app_router.dart';
import 'package:flutter_app/utils/res/app_strings.dart';
import 'package:flutter_app/utils/res/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF0B0B1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const LumenApp());
}

class LumenApp extends StatelessWidget {
  const LumenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: buildLumenTheme(),
      routerConfig: buildRouter(),
    );
  }
}
