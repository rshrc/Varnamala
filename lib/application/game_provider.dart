// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:words625/di/injection.dart';
import 'package:words625/service/locator.dart';

enum XPEvent {
  lessonComplete(base: 10),
  perfectLesson(base: 15),
  dailyGoalComplete(base: 20),
  streakBonus(base: 5),
  challengeWin(base: 25);

  final int base;
  const XPEvent({required this.base});
}

enum StreakCheckResult {
  none,
  maintained,
  freezeConsumed,
  broken,
}

@injectable
class GameProvider extends ChangeNotifier {
  static const String bronzeLeague = 'bronze';
  static const int defaultDailyXpGoal = 50;
  static const int defaultStreakRepairTarget = 100;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreakCheckResult _lastStreakCheckResult = StreakCheckResult.none;

  StreakCheckResult get lastStreakCheckResult => _lastStreakCheckResult;

  int _recentXp = 0;

  /// XP awarded since [resetRecentXp], so the screen that follows a lesson can
  /// say what the lesson was worth.
  ///
  /// A lesson awards more than once - completion, then a perfect bonus - so a
  /// single "last award" would under-report it.
  int get recentXp => _recentXp;

  void resetRecentXp() => _recentXp = 0;

  /// Adds to a running counter on the user document.
  ///
  /// These are what the achievement catalogue reads — a badge whose stat is
  /// never written can never be earned, so every counter it names is bumped
  /// from wherever that thing actually happens.
  Future<void> bumpStat(String field, {int by = 1}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || by == 0) return;
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .set({field: FieldValue.increment(by)}, SetOptions(merge: true));
    } catch (error) {
      debugPrint('Could not bump $field: $error');
    }
  }

  /// Records a personal best, leaving it alone if the stored value is higher.
  Future<void> recordBest(String field, int value) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || value <= 0) return;
    final docRef = _firestore.collection('users').doc(userId);
    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final current = (snapshot.data()?[field] as num? ?? 0).toInt();
        if (value > current) {
          transaction.set(docRef, {field: value}, SetOptions(merge: true));
        }
      });
    } catch (error) {
      debugPrint('Could not record best $field: $error');
    }
  }

  Stream<int> getUserStreakStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => _readInt(snapshot.data(), 'streak', 0));
  }

  Stream<int> getUserScoreStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => _readInt(snapshot.data(), 'score', 0));
  }

  Stream<Map<String, dynamic>> getUserGameStateStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(<String, dynamic>{});
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data() ?? <String, dynamic>{});
  }

  Future<Map<String, dynamic>> getUserGameStateOnce() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return <String, dynamic>{};

    final snapshot = await _firestore.collection('users').doc(userId).get();
    return snapshot.data() ?? <String, dynamic>{};
  }

  Future<void> ensureUserGameFields() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final docRef = _firestore.collection('users').doc(userId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data() ?? <String, dynamic>{};
    final now = DateTime.now();
    final score = _readInt(data, 'score', 0);
    final leagueXp = _readInt(data, 'leagueXp', 0);
    final leagueXpMigrated =
        data['leagueXpMigratedFromScore'] as bool? ?? false;
    final leagueXpSeeded = data['leagueXpSeededFromScore'] as bool? ?? false;
    final shouldSeedLeagueXp =
        score > 0 && leagueXp == 0 && (!leagueXpMigrated || !leagueXpSeeded);
    final initialLeagueXp = shouldSeedLeagueXp ? score : leagueXp;

    final defaults = <String, dynamic>{
      'gems': _readInt(data, 'gems', 0),
      'hearts': _readInt(data, 'hearts', 5),
      'heartsRefillAt': data['heartsRefillAt'],
      'streakFreezes': _readInt(data, 'streakFreezes', 0),
      'streakFreezeActive': data['streakFreezeActive'] as bool? ?? false,
      'league': data['league'] as String? ?? bronzeLeague,
      'leagueXp': initialLeagueXp,
      'leagueXpMigratedFromScore': true,
      'leagueXpSeededFromScore': shouldSeedLeagueXp || leagueXpSeeded,
      ...languageLeagueMigration(
        data,
        initialLeagueXp: initialLeagueXp,
        localLanguage: _localLanguage(),
      ),
      'leagueJoinedAt': data['leagueJoinedAt'] ?? FieldValue.serverTimestamp(),
      'achievements': (data['achievements'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          <String>[],
      'dailyXpGoal': _readInt(data, 'dailyXpGoal', defaultDailyXpGoal),
      'dailyXpEarned': _readInt(data, 'dailyXpEarned', 0),
      'lastDailyReset': data['lastDailyReset'] ??
          DateTime(now.year, now.month, now.day).toIso8601String(),
      'lessonsCompleted': _readInt(data, 'lessonsCompleted', 0),
      'perfectLessons': _readInt(data, 'perfectLessons', 0),
      'streakWasBroken': data['streakWasBroken'] as bool? ?? false,
      'streakRepairRequired': data['streakRepairRequired'] as bool? ?? false,
      'streakRepairProgress': _readInt(data, 'streakRepairProgress', 0),
      'streakRepairTarget':
          _readInt(data, 'streakRepairTarget', defaultStreakRepairTarget),
      'streakBeforeBreak': _readInt(data, 'streakBeforeBreak', 0),
      'doubleXpUntil': data['doubleXpUntil'],
      'followRewardClaimed': data['followRewardClaimed'] as bool? ?? false,
      'validatedShareCount': _readInt(data, 'validatedShareCount', 0),
      'claimedShareCount': _readInt(data, 'claimedShareCount', 0),
    };

    await docRef.set(defaults, SetOptions(merge: true));
  }

  /// The language selected on this device, if any.
  String? _localLanguage() {
    try {
      final value = getIt<AppPrefs>()
          .preferences
          .getString(
            PrefsConstants.currentLanguage,
            defaultValue: '',
          )
          .getValue();
      return value.isEmpty ? null : value;
    } catch (_) {
      // Preferences are not registered in every test harness.
      return null;
    }
  }

  /// The per-language XP bump for a write of [xp], or null when the language
  /// cannot be determined and only the account-wide total can be updated.
  ///
  /// Uses a dotted field path so it adds one key to the map rather than
  /// replacing the learner's other languages.
  static Map<String, dynamic>? _languageLeagueXpUpdate(
    Map<String, dynamic> data,
    int xp,
    String? language,
  ) {
    final target = language?.isNotEmpty ?? false
        ? language
        : data['preferredLanguage'] as String?;
    if (target == null || target.isEmpty) return null;

    final current = _readInt(
      (data['leagueXpByLanguage'] as Map<String, dynamic>?) ?? const {},
      target,
      0,
    );
    return {
      'leagueXpByLanguage.$target': current + xp,
      // A language the learner earns XP in is a language they are learning,
      // whatever the array says.
      'languages': FieldValue.arrayUnion([target]),
    };
  }

  /// The fields that move an account from one account-wide league standing to
  /// one standing per language.
  ///
  /// Runs once, on the first launch after the split, and is deliberately
  /// conservative about what it claims:
  ///
  /// - **Tier carries to every language the learner already has.** They earned
  ///   it once; showing them a demotion to Bronze the moment they switch
  ///   language would be a loss they did not incur.
  /// - **XP carries to exactly one language** - the one they were studying.
  ///   It was earned before the app recorded which language it belonged to, so
  ///   crediting it everywhere would put a Hindi learner's XP on the Tamil
  ///   board and outrank people who actually earned it there.
  ///
  /// Also backfills `languages` from `preferredLanguage`. The leaderboard
  /// query filters on `languages`, and an account with an empty array would
  /// vanish from every board.
  ///
  /// Static and pure so the rules can be tested without Firestore.
  static Map<String, dynamic> languageLeagueMigration(
    Map<String, dynamic> data, {
    required int initialLeagueXp,
    String? localLanguage,
  }) {
    final languages = (data['languages'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList();
    final preferred = data['preferredLanguage'] as String?;

    final known = <String>{
      ...languages,
      if (preferred != null && preferred.isNotEmpty) preferred,
      // The device's own choice. Most accounts predate `preferredLanguage`
      // and never wrote `languages` either, so the server has no idea what
      // they are learning - but the phone in their hand does. Without this
      // they match no language-scoped leaderboard and simply vanish from the
      // rankings they used to appear on.
      if (localLanguage != null && localLanguage.isNotEmpty) localLanguage,
    };

    final updates = <String, dynamic>{};
    if (known.length != languages.length) {
      updates['languages'] = known.toList(growable: false);
    }

    if (data['leagueLanguageMigrated'] as bool? ?? false) return updates;

    final tier = data['league'] as String? ?? bronzeLeague;
    final home = preferred?.isNotEmpty ?? false
        ? preferred
        : (known.length == 1 ? known.single : null);

    updates['leagueByLanguage'] = <String, dynamic>{
      for (final language in known) language: tier,
    };
    updates['leagueXpByLanguage'] = <String, dynamic>{
      for (final language in known)
        language: language == home ? initialLeagueXp : 0,
    };
    updates['leagueLanguageMigrated'] = true;
    return updates;
  }

  Future<int> awardXP(
    XPEvent event, {
    double multiplier = 1.0,
    bool notify = true,
    String? language,
  }) async {
    final xp = (event.base * multiplier).round();
    if (xp <= 0) return 0;

    await incrementScore(xp, notify: false, language: language);
    _recentXp += xp;

    if (notify) notifyListeners();
    return xp;
  }

  /// Adds [xp] to the learner's totals.
  ///
  /// [language] is the language the XP was earned in. Callers that know it -
  /// a lesson knows its own course - should pass it; otherwise the learner's
  /// stored `preferredLanguage` is used, which is what they are studying.
  Future<void> incrementScore(
    int xp, {
    bool notify = true,
    String? language,
  }) async {
    if (xp <= 0) return;

    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final userDocRef = _firestore.collection('users').doc(userId);

    try {
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(userDocRef);
        if (!doc.exists) return;

        final data = doc.data() ?? <String, dynamic>{};
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final score = _readInt(data, 'score', 0);
        final streak = _readInt(data, 'streak', 0);
        final leagueXp = _readInt(data, 'leagueXp', 0);

        final streakResolution = _resolveStreakOnPractice(
          oldStreak: streak,
          oldDate: _parseDate(data['lastStreakDate']),
          today: today,
          streakFreezeActive: data['streakFreezeActive'] as bool? ?? false,
          streakFreezes: _readInt(data, 'streakFreezes', 0),
        );

        var newScore = score + xp;
        var newGems = _readInt(data, 'gems', 0);

        final achievements =
            (data['achievements'] as List<dynamic>? ?? const <dynamic>[])
                .whereType<String>()
                .toSet();

        newGems += _unlockXpAchievements(achievements, newScore);
        newGems += _unlockStreakAchievements(
          achievements,
          streakResolution.newStreak,
        );

        final dailyResetDate = _parseDate(data['lastDailyReset']);
        var dailyXpEarned = _readInt(data, 'dailyXpEarned', 0);
        if (dailyResetDate == null || !_isSameDay(dailyResetDate, today)) {
          dailyXpEarned = 0;
        }

        final dailyGoal = _readInt(data, 'dailyXpGoal', defaultDailyXpGoal);
        final previousDailyXp = dailyXpEarned;
        dailyXpEarned += xp;
        final streakRepairRequired =
            data['streakRepairRequired'] as bool? ?? false;
        final streakWasBroken = data['streakWasBroken'] as bool? ?? false;
        final streakRepairTarget =
            _readInt(data, 'streakRepairTarget', defaultStreakRepairTarget);
        final previousRepairProgress =
            _readInt(data, 'streakRepairProgress', 0);

        var streakRepairProgress = previousRepairProgress;
        var repairedThisUpdate = false;
        var repairedStreak = streakResolution.newStreak;

        if (streakRepairRequired && streakWasBroken) {
          streakRepairProgress = previousRepairProgress + xp;
          if (streakRepairProgress >= streakRepairTarget) {
            repairedThisUpdate = true;
            final streakBeforeBreak = _readInt(data, 'streakBeforeBreak', 1);
            repairedStreak = streakBeforeBreak <= 0 ? 1 : streakBeforeBreak;
          }
        }

        var dailyGoalsHit = _readInt(data, 'dailyGoalsHit', 0);
        if (previousDailyXp < dailyGoal && dailyXpEarned >= dailyGoal) {
          newScore += XPEvent.dailyGoalComplete.base;
          // Counted once per day, the moment the goal is crossed.
          dailyGoalsHit += 1;
        }

        final updates = <String, dynamic>{
          'score': newScore,
          'streak':
              repairedThisUpdate ? repairedStreak : streakResolution.newStreak,
          'lastStreakDate': today.toIso8601String(),
          'streakFreezes': streakResolution.remainingFreezes,
          'streakFreezeActive': streakResolution.freezeActive,
          'streakWasBroken':
              repairedThisUpdate ? false : streakResolution.broken,
          'streakRepairRequired': repairedThisUpdate
              ? false
              : (streakRepairRequired && streakWasBroken),
          'streakRepairProgress': repairedThisUpdate ? 0 : streakRepairProgress,
          'streakRepairTarget': streakRepairTarget,
          'leagueXp': leagueXp + xp,
          'dailyXpEarned': dailyXpEarned,
          // Written alongside the account-wide total, not instead of it: the
          // account-wide value stays the fallback for any client that has not
          // been updated yet.
          ...?_languageLeagueXpUpdate(data, xp, language),
          'dailyXpGoal': dailyGoal,
          'dailyGoalsHit': dailyGoalsHit,
          'lastDailyReset': today.toIso8601String(),
          'gems': newGems,
          'achievements': achievements.toList(growable: false),
        };

        if (streakResolution.broken) {
          updates['lastStreakBreakDate'] = FieldValue.serverTimestamp();
        }

        transaction.update(userDocRef, updates);
      });

      if (notify) notifyListeners();
    } catch (e) {
      debugPrint('Error updating score and streak: $e');
    }
  }

  Future<void> recordLessonCompletion({
    required bool wasPerfect,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final docRef = _firestore.collection('users').doc(userId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) return;

      final data = doc.data() ?? <String, dynamic>{};
      final lessonsCompleted = _readInt(data, 'lessonsCompleted', 0) + 1;
      final perfectLessons =
          _readInt(data, 'perfectLessons', 0) + (wasPerfect ? 1 : 0);
      transaction.update(docRef, {
        'lessonsCompleted': lessonsCompleted,
        'perfectLessons': perfectLessons,
      });
    });
  }

  Future<StreakCheckResult> checkStreakOnAppOpen() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _lastStreakCheckResult = StreakCheckResult.none;
      return _lastStreakCheckResult;
    }

    final docRef = _firestore.collection('users').doc(userId);

    try {
      final result = await _firestore.runTransaction<StreakCheckResult>(
        (transaction) async {
          final doc = await transaction.get(docRef);
          if (!doc.exists) return StreakCheckResult.none;

          final data = doc.data() ?? <String, dynamic>{};
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final lastDate = _parseDate(data['lastStreakDate']);

          if (lastDate == null) {
            return StreakCheckResult.none;
          }

          final last = DateTime(lastDate.year, lastDate.month, lastDate.day);
          final gap = today.difference(last).inDays;

          if (gap <= 1) {
            transaction.update(docRef, {'streakWasBroken': false});
            return StreakCheckResult.maintained;
          }

          final streakFreezes = _readInt(data, 'streakFreezes', 0);
          final freezeActive = data['streakFreezeActive'] as bool? ?? false;

          if (gap == 2 && (freezeActive || streakFreezes > 0)) {
            transaction.update(docRef, {
              'streakFreezes': freezeActive ? streakFreezes : streakFreezes - 1,
              'streakFreezeActive': false,
              'lastStreakDate': today.toIso8601String(),
              'streakWasBroken': false,
            });
            return StreakCheckResult.freezeConsumed;
          }

          transaction.update(docRef, {
            'streak': 0,
            'streakWasBroken': true,
            'streakBeforeBreak': _readInt(data, 'streak', 0),
            'streakRepairRequired': true,
            'streakRepairProgress': 0,
            'streakRepairTarget': defaultStreakRepairTarget,
            'lastStreakBreakDate': FieldValue.serverTimestamp(),
          });
          return StreakCheckResult.broken;
        },
      );

      _lastStreakCheckResult = result;
      notifyListeners();
      return result;
    } catch (e) {
      debugPrint('Error checking streak on app open: $e');
      _lastStreakCheckResult = StreakCheckResult.none;
      return _lastStreakCheckResult;
    }
  }

  int _unlockXpAchievements(Set<String> achievements, int score) {
    var gemsReward = 0;
    if (score >= 1000 && achievements.add('xp_1000')) gemsReward += 25;
    if (score >= 10000 && achievements.add('xp_10000')) gemsReward += 100;
    if (score >= 50000 && achievements.add('xp_50000')) gemsReward += 250;
    return gemsReward;
  }

  int _unlockStreakAchievements(Set<String> achievements, int streak) {
    var gemsReward = 0;
    if (streak >= 3 && achievements.add('streak_3')) gemsReward += 15;
    if (streak >= 7 && achievements.add('streak_7')) gemsReward += 50;
    if (streak >= 30 && achievements.add('streak_30')) gemsReward += 200;
    if (streak >= 100 && achievements.add('streak_100')) gemsReward += 500;
    if (streak >= 365 && achievements.add('streak_365')) gemsReward += 1000;
    return gemsReward;
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  static int _readInt(Map<String, dynamic>? data, String key, int fallback) {
    final value = data?[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  _StreakResolution _resolveStreakOnPractice({
    required int oldStreak,
    required DateTime? oldDate,
    required DateTime today,
    required bool streakFreezeActive,
    required int streakFreezes,
  }) {
    if (oldDate == null) {
      return _StreakResolution(
        newStreak: oldStreak == 0 ? 1 : oldStreak,
        remainingFreezes: streakFreezes,
        freezeActive: streakFreezeActive,
        broken: false,
      );
    }

    final last = DateTime(oldDate.year, oldDate.month, oldDate.day);
    final gap = today.difference(last).inDays;

    if (gap <= 0) {
      return _StreakResolution(
        newStreak: oldStreak,
        remainingFreezes: streakFreezes,
        freezeActive: streakFreezeActive,
        broken: false,
      );
    }

    if (gap == 1) {
      return _StreakResolution(
        newStreak: oldStreak + 1,
        remainingFreezes: streakFreezes,
        freezeActive: streakFreezeActive,
        broken: false,
      );
    }

    if (gap == 2 && (streakFreezeActive || streakFreezes > 0)) {
      return _StreakResolution(
        newStreak: oldStreak + 1,
        remainingFreezes:
            streakFreezeActive ? streakFreezes : streakFreezes - 1,
        freezeActive: false,
        broken: false,
      );
    }

    return _StreakResolution(
      newStreak: 1,
      remainingFreezes: streakFreezes,
      freezeActive: streakFreezeActive,
      broken: true,
    );
  }
}

class _StreakResolution {
  final int newStreak;
  final int remainingFreezes;
  final bool freezeActive;
  final bool broken;

  _StreakResolution({
    required this.newStreak,
    required this.remainingFreezes,
    required this.freezeActive,
    required this.broken,
  });
}
