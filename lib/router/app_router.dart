import 'package:flutter/material.dart';
import 'package:flutter_app/screens/cosmic/cosmic_screen.dart';
import 'package:flutter_app/screens/dream_entry/dream_entry_screen.dart';
import 'package:flutter_app/screens/dream_interpretation/dream_interpretation_screen.dart';
import 'package:flutter_app/screens/home/home_a_screen.dart';
import 'package:flutter_app/screens/home/home_b_screen.dart';
import 'package:flutter_app/screens/journal/journal_screen.dart';
import 'package:flutter_app/screens/main_shell/main_shell.dart';
import 'package:flutter_app/screens/patterns/patterns_screen.dart';
import 'package:flutter_app/screens/paywall/paywall_a_screen.dart';
import 'package:flutter_app/screens/paywall/paywall_b_screen.dart';
import 'package:flutter_app/screens/quiz/quiz_screen.dart';
import 'package:flutter_app/screens/sign_in/sign_in_screen.dart';
import 'package:flutter_app/screens/splash/splash_screen.dart';
import 'package:flutter_app/screens/tarot_meaning/tarot_meaning_screen.dart';
import 'package:flutter_app/screens/tarot_pull/tarot_pull_screen.dart';
import 'package:flutter_app/screens/welcome/welcome_screen.dart';
import 'package:flutter_app/screens/you/you_screen.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String quiz = '/quiz'; // /quiz/:step
  static const String signIn = '/sign-in';
  static const String cosmic = '/cosmic';

  // Shell tabs
  static const String homeToday = '/today';
  static const String homeTodayAlt = '/today-alt';
  static const String dreams = '/dreams';
  static const String readings = '/readings';
  static const String you = '/you';

  // Stacked
  static const String dreamEntry = '/dreams/entry';
  static const String dreamInterpretation = '/dreams/interpretation';
  static const String dreamPatterns = '/dreams/patterns';
  static const String tarotMeaning = '/readings/meaning';
  static const String paywallA = '/paywall/a';
  static const String paywallB = '/paywall/b';
}

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

GoRouter buildRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (_, __) => WelcomeScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.quiz}/:step',
        builder: (_, state) {
          final step = int.tryParse(state.pathParameters['step'] ?? '1') ?? 1;
          return QuizScreen(step: step);
        },
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (_, __) => SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.cosmic,
        builder: (_, __) => CosmicScreen(),
      ),

      // Shell with bottom nav
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) =>
            MainShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.homeToday,
            builder: (_, __) => HomeBScreen(),
          ),
          GoRoute(
            path: AppRoutes.homeTodayAlt,
            builder: (_, __) => HomeAScreen(),
          ),
          GoRoute(
            path: AppRoutes.dreams,
            builder: (_, __) => JournalScreen(),
          ),
          GoRoute(
            path: AppRoutes.readings,
            builder: (_, __) => TarotPullScreen(),
          ),
          GoRoute(
            path: AppRoutes.you,
            builder: (_, __) => YouScreen(),
          ),
        ],
      ),

      // Stacked routes (above the shell)
      GoRoute(
        path: AppRoutes.dreamEntry,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => DreamEntryScreen(),
      ),
      GoRoute(
        path: AppRoutes.dreamInterpretation,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => DreamInterpretationScreen(),
      ),
      GoRoute(
        path: AppRoutes.dreamPatterns,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => PatternsScreen(),
      ),
      GoRoute(
        path: AppRoutes.tarotMeaning,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => TarotMeaningScreen(),
      ),
      GoRoute(
        path: AppRoutes.paywallA,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => PaywallAScreen(),
      ),
      GoRoute(
        path: AppRoutes.paywallB,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => PaywallBScreen(),
      ),
    ],
  );
}
