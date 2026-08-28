import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/core/logger.dart';
import 'package:words625/service/locator.dart';

class LanguagePreferenceService {
  LanguagePreferenceService(
    this.appPrefs, {
    FirebaseFirestore? firestore,
  }) : _firestoreOverride = firestore;

  final AppPrefs appPrefs;
  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  TargetLanguage? readLocalSelection() {
    final keys = appPrefs.preferences.getKeys().getValue();
    final explicitlyCompleted = appPrefs.languageSelectionComplete.getValue();
    final hasLegacySelection = keys.contains(PrefsConstants.currentLanguage);
    if (!explicitlyCompleted && !hasLegacySelection) return null;
    return parseLanguage(appPrefs.currentLanguage.getValue());
  }

  Future<TargetLanguage?> restoreForUser(String userId) async {
    final localSelection = readLocalSelection();
    if (localSelection != null) {
      if (!appPrefs.languageSelectionComplete.getValue()) {
        await appPrefs.setBool(
          PrefsConstants.languageSelectionComplete,
          value: true,
        );
      }
      return localSelection;
    }

    try {
      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .get()
          .timeout(const Duration(seconds: 3));
      final data = snapshot.data();
      final preferred = parseLanguage(data?['preferredLanguage']);
      if (preferred != null) {
        await saveLocally(preferred);
        return preferred;
      }

      // Older accounts only stored a set of languages. A single entry is
      // unambiguous; with several entries we ask rather than guessing.
      final legacyLanguages = data?['languages'];
      if (legacyLanguages is List && legacyLanguages.length == 1) {
        final onlyLanguage = parseLanguage(legacyLanguages.first);
        if (onlyLanguage != null) {
          await saveLocally(onlyLanguage);
          return onlyLanguage;
        }
      }
    } catch (error, stackTrace) {
      logger.w(
        'Could not restore the preferred language',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return null;
  }

  Future<void> saveSelection({
    required TargetLanguage language,
    required String? userId,
  }) async {
    await saveLocally(language);
    if (userId != null) {
      unawaited(_syncToAccount(userId, language));
    }
  }

  Future<void> saveLocally(TargetLanguage language) async {
    await appPrefs.setString(
      PrefsConstants.currentLanguage,
      language.name,
    );
    await appPrefs.setBool(
      PrefsConstants.languageSelectionComplete,
      value: true,
    );
  }

  Future<void> _syncToAccount(
    String userId,
    TargetLanguage language,
  ) async {
    try {
      await firestore.collection('users').doc(userId).set(
        {
          'preferredLanguage': language.name,
          'languages': FieldValue.arrayUnion([language.name]),
        },
        SetOptions(merge: true),
      );
    } catch (error, stackTrace) {
      logger.w(
        'Could not sync the preferred language',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}

TargetLanguage? parseLanguage(Object? value) {
  if (value is! String) return null;
  for (final language in TargetLanguage.values) {
    if (language.name == value) return language;
  }
  return null;
}
