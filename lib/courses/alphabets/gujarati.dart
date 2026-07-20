/// Gujarati script — Devanagari's sibling, written without the connecting
/// shirorekha line across the top.
Map<String, String> gujaratiVowels = {
  'અ': 'a',
  'આ': 'aa',
  'ઇ': 'i',
  'ઈ': 'ee',
  'ઉ': 'u',
  'ઊ': 'oo',
  'ઋ': 'ru',
  'એ': 'e',
  'ઐ': 'ai',
  'ઓ': 'o',
  'ઔ': 'au'
};

Map<String, String> gujaratiConsonants = {
  'ક': 'ka',
  'ખ': 'kha',
  'ગ': 'ga',
  'ઘ': 'gha',
  'ઙ': 'nga',
  'ચ': 'cha',
  'છ': 'chha',
  'જ': 'ja',
  'ઝ': 'jha',
  'ઞ': 'nya',
  'ટ': 'ta',
  'ઠ': 'tha',
  'ડ': 'da',
  'ઢ': 'dha',
  'ણ': 'na',
  'ત': 'ta',
  'થ': 'tha',
  'દ': 'da',
  'ધ': 'dha',
  'ન': 'na',
  'પ': 'pa',
  'ફ': 'pha',
  'બ': 'ba',
  'ભ': 'bha',
  'મ': 'ma',
  'ય': 'ya',
  'ર': 'ra',
  'લ': 'la',
  'વ': 'va',
  'શ': 'sha',
  'ષ': 'shha',
  'સ': 'sa',
  'હ': 'ha',
  'ળ': 'lla',
  'ક્ષ': 'ksha',
  'જ્ઞ': 'gya'
};

Map<String, String> gujaratiSounds = {
  ...gujaratiVowels,
  ...gujaratiConsonants,
  'ં': 'n (anusvara)',
  'ઃ': 'h (visarga)'
};
