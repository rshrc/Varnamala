// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:words625/core/enums.dart';
import 'package:words625/core/logger.dart';
import 'package:words625/courses/courses.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/domain/course/course.dart';
import 'package:words625/service/locator.dart';

@injectable
class CourseProvider extends ChangeNotifier {
  List<List<Course>>? courses;

  /// Set when the chosen language could not be loaded. Without this a failed
  /// load would leave the previous language's courses on screen — picking Urdu
  /// and being shown Kannada.
  TargetLanguage? failedLanguage;

  bool get hasFailed => failedLanguage != null;

  Future<void> getCourses(TargetLanguage language) async {
    logger.w('Getting courses for $language');
    // Clear first: whatever happens next, the old language must not linger.
    courses = null;
    failedLanguage = null;
    notifyListeners();

    try {
      courses = await parseCourses(
        firstName:
            getIt<AppPrefs>().authUser.getValue()!.displayName!.split(" ").first,
        targetLanguage: language,
      );
    } catch (error, stackTrace) {
      logger.e('Could not load $language', error: error, stackTrace: stackTrace);
      failedLanguage = language;
      courses = null;
    }
    notifyListeners();
  }
}
