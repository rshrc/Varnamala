import 'package:flutter_test/flutter_test.dart';
import 'package:words625/courses/word_dictionary.dart';

void main() {
  group('glosses that teach nothing', () {
    test('an English loanword glossed as itself is rejected', () {
      // The reported bug: a Kannada lesson asked the learner to type "filter"
      // in "Idu filter kaapi, adu chaha."
      expect(glossTeachesNothing('filter', 'filter (coffee)'), isTrue);
      expect(glossTeachesNothing('bus', 'bus'), isTrue);
      expect(glossTeachesNothing('hotel', 'Hotel'), isTrue);
      expect(glossTeachesNothing('school', 'school '), isTrue);
      // Punctuation and case must not smuggle one through.
      expect(glossTeachesNothing('Filter,', 'FILTER'), isTrue);
    });

    test('a real translation is kept', () {
      expect(glossTeachesNothing('kaapi', 'coffee'), isFalse);
      expect(glossTeachesNothing('chaha', 'tea'), isFalse);
      expect(glossTeachesNothing('idu', 'this'), isFalse);
      expect(glossTeachesNothing('nanna', 'my'), isFalse);
    });

    test('a gloss offering choices is judged on each of them', () {
      // "tea/chai" still teaches "chaha", but "chai/tea" does not teach "chai".
      expect(glossTeachesNothing('chaha', 'tea/chai'), isFalse);
      expect(glossTeachesNothing('chai', 'tea/chai'), isTrue);
      expect(glossTeachesNothing('auto', 'auto, rickshaw'), isTrue);
    });

    test('a qualifier does not disguise a passthrough', () {
      expect(glossTeachesNothing('filter', 'filter (the coffee kind)'), isTrue);
      expect(glossTeachesNothing('kaapi', 'coffee (filter)'), isFalse);
    });

    test('an empty word is never a usable question', () {
      expect(glossTeachesNothing('', 'anything'), isTrue);
      expect(glossTeachesNothing('...', 'anything'), isTrue);
    });
  });
}
