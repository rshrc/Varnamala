// Dart imports:
import 'dart:math' as math;

// Project imports:
import 'package:words625/core/text_normalization.dart';

/// How a typed answer compared to what the exercise asked for.
enum TypedAnswerVerdict {
  /// Written exactly as authored, or in an equally valid romanization.
  exact,

  /// Close enough to be a slip of the finger rather than a different word.
  nearMiss,

  /// Not this word.
  wrong,
}

/// Judges a typed answer against every authored alternative.
///
/// Romanized Indian languages have no single correct spelling. *dhanyavaad*,
/// *danyavad* and *dhanyavad* are one word written by three people, and failing
/// a learner for picking a different one tests typing rather than language.
///
/// Two layers, in order:
///
/// 1. [romanizationKey] folds the spellings that stand for the same sound. Two
///    answers with the same key are the same answer, and the learner is told
///    nothing — they did not misspell anything.
/// 2. Anything left over is measured. A near miss has to be *both* within a
///    length-scaled edit budget and above [_minimumCosine] on character
///    bigrams; a single measure lets through either anagrams or long words
///    that share a prefix.
///
/// [dictionary] is the safety gate and matters more than the thresholds: a
/// typed word that the language actually teaches, with a meaning of its own, is
/// never accepted as a misspelling of a different word. *mane* (house) must not
/// swallow *mana* (mind), and *illa* (no) must not swallow *ella* (all).
TypedAnswerVerdict judgeTypedAnswer({
  required String typed,
  required Iterable<String> accepted,
  Map<String, String> dictionary = const {},
}) {
  final typedKey = romanizationKey(typed);
  if (typedKey.isEmpty) return TypedAnswerVerdict.wrong;

  var nearMiss = false;
  for (final answer in accepted) {
    final answerKey = romanizationKey(answer);
    if (answerKey.isEmpty) continue;
    if (typedKey == answerKey) return TypedAnswerVerdict.exact;
    if (_isNearMiss(typedKey, answerKey) &&
        !_namesADifferentWord(
          typed: typed,
          answer: answer,
          dictionary: dictionary,
        )) {
      nearMiss = true;
    }
  }

  return nearMiss ? TypedAnswerVerdict.nearMiss : TypedAnswerVerdict.wrong;
}

/// Folds a romanized word onto the spelling-independent sound it stands for.
///
/// Deterministic and total: every input produces a key, and equal keys mean the
/// two spellings are equally defensible ways to write the same word.
String romanizationKey(String value) {
  final letters = value.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
  final folded = StringBuffer();

  var index = 0;
  while (index < letters.length) {
    // Longest fold first, so `chh` is not eaten by `ch` and `aw` not by `w`.
    final longest = math.min(_longestFold, letters.length - index);
    var span = longest;
    for (; span >= 1; span--) {
      final fold = _romanizationFolds[letters.substring(index, index + span)];
      if (fold == null) continue;
      folded.write(fold);
      break;
    }
    if (span >= 1) {
      index += span;
      continue;
    }
    folded.write(letters[index]);
    index += 1;
  }

  return _collapseRuns(folded.toString());
}

/// Cosine similarity of two words' padded character bigrams, 0.0 to 1.0.
///
/// Padding the ends means a word's first and last letters carry weight, so
/// `hesaru` and `esaru` are further apart than their shared middle suggests.
double bigramCosine(String a, String b) {
  if (a == b) return a.isEmpty ? 0 : 1;
  if (a.isEmpty || b.isEmpty) return 0;

  final left = _bigramCounts(a);
  final right = _bigramCounts(b);

  var dot = 0;
  for (final entry in left.entries) {
    dot += entry.value * (right[entry.key] ?? 0);
  }
  if (dot == 0) return 0;

  final leftNorm = math.sqrt(
    left.values.fold<int>(0, (sum, count) => sum + count * count),
  );
  final rightNorm = math.sqrt(
    right.values.fold<int>(0, (sum, count) => sum + count * count),
  );
  return dot / (leftNorm * rightNorm);
}

