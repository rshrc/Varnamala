// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:words625/core/identity.dart';

void main() {
  group('handleFromName', () {
    test('shortens a full name the way a nickname would', () {
      expect(handleFromName('Rishi Banerjee'), 'Riban');
      expect(handleFromName('Asha Menon'), 'Asmen');
      expect(handleFromName('priya  krishnan'), 'Prkri');
    });

    test('handles one-word and messy names', () {
      expect(handleFromName('Madonna'), 'Madonn');
      expect(handleFromName('rishi.banerjee'), 'Riban');
      expect(handleFromName('A B'), 'Ab');
    });

    test('never leaks an email or leaves someone nameless', () {
      expect(handleFromName(null), 'Learner');
      expect(handleFromName(''), 'Learner');
      expect(handleFromName('   '), 'Learner');
      expect(handleFromName('rishi@gmail.com'), isNot(contains('@')));
    });
  });

  group('validateHandle', () {
    test('accepts a reasonable handle', () {
      expect(validateHandle('Riban'), isNull);
    });

    test('rejects impersonation and email-shaped input', () {
      expect(validateHandle('ad'), isNotNull);
      expect(validateHandle('a' * 17), isNotNull);
      expect(validateHandle('two words'), isNotNull);
      expect(validateHandle('me@you.com'), isNotNull);
      expect(validateHandle('varnamala'), isNotNull);
      expect(validateHandle('ADMIN'), isNotNull);
    });
  });

  group('generated handles', () {
    test('nameless accounts get distinct, stable names, not all "Learner"', () {
      final names = [
        for (var i = 0; i < 40; i++) generatedHandle('user-id-$i'),
      ];
      expect(names.toSet().length, greaterThan(30),
          reason: 'generated handles should rarely collide');
      expect(names, everyElement(isNot('Learner')));
      expect(generatedHandle('user-id-1'), generatedHandle('user-id-1'));
    });

    test('falls back to a generated name when there is no display name', () {
      expect(handleFromName(null, seed: 'abc'), isNot('Learner'));
      expect(handleFromName('', seed: 'abc'), handleFromName(null, seed: 'abc'));
    });

    test('displayHandle fills in for accounts with nothing stored', () {
      expect(displayHandle(storedHandle: 'Riban', userId: 'u1'), 'Riban');
      expect(displayHandle(storedHandle: null, userId: 'u1'),
          generatedHandle('u1'));
      // Legacy rows literally containing "Learner" should not stay that way.
      expect(displayHandle(storedHandle: 'Learner', userId: 'u1'),
          generatedHandle('u1'));
      expect(displayHandle(storedHandle: null, userId: 'u1'),
          isNot(displayHandle(storedHandle: null, userId: 'u2')));
    });
  });

  test('identicon seeds are stable and differ per user', () {
    expect(identiconSeed('abc'), identiconSeed('abc'));
    expect(identiconSeed('abc'), isNot(identiconSeed('abd')));
  });
}
