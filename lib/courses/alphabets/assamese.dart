/// Assamese uses the Bengali-Assamese script, but two letters and several
/// sounds are its own: `ৰ` replaces `র` for "ra", `ৱ` carries "wa", and the
/// three sibilants `শ ষ স` are all pronounced as the velar fricative "xa".
Map<String, String> assameseVowels = {
  'অ': 'o',
  'আ': 'a',
  'ই': 'i',
  'ঈ': 'i',
  'উ': 'u',
  'ঊ': 'u',
  'ঋ': 'ri',
  'এ': 'e',
  'ঐ': 'oi',
  'ও': 'ou',
  'ঔ': 'ou'
};

Map<String, String> assameseConsonants = {
  'ক': 'ka',
  'খ': 'kha',
  'গ': 'ga',
  'ঘ': 'gha',
  'ঙ': 'nga',
  'চ': 'sa',
  'ছ': 'sa',
  'জ': 'za',
  'ঝ': 'zha',
  'ঞ': 'nya',
  'ট': 'ta',
  'ঠ': 'tha',
  'ড': 'da',
  'ঢ': 'dha',
  'ণ': 'na',
  'ত': 'ta',
  'থ': 'tha',
  'দ': 'da',
  'ধ': 'dha',
  'ন': 'na',
  'প': 'pa',
  'ফ': 'pha',
  'ব': 'ba',
  'ভ': 'bha',
  'ম': 'ma',
  'য': 'za',
  'ৰ': 'ra',
  'ল': 'la',
  'ৱ': 'wa',
  'শ': 'xa',
  'ষ': 'xa',
  'স': 'xa',
  'হ': 'ha',
  'ক্ষ': 'khya',
  'ড়': 'ra',
  'ঢ়': 'rha',
  'য়': 'ya'
};

Map<String, String> assameseSounds = {
  ...assameseVowels,
  ...assameseConsonants,
  'ৎ': 't',
  'ং': 'ng',
  'ঃ': 'h',
  'ঁ': 'n'
};
