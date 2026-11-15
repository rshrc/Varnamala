/// How roman text is shown. The same data renders both ways.
enum KathaSpelling {
  /// Reads like a text message: no capitals, nasals spelled out.
  casual,

  /// Capitals for retroflex sounds, for learners who want them.
  precise;

  /// [precise] roman text as this spelling shows it.
  ///
  /// Casual drops the retroflex capitals and spells a nasalised vowel
  /// (`chale~ge`) with an `n` (`chalenge`).
  String show(String precise) => switch (this) {
    KathaSpelling.precise => precise,
    KathaSpelling.casual => precise.replaceAll('~', 'n').toLowerCase(),
  };
}
