/// Strips punctuation a romanized course word carries inside a sentence and
/// lowercases it so dictionary lookups match authored dictionary keys.
String normalizeWord(String word) => word
    .toLowerCase()
    .replaceAll(RegExp(r"^[^a-z0-9]+"), '')
    .replaceAll(RegExp(r"[^a-z0-9]+$"), '');

/// Removes sentence punctuation from the edge of a generated draggable tile.
/// Internal apostrophes and hyphens remain part of the word.
String exerciseTokenText(String value) => value
    .replaceAll(
      RegExp(r'''^[\s.,!?;:…।॥،؛؟"“”‘’()\[\]{}]+'''),
      '',
    )
    .replaceAll(
      RegExp(r'''[\s.,!?;:…।॥،؛؟"“”‘’()\[\]{}]+$'''),
      '',
    );
