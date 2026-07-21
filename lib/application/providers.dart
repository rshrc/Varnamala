// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/achievements_provider.dart';
import 'package:words625/application/activity_provider.dart';
import 'package:words625/application/character_provider.dart';
import 'package:words625/application/community_provider.dart';
import 'package:words625/application/course_provider.dart';
import 'package:words625/application/game_provider.dart';
import 'package:words625/application/gems_provider.dart';
import 'package:words625/application/hearts_provider.dart';
import 'package:words625/application/identity_provider.dart';
import 'package:words625/application/language_provider.dart';
import 'package:words625/application/league_provider.dart';
import 'package:words625/application/level_provider.dart';
import 'package:words625/application/match_provider.dart';
import 'package:words625/application/theme_provider.dart';
import 'package:words625/di/injection.dart';

final providers = [
  ChangeNotifierProvider<ThemeProvider>(
    create: (_) => ThemeProvider(),
  ),
  ChangeNotifierProvider<LessonProvider>(
    create: (_) => getIt<LessonProvider>(),
  ),
  ChangeNotifierProvider<CharacterProvider>(
    create: (_) => getIt<CharacterProvider>(),
  ),
  ChangeNotifierProvider<LanguageProvider>(
    create: (_) => getIt<LanguageProvider>(),
  ),
  ChangeNotifierProvider<CourseProvider>(
    create: (_) => getIt<CourseProvider>(),
  ),
  // for GameProvider
  ChangeNotifierProvider<GameProvider>(
    create: (_) => getIt<GameProvider>(),
  ),
  ChangeNotifierProvider<GemsProvider>(
    create: (_) => getIt<GemsProvider>(),
  ),
  ChangeNotifierProvider<HeartsProvider>(
    create: (_) => getIt<HeartsProvider>(),
  ),
  ChangeNotifierProvider<LeagueProvider>(
    create: (_) => getIt<LeagueProvider>(),
  ),
  ChangeNotifierProvider<AchievementsProvider>(
    create: (_) => getIt<AchievementsProvider>(),
  ),
  ChangeNotifierProvider<MatchProvider>(
    create: (_) => getIt<MatchProvider>(),
  ),
  ChangeNotifierProvider<IdentityProvider>(
    create: (_) => IdentityProvider(),
  ),
  ChangeNotifierProvider<CommunityProvider>(
    create: (_) => CommunityProvider(),
  ),
  ChangeNotifierProvider<ActivityProvider>(
    create: (_) => ActivityProvider(),
  ),
];
