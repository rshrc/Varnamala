// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:words625/core/enums.dart';
import 'package:words625/service/locator.dart';

@injectable
class LanguageProvider extends ChangeNotifier {
  final AppPrefs appPrefs;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TargetLanguage selectedLanguage = TargetLanguage.kannada;

  LanguageProvider(this.appPrefs);

  initLanguage() {
    selectedLanguage = TargetLanguage.values.firstWhere(
      (element) => element.name == appPrefs.currentLanguage.getValue(),
      orElse: () => TargetLanguage.kannada,
    );

    notifyListeners();
  }

  void setLanguage(TargetLanguage language) {
    selectedLanguage = language;

    notifyListeners();
  }

  void cacheLanguage() async {
    // Persist locally first: the app bar and the match game read this
    // preference, and they must follow the learner's choice even when there is
    // no signed-in user to sync it to.
    appPrefs.setString(PrefsConstants.currentLanguage, selectedLanguage.name);
    notifyListeners();

    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final userDocRef = firestore.collection('users').doc(userId);

    await userDocRef.update({
      'languages': FieldValue.arrayUnion([selectedLanguage.name])
    });

    notifyListeners();
  }
}
