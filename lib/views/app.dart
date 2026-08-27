// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/providers.dart';
import 'package:words625/application/theme_provider.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/routing/routing.dart';
import 'package:words625/views/theme.dart';

final router = getIt<AppRouter>();

class Words625App extends StatelessWidget {
  const Words625App({Key? key}) : super(key: key);

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Varnamala',
            theme: VarnamalaTheme.lightTheme,
            darkTheme: VarnamalaTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: router.config(navigatorObservers: () => [observer]),
          );
        },
      ),
    );
  }
}
