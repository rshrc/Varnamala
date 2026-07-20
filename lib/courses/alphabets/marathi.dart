/// Marathi is written in Devanagari, but unlike Hindi it keeps the retroflex
/// lateral `ळ` and the extra sibilants inherited from Sanskrit.
Map<String, String> marathiVowels = {
  'अ': 'a',
  'आ': 'aa',
  'इ': 'i',
  'ई': 'ee',
  'उ': 'u',
  'ऊ': 'oo',
  'ऋ': 'ru',
  'ए': 'e',
  'ऐ': 'ai',
  'ओ': 'o',
  'औ': 'au'
};

Map<String, String> marathiConsonants = {
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
  'ह': 'ha',
  'ळ': 'lla',
  'क्ष': 'ksha',
  'ज्ञ': 'dnya'
};

Map<String, String> marathiSounds = {
  ...marathiVowels,
  ...marathiConsonants,
  'ं': 'n (anusvara)',
  'ः': 'h (visarga)'
};
