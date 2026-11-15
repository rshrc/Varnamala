import 'package:flutter/painting.dart';
import 'package:words625/domain/katha.dart';

/// What a word means and how it is built, for its tooltip:
///
///     uurige  to (this) town
///     uur · ige (to)
///     from: uuru
///
/// The grammar codes are shared by every language, so "ige (to)" in Kannada
/// and "ko (to)" in Hindi read the same way.
TextSpan kathaGloss(KathaToken token, KathaSpelling spelling) {
  final word = spelling.show(token.roman);
  final lemma = spelling.show(token.lemma);
  final parts = token.morphemes;
  final function = token.function;
  return TextSpan(
    style: const TextStyle(height: 1.4),
    children: [
      TextSpan(
        text: word,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      TextSpan(text: '  ${token.gloss}'),
      if (parts.length > 1)
        TextSpan(
          text: '\n${parts.map((part) => _part(part, spelling)).join(' · ')}',
        )
      else if (function != null)
        TextSpan(text: '\n(${kathaFunctionName(function)})'),
      if (!token.isName && lemma != word)
        TextSpan(text: '\nfrom: $lemma', style: _aside),
      if (token.isLoan)
        const TextSpan(text: '\nborrowed from English', style: _aside),
    ],
  );
}

/// A part of a word, with what its grammar does: `ige (to)`.
String _part(KathaMorpheme part, KathaSpelling spelling) {
  final roman = spelling.show(part.roman);
  final function = part.function;
  return function == null ? roman : '$roman (${kathaFunctionName(function)})';
}

const _aside = TextStyle(fontStyle: FontStyle.italic);

/// A grammar function code (`DIR`, `PRES.1SG`) in plain words.
String kathaFunctionName(String code) {
  if (code.startsWith('PRES')) return 'now / habit';
  return switch (code) {
    'DIR' => 'to',
    'LOC' => 'in, at',
    'GEN' => "of, 's",
    'ACC' => 'the one acted on',
    'INS' => 'with, by',
    'ABL' => 'from',
    'PL' => 'more than one',
    'PAST' => 'past',
    'PERF' => 'has done',
    'PROG' => '-ing',
    'FUT' => 'will',
    'NEG' => 'not',
    'Q' => 'question',
    'IMP' => 'do it!',
    'IMP.HON' => 'please do',
    'HON' => 'polite',
    _ => code.toLowerCase(),
  };
}
