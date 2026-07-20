// Project imports:
import 'package:words625/core/extensions.dart';
import 'package:words625/courses/course_repository.dart';
import 'package:words625/courses/courses.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/service/locator.dart';

/// English gloss for a word as it appears inside a lesson sentence, or `null`
/// when the language's dictionary has no entry for it.
///
/// Synchronous by design: lesson text builds a tappable span per word, and the
/// dictionary is already warm because [CourseRepository] loads it with the
/// course it belongs to.
String? getWordMeaning(String word) {
  final language = getIt<AppPrefs>().currentLanguage.getValue().getEnumValue();
  return courseRepository.cachedDictionary(language)?[normalizeWord(word)];
}
