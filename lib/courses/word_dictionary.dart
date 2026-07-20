// Project imports:
import 'package:words625/courses/course_repository.dart';
import 'package:words625/courses/courses.dart';

/// English gloss for a word as it appears inside a lesson sentence, or `null`
/// when the language's dictionary has no entry for it.
///
/// Synchronous by design: lesson text builds a tappable span per word, and the
/// dictionary is already warm because [CourseRepository] loads it alongside the
/// course the learner opened.
String? getWordMeaning(String word) =>
    courseRepository.activeDictionary?[normalizeWord(word)];
