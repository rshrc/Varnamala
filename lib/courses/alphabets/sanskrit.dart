/// Sanskrit is written in Devanagari, but its varnamala is the full classical
/// inventory — including the vocalic vowels and the retroflex sibilant that
/// modern Hindi has largely stopped using.
Map<String, String> sanskritVowels = {
  'अ': 'a',
  'आ': 'aa',
  'इ': 'i',
  'ई': 'ii',
  'उ': 'u',
  'ऊ': 'uu',
  'ऋ': 'ri',
  'ॠ': 'rii',
  'ऌ': 'li',
  'ए': 'e',
  'ऐ': 'ai',
  'ओ': 'o',
  'औ': 'au'
};

Map<String, String> sanskritConsonants = {
  'क': 'ka',
  'ख': 'kha',
  'ग': 'ga',
  'घ': 'gha',
  'ङ': 'nga',
  'च': 'cha',
  'छ': 'chha',
  'ज': 'ja',
  'झ': 'jha',
  'ञ': 'nya',
  'ट': 'ta',
  'ठ': 'tha',
  'ड': 'da',
  'ढ': 'dha',
  'ण': 'na',
  'त': 'ta',
  'थ': 'tha',
  'द': 'da',
  'ध': 'dha',
  'न': 'na',
  'प': 'pa',
  'फ': 'pha',
  'ब': 'ba',
  'भ': 'bha',
  'म': 'ma',
  'य': 'ya',
  'र': 'ra',
  'ल': 'la',
  'व': 'va',
  'श': 'sha',
  'ष': 'shha',
  'स': 'sa',
  'ह': 'ha'
};

Map<String, String> sanskritSounds = {
  ...sanskritVowels,
  ...sanskritConsonants,
  'ं': 'm (anusvara)',
  'ः': 'h (visarga)'
};
