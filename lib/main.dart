// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Project imports:
import 'package:words625/di/injection.dart';
import 'package:words625/firebase_options.dart';
import 'package:words625/service/locator.dart';
import 'package:words625/views/app.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();

  // These startup tasks do not depend on one another. Running them together
  // avoids making web users wait for three sequential browser/network round
  // trips before Flutter can draw its first frame.
  await Future.wait<void>([
    setupLocator(),
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).then<void>((_) {}),
    GoogleSignIn.instance.initialize(),
  ]);

  if (!kIsWeb) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  runApp(const Words625App());
}