/// Number of single-character insertions, deletions, or substitutions between
/// two strings.
int levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  var previous = List<int>.generate(b.length + 1, (index) => index);
  var current = List<int>.filled(b.length + 1, 0);

  for (var i = 1; i <= a.length; i++) {
    current[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final substitution = previous[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1);
      current[j] = math.min(
        substitution,
        math.min(previous[j] + 1, current[j - 1] + 1),
      );
    }
    final swap = previous;
    previous = current;
    current = swap;
  }

  return previous[b.length];
}

/// The similarity a near miss has to clear.
///
/// Tuned against real minimal pairs rather than picked round: *avanu* and
/// *avalu* score 0.67 and *mane* and *mana* score 0.60, while a one-finger slip
/// in a six-letter word sits above 0.77.
const double _minimumCosine = 0.75;

/// How many edits a word of this length may absorb and still be the same word.
///
/// Short words get none. In a four-letter word a single substitution is usually
/// a different word, not a typo, and the dictionary gate cannot catch the ones
/// the language happens not to teach.
int _maximumEdits(int length) {
  if (length >= 8) return 2;
  if (length >= 5) return 1;
  return 0;
}

bool _isNearMiss(String typedKey, String answerKey) {
  final allowance = _maximumEdits(answerKey.length);
  if (allowance == 0) return false;
  if ((typedKey.length - answerKey.length).abs() > allowance) return false;
  if (levenshtein(typedKey, answerKey) > allowance) return false;
  return bigramCosine(typedKey, answerKey) >= _minimumCosine;
}

/// Whether the learner typed a real word of this language that means something
/// else, rather than a misspelling of the answer.
bool _namesADifferentWord({
  required String typed,
  required String answer,
  required Map<String, String> dictionary,
}) {
  final typedGloss = dictionary[normalizeWord(typed)];
  // Not a word the course teaches, so nothing to confuse it with.
  if (typedGloss == null) return false;

  final answerGloss = dictionary[normalizeWord(answer)];
  // The learner typed something the course teaches and the answer is not in the
  // dictionary at all, so they are certainly two different words.
  if (answerGloss == null) return true;

  return typedGloss != answerGloss;
}

/// Spellings that stand for one sound, mapped onto a single representative.
///
/// The direction of each pair is arbitrary; only agreement matters, because
/// both the answer and the response go through the same table.
const Map<String, String> _romanizationFolds = {
  // Aspirates. A learner hears one consonant and writes it with or without
  // the h that marks the breath.
  'chh': 'c',
  'ksh': 'ks',
  'ph': 'f',
  'bh': 'b',
  'dh': 'd',
  'th': 't',
  'kh': 'k',
  'gh': 'g',
  'jh': 'j',
  'ch': 'c',
  'sh': 's',
  // Tamil's retroflex l has no settled spelling: zh, l and lh all appear for
  // the same letter, as in Tamizh and Tamil.
  'zh': 'l',
  // Diphthongs, written either as a glide or as the vowel they land on.
  'ai': 'e',
  'ay': 'e',
  'au': 'o',
  'aw': 'o',
  // One consonant, two letters, no consistency anywhere: vanakkam, wanakkam.
  'w': 'v',
  'q': 'k',
  'x': 'ks',
  'jn': 'gn',
};

const int _longestFold = 3;

/// Collapses runs of one letter, which is how vowel length and doubled
/// consonants are written: neeru and neru, chennagiddene and chenagidene.
String _collapseRuns(String value) {
  final buffer = StringBuffer();
  for (var index = 0; index < value.length; index++) {
    if (index > 0 && value[index] == value[index - 1]) continue;
    buffer.write(value[index]);
  }
  return buffer.toString();
}

Map<String, int> _bigramCounts(String value) {
  final padded = '^$value\$';
  final counts = <String, int>{};
  for (var index = 0; index < padded.length - 1; index++) {
    final bigram = padded.substring(index, index + 2);
    counts[bigram] = (counts[bigram] ?? 0) + 1;
  }
  return counts;
}
