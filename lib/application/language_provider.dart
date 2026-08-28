// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:words625/core/enums.dart';
import 'package:words625/service/language_preference_service.dart';
import 'package:words625/service/locator.dart';

@injectable
class LanguageProvider extends ChangeNotifier {
  final AppPrefs appPrefs;
  late final LanguagePreferenceService _preferenceService =
      LanguagePreferenceService(appPrefs);

  FirebaseAuth get _auth => FirebaseAuth.instance;

  TargetLanguage selectedLanguage = TargetLanguage.kannada;
  bool _selectionMadeThisSession = false;

  LanguageProvider(this.appPrefs);

  bool get canConfirmSelection =>
      _selectionMadeThisSession ||
      _preferenceService.readLocalSelection() != null;

  void initLanguage() {
    selectedLanguage =
        _preferenceService.readLocalSelection() ?? TargetLanguage.kannada;

    notifyListeners();
  }

  void setLanguage(TargetLanguage language) {
    selectedLanguage = language;
    _selectionMadeThisSession = true;

    notifyListeners();
  }

  Future<void> cacheLanguage() async {
    await _preferenceService.saveSelection(
      language: selectedLanguage,
      userId: _auth.currentUser?.uid,
    );
    _selectionMadeThisSession = false;
    notifyListeners();
  }
}
