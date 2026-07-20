/// Urdu is written right-to-left in the Perso-Arabic script, usually in the
/// Nastaliq style. It has no separate vowel letters the way Indic scripts do —
/// the "vowels" below are the long-vowel carriers, and short vowels are marked
/// with optional diacritics (aerab) that are normally left out.
Map<String, String> urduVowels = {
  'ا': 'a / aa',
  'آ': 'aa',
  'و': 'o / u / v',
  'ی': 'i / ee / y',
  'ے': 'e / ai'
};

Map<String, String> urduConsonants = {
  'ب': 'be',
  'پ': 'pe',
  'ت': 'te',
  'ٹ': 'tte',
  'ث': 'se',
  'ج': 'jeem',
  'چ': 'che',
  'ح': 'hay',
  'خ': 'khe',
  'د': 'daal',
  'ڈ': 'ddaal',
  'ذ': 'zaal',
  'ر': 're',
  'ڑ': 'rre',
  'ز': 'ze',
  'ژ': 'zhe',
  'س': 'seen',
  'ش': 'sheen',
  'ص': 'suaad',
  'ض': 'zuaad',
  'ط': 'toe',
  'ظ': 'zoe',
  'ع': 'ain',
  'غ': 'ghain',
  'ف': 'fe',
  'ق': 'qaaf',
  'ک': 'kaaf',
  'گ': 'gaaf',
  'ل': 'laam',
  'م': 'meem',
  'ن': 'noon',
  'ں': 'noon ghunna',
  'ہ': 'he',
  'ھ': 'do chashmi he',
  'ء': 'hamza'
};

Map<String, String> urduSounds = {
  ...urduVowels,
  ...urduConsonants,
};
