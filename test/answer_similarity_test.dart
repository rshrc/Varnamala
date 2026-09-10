// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:words625/core/answer_similarity.dart';

/// A slice of a real dictionary, holding the minimal pairs that a forgiving
/// matcher is most likely to confuse.
const Map<String, String> _dictionary = {
  'mane': 'house',
  'mana': 'mind',
  'naanu': 'I',
  'neenu': 'you',
  'illa': 'no, there is not',
  'ella': 'all',
  'avanu': 'he',
  'avalu': 'she',
  'hesaru': 'name',
  'neeru': 'water',
  'haalu': 'milk',
  'chennagiddene': 'I am well',
  'dhanyavaadagalu': 'thank you',
};

TypedAnswerVerdict judge(String typed, String answer) => judgeTypedAnswer(
      typed: typed,
      accepted: [answer],
      dictionary: _dictionary,
    );

void main() {
  group('romanizationKey', () {
    test('folds aspirates, doubled letters and vowel length together', () {
      // One word, three defensible spellings.
      expect(romanizationKey('dhanyavaad'), romanizationKey('danyavad'));
      expect(romanizationKey('dhanyavaad'), romanizationKey('dhanyavad'));

      // Vowel length is not information a learner can hear.
      expect(romanizationKey('neeru'), romanizationKey('neru'));

      // Doubled consonants likewise.
      expect(romanizationKey('chennagiddene'), romanizationKey('chenagidene'));
      expect(romanizationKey('vanakkam'), romanizationKey('vanakam'));

      // v and w are one consonant everywhere in these languages.
      expect(romanizationKey('vanakkam'), romanizationKey('wanakkam'));

      // Tamil's retroflex l.
      expect(romanizationKey('tamizh'), romanizationKey('tamil'));
    });

    test('keeps genuinely different words apart', () {
      expect(romanizationKey('mane'), isNot(romanizationKey('mana')));
      expect(romanizationKey('naanu'), isNot(romanizationKey('neenu')));
      expect(romanizationKey('avanu'), isNot(romanizationKey('avalu')));
      expect(romanizationKey('illa'), isNot(romanizationKey('ella')));
    });

    test('is stable under case and surrounding punctuation', () {
      expect(romanizationKey('  Hesaru? '), romanizationKey('hesaru'));
    });
  });

  group('judgeTypedAnswer accepts an equivalent spelling silently', () {
    const equivalents = <List<String>>[
      ['danyavad', 'dhanyavaad'],
      ['neru', 'neeru'],
      ['chenagidene', 'chennagiddene'],
      ['wanakkam', 'vanakkam'],
      ['halu', 'haalu'],
      // Doubling the wrong consonant is still the same spelling once runs
      // collapse, so it costs the learner nothing.
      ['chennagidenne', 'chennagiddene'],
    ];

    for (final pair in equivalents) {
      test('${pair.first} is ${pair.last}', () {
        expect(judge(pair.first, pair.last), TypedAnswerVerdict.exact);
      });
    }
  });

  group('judgeTypedAnswer forgives a typo but says so', () {
    const typos = <List<String>>[
      ['hesru', 'hesaru'],
      ['chennagiddane', 'chennagiddene'],
      ['dhanyavadagulu', 'dhanyavaadagalu'],
    ];

    for (final pair in typos) {
      test('${pair.first} is a slip for ${pair.last}', () {
        expect(judge(pair.first, pair.last), TypedAnswerVerdict.nearMiss);
      });
    }
  });

  group('judgeTypedAnswer refuses a different word', () {
    // The column that matters. Over-accepting is worse than being strict:
    // telling a learner that "she" is an acceptable way to write "he" teaches
    // them something false.
    const distinct = <List<String>>[
      ['mana', 'mane'],
      ['mane', 'mana'],
      ['neenu', 'naanu'],
      ['naanu', 'neenu'],
      ['ella', 'illa'],
      ['illa', 'ella'],
      ['avalu', 'avanu'],
      ['avanu', 'avalu'],
    ];

    for (final pair in distinct) {
      test('${pair.first} is not ${pair.last}', () {
        expect(judge(pair.first, pair.last), TypedAnswerVerdict.wrong);
      });
    }

    test('an unrelated word is wrong', () {
      expect(judge('haalu', 'hesaru'), TypedAnswerVerdict.wrong);
      expect(judge('', 'hesaru'), TypedAnswerVerdict.wrong);
    });
  });

  test('any of several authored alternatives may be matched', () {
    expect(
      judgeTypedAnswer(
        typed: 'neru',
        accepted: const ['haalu', 'neeru'],
        dictionary: _dictionary,
      ),
      TypedAnswerVerdict.exact,
    );
  });

  test('without a dictionary a near miss is still forgiven', () {
    // Course content is not obliged to gloss every accepted answer, and a
    // missing gloss must not make the matcher stricter than it is with one.
    expect(
      judgeTypedAnswer(typed: 'hesru', accepted: const ['hesaru']),
      TypedAnswerVerdict.nearMiss,
    );
  });

  group('measures', () {
    test('bigramCosine separates minimal pairs from slips', () {
      expect(bigramCosine('mane', 'mana'), lessThan(0.75));
      expect(bigramCosine('avanu', 'avalu'), lessThan(0.75));
      expect(bigramCosine('hesaru', 'hesru'), greaterThanOrEqualTo(0.75));
      expect(bigramCosine('mane', 'mane'), 1);
    });

    test('levenshtein counts single-character edits', () {
      expect(levenshtein('mane', 'mane'), 0);
      expect(levenshtein('mane', 'mana'), 1);
      expect(levenshtein('hesaru', 'hesru'), 1);
      expect(levenshtein('', 'mane'), 4);
    });
  });
}
