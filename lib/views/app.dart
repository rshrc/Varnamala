// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Consumer;
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/providers.dart';
import 'package:words625/application/theme_notifier.dart';
import 'package:words625/application/theme_provider.dart';
import 'package:words625/core/migration_flags.dart';
import 'package:words625/core/responsive.dart';
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
      child: MigrationFlags.useRiverpodTheme
          ? _RiverpodThemedApp(observer: observer)
          : _LegacyThemedApp(observer: observer),
    );
  }
}

/// Reads theme state from the Riverpod [themeModeProvider].
class _RiverpodThemedApp extends ConsumerWidget {
  const _RiverpodThemedApp({required this.observer});

  final FirebaseAnalyticsObserver observer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final palette = ref.watch(paletteProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Varnamala',
      theme: buildAppTheme(palette, Brightness.light),
      darkTheme: buildAppTheme(palette, Brightness.dark),
      themeMode: themeMode,
      builder: (context, child) => SnackBarWidthCap(child: child!),
      routerConfig: router.config(navigatorObservers: () => [observer]),
    );
  }
}

/// Reads theme state from the legacy `provider`-based [ThemeProvider].
class _LegacyThemedApp extends StatelessWidget {
  const _LegacyThemedApp({required this.observer});

  final FirebaseAnalyticsObserver observer;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Varnamala',
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          builder: (context, child) => SnackBarWidthCap(child: child!),
          routerConfig: router.config(navigatorObservers: () => [observer]),
        );
      },
    );
  }
}
