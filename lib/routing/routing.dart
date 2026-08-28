// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:words625/routing/routing.gr.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/service/language_preference_service.dart';
import 'package:words625/service/locator.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  late final AutoRouteGuard _authGuard = _FirebaseAuthGuard();
  late final AutoRouteGuard _languageGuard = _LanguageSelectionGuard();

  @override
  RouteType get defaultRouteType => const RouteType.cupertino();
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(
          page: InteractiveLessonDemoRoute.page,
          path: '/interactive-lab',
        ),
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: LangChoiceRoute.page, guards: [_authGuard]),
        AutoRoute(
          page: HomeRoute.page,
          guards: [_authGuard, _languageGuard],
        ),
        AutoRoute(
          page: LessonRoute.page,
          guards: [_authGuard, _languageGuard],
        ),
        AutoRoute(
          page: VowelAndConsonantLearningRoute.page,
          guards: [_authGuard, _languageGuard],
        ),
        AutoRoute(
          page: MatchWordsRoute.page,
          guards: [_authGuard, _languageGuard],
        ),
      ];
}

class _LanguageSelectionGuard extends AutoRouteGuard {
  @override
  Future<void> onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      resolver.next(false);
      return;
    }

    final selection = await LanguagePreferenceService(getIt<AppPrefs>())
        .restoreForUser(user.uid);
    if (selection != null) {
      resolver.next();
      return;
    }

    await router.replaceAll([const LangChoiceRoute()]);
    resolver.next(false);
  }
}

class _FirebaseAuthGuard extends AutoRouteGuard {
  @override
  Future<void> onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser ?? await auth.authStateChanges().first;

    if (user != null) {
      resolver.next();
      return;
    }

    await router.replaceAll([const SplashRoute()]);
    resolver.next(false);
  }
}
