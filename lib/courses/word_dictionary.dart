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

/// Whether a dictionary entry teaches the learner nothing, because the "gloss"
/// is just the word again.
///
/// Indian languages carry a lot of English: *filter kaapi*, *bus*, *hotel*,
/// *school*. Keeping those in the dictionary is right — a learner reading a
/// sentence may still want the tap-a-word hint. Building an **exercise** out of
/// them is not: asking someone learning Kannada to type "filter", or to match
/// "bus" with "bus", tests nothing about Kannada and reads as a bug.
///
/// So the entry stays for hints, and this predicate keeps it out of generated
/// questions.
bool glossTeachesNothing(String word, String gloss) {
  final subject = normalizeWord(word);
  if (subject.isEmpty) return true;

  for (final alternative in _glossAlternatives(gloss)) {
    if (alternative == subject) return true;
  }
  return false;
}

/// The distinct meanings inside one gloss.
///
/// A gloss may qualify itself ("filter (coffee)"), or offer choices
/// ("tea/chai", "yes, indeed"). Each is compared on its own, so "filter
/// (coffee)" is recognised as the word "filter" wearing a hat.
Iterable<String> _glossAlternatives(String gloss) sync* {
  final withoutQualifiers = gloss.replaceAll(RegExp(r'\([^)]*\)'), ' ');
  for (final part in withoutQualifiers.split(RegExp(r'[,/;]'))) {
    final normalized = normalizeWord(part.trim());
    if (normalized.isNotEmpty) yield normalized;
  }
}
