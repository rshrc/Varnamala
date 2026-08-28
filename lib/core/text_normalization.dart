/// Strips punctuation a romanized course word carries inside a sentence and
/// lowercases it so dictionary lookups match authored dictionary keys.
String normalizeWord(String word) => word
    .toLowerCase()
    .replaceAll(RegExp(r"^[^a-z0-9]+"), '')
    .replaceAll(RegExp(r"[^a-z0-9]+$"), '');
