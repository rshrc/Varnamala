// Flutter imports:

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';

// Project imports:
import 'package:words625/service/speech_service.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

// Project imports:
import 'package:words625/core/logger.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/domain/auth/firebase_user.dart';
import 'package:words625/routing/routing.dart';

class AppPrefs {
  final StreamingSharedPreferences preferences;

  AppPrefs(
    this.preferences,
  )   : fcmToken = preferences.getString(
          PrefsConstants.fcmToken,
          defaultValue: "",
        ),
        currentLanguage = preferences.getString(
          PrefsConstants.currentLanguage,
          defaultValue: "kannada",
        ),
        languageSelectionComplete = preferences.getBool(
          PrefsConstants.languageSelectionComplete,
          defaultValue: false,
        ),
        authUser = preferences.getCustomValue(
          PrefsConstants.authUser,
          defaultValue: null,
          adapter: JsonAdapter(
            deserializer: (val) => SerializableFirebaseUser.fromJson(
              val as Map<String, dynamic>,
            ),
          ),
        );

  final Preference<String> fcmToken;
  final Preference<SerializableFirebaseUser?> authUser;
  final Preference<String> currentLanguage;
  final Preference<bool> languageSelectionComplete;

  Future<bool> setBool(String key, {required bool value}) async {
    printBefore(value: value, key: key);
    return preferences.setBool(key, value);
  }

  Future<bool> setDouble(String key, double value) async {
    printBefore(value: value, key: key);
    return preferences.setDouble(key, value);
  }

  Future<bool> setInt(String key, int value) async {
    printBefore(value: value, key: key);
    return preferences.setInt(key, value);
  }

  Future<bool> setString(String key, String value) async {
    printBefore(value: value, key: key);
    return preferences.setString(key, value);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    printBefore(value: value, key: key);
    return preferences.setStringList(key, value);
  }

  Future<bool> setCustomValue(
      String key, value, PreferenceAdapter<dynamic> adapter) async {
    printBefore(value: value, key: key);
    return preferences.setCustomValue(key, value, adapter: adapter);
  }

  Future<bool> setFirebaseUser(User user) async {
    final serializableUser = SerializableFirebaseUser.fromFirebaseUser(user);
    return preferences.setCustomValue(
      PrefsConstants.authUser,
      serializableUser.toJson(),
      adapter: const JsonAdapter(),
    );
  }

  void printBefore({String? key, value}) =>
      logger.w('Saving Key: $key &  value: $value');
}

class PrefsConstants {
  static const String authToken = "authToken";
  static const String fcmToken = "fcmToken";
  static const String userId = 'userId';
  static const String authUser = 'authUser';
  static const String branch = 'branch';
  static const String currentLanguage = 'currentLanguage';
  static const String languageSelectionComplete = 'languageSelectionComplete';
  static const String themeMode = 'themeMode';
  static const String demoCount = 'demoCount';
  static const String unlockAllLevels = 'unlockAllLevels';
  static const String flashcardProgressPrefix = 'flashcardProgress_';
}

/// Making AppPrefs injectable
Future<void> setupLocator() async {
  final preferences = await StreamingSharedPreferences.instance;
  getIt.registerLazySingleton<AppRouter>(() => AppRouter());
  getIt.registerLazySingleton<AppPrefs>(() => AppPrefs(preferences));

  // Registered on web too: flutter_tts supports it, and SpeechService handles
  // the browser-specific setup that the plugin leaves to the caller.
  getIt.registerLazySingleton<FlutterTts>(FlutterTts.new);
  getIt.registerLazySingleton<SpeechService>(
      () => SpeechService(getIt<FlutterTts>()));
}
