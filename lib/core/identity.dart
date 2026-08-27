// Varnamala never shows a learner's real name, email address or Google photo to
// anyone else.
//
// The app is used by people learning the language of a place they may have
// complicated ties to — diaspora, converts, migrants, people practising a
// mother tongue they were discouraged from speaking. A leaderboard that prints
// "Rishi Banerjee · rishi@gmail.com" next to a Bengali course tells every other
// user their full legal name, their religion-coded surname, and a contact
// address, in exchange for nothing they asked for.
//
// So the public identity is a short handle derived from their name, plus a
// generated avatar. Both are editable, neither is reversible to an email, and
// the real name stays in the account record where only they can see it.

/// Builds a public handle from a display name: "Rishi Banerjee" -> "Riban".
///
/// Keeps enough of the name that it still feels like theirs, while being far
/// too lossy to identify anyone from. Accounts with no usable name — email
/// sign-ups, or a Google profile with the name hidden — get a generated one
/// from [seed] instead, so they are still distinguishable from each other.
String handleFromName(String? fullName, {String seed = ''}) {
  final parts = (fullName ?? '')
      .split(RegExp(r'[\s._-]+'))
      .map((part) => part.replaceAll(RegExp(r'[^A-Za-z]'), ''))
      .where((part) => part.isNotEmpty)
      .toList();

  if (parts.isEmpty) return generatedHandle(seed);

  String take(String word, int count) =>
      word.length <= count ? word : word.substring(0, count);

  final handle = parts.length == 1
      ? take(parts.first, 6)
      : '${take(parts.first, 2)}${take(parts[1], 3)}';

  return _titleCase(handle);
}

/// Words the generated handles are built from. Deliberately warm and neutral —
/// nothing that could read as an insult when it lands on a stranger.
const List<String> _adjectives = [
  'Swift',
  'Calm',
  'Bright',
  'Keen',
  'Bold',
  'Quiet',
  'Sunny',
  'Clever',
  'Gentle',
  'Merry',
  'Steady',
  'Lucky',
  'Kind',
  'Brave',
  'Warm',
  'Neat',
];

/// Things from the subcontinent a learner might actually meet in a lesson.
const List<String> _nouns = [
  'Mynah',
  'Lotus',
  'Peacock',
  'Koel',
  'Neem',
  'Monsoon',
  'Tabla',
  'Sitar',
  'Jasmine',
  'Banyan',
  'Mango',
  'Kite',
  'Parrot',
  'River',
  'Lantern',
  'Cardamom',
];

/// A stable, pronounceable handle for an account with no name to work from:
/// "SwiftMynah", "CalmLotus". 256 combinations plus a suffix, which is plenty
/// to tell learners apart on a leaderboard.
String generatedHandle(String seed) {
  if (seed.isEmpty) return 'Learner';
  final hash = _hash(seed);
  final adjective = _adjectives[hash % _adjectives.length];
  final noun = _nouns[(hash ~/ _adjectives.length) % _nouns.length];
  return '$adjective$noun';
}

/// What to show for another learner.
///
/// Accounts created before handles existed have nothing stored until their
/// owner next opens the app, so derive something stable and distinct from their
/// user id rather than calling everyone "Learner".
String displayHandle({String? storedHandle, required String userId}) {
  final stored = storedHandle?.trim();
  if (stored != null && stored.isNotEmpty && stored != 'Learner') return stored;
  return generatedHandle(userId);
}

String _titleCase(String word) => word.isEmpty
    ? word
    : word[0].toUpperCase() + word.substring(1).toLowerCase();

/// A short stable suffix for when a handle is already taken. Derived from the
/// user id so the same account always lands on the same fallback.
String handleSuffix(String seed) => (_hash(seed) % 90 + 10).toString();

/// Handles a learner may not take, because they impersonate the app or staff.
const Set<String> reservedHandles = {
  'varnamala',
  'admin',
  'moderator',
  'support',
  'mala',
  'official',
  'staff',
};

/// Whether a handle a learner typed is acceptable.
///
/// Deliberately permissive about scripts — someone may want a handle in their
/// own language — but bans whitespace so it cannot be padded to imitate
/// another user.
String? validateHandle(String handle) {
  final trimmed = handle.trim();
  if (trimmed.length < 3) return 'At least 3 characters.';
  if (trimmed.length > 16) return 'At most 16 characters.';
  if (trimmed.contains(RegExp(r'\s'))) return 'No spaces.';
  if (RegExp(r'[@.]').hasMatch(trimmed)) {
    return 'No @ or dots — a handle is not an email.';
  }
  if (reservedHandles.contains(trimmed.toLowerCase())) {
    return 'That handle is reserved.';
  }
  return null;
}

/// FNV-1a. Small, stable across runs and platforms, and good enough to scatter
/// avatars — this is not used for anything security-sensitive.
int _hash(String value) {
  var hash = 0x811c9dc5;
  for (final unit in value.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash;
}

/// Stable pseudo-random bits for [seed], used to draw an identicon.
int identiconSeed(String seed) => _hash('varnamala:$seed');
