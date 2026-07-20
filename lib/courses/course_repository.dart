// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart';

// Project imports:
import 'package:words625/core/enums.dart';
import 'package:words625/core/logger.dart';
import 'package:words625/domain/course/course.dart';

/// Course content lives as human-editable JSON under `assets/courses/<language>/`:
///
/// ```
/// assets/courses/tamil/
///   manifest.json      course order, tree layout, icon + colour per course
///   dictionary.json    romanized word -> English gloss (powers word-tap hints)
///   basics.json        the levels of one course
///   greetings.json
///   ...
/// ```
///
/// Keeping levels in JSON means a language contributor can edit a lesson
/// without touching Dart, and the app picks the change up on a hot restart.
class CourseRepository {
  CourseRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  /// Parsed-but-unpersonalised course data, keyed by language. The learner's
  /// name is spliced in per read, so the cache survives an account switch.
  final Map<TargetLanguage, _LanguageContent> _cache = {};

  /// The language whose courses were loaded most recently — i.e. the one the
  /// learner is actually studying. Word lookups follow this rather than a
  /// separate preference, so a lesson can never be glossed against the wrong
  /// language's dictionary.
  TargetLanguage? _activeLanguage;

  static const String _root = 'assets/courses';

  /// Token used in the JSON wherever the learner's own first name belongs.
  static const String _namePlaceholder = '{name}';

  /// Course tree for [language], grouped into the rows the winding path draws
  /// (a group of one renders a single node, two render side by side, three
  /// render as a row).
  Future<List<List<Course>>> courses(
    TargetLanguage language, {
    required String firstName,
  }) async {
    final content = await _content(language);
    _activeLanguage = language;

    // The learner's own name appears inside `basics` and `introductions`
    // sentences. It is the one word no dictionary can ship a gloss for, so
    // give it one here — otherwise it is the only untappable word in a lesson.
    final nameKey = normalizeWord(firstName);
    if (nameKey.isNotEmpty) {
      content.dictionary.putIfAbsent(nameKey, () => 'your name');
    }

    return content.tree
        .map((group) => group
            .map((json) => Course.fromJson(_personalise(json, firstName)))
            .toList())
        .toList();
  }

  /// Romanized word -> English gloss for [language]. Loaded alongside the
  /// courses so lesson word-taps never have to wait on IO.
  Future<Map<String, String>> dictionary(TargetLanguage language) async =>
      (await _content(language)).dictionary;

  /// The dictionary for [language] if it has already been loaded. Lesson
  /// widgets look words up during `build`, which cannot await.
  Map<String, String>? cachedDictionary(TargetLanguage language) =>
      _cache[language]?.dictionary;

  /// Dictionary for the course the learner is currently in. Always warm by the
  /// time a lesson opens, because the course tree loads it first.
  Map<String, String>? get activeDictionary =>
      _activeLanguage == null ? null : _cache[_activeLanguage]?.dictionary;

  /// Mala's asides for [language], keyed by the course they sit beside.
  Map<String, TrailNote> notes(TargetLanguage language) =>
      _cache[language]?.notes ?? const {};

  Future<_LanguageContent> _content(TargetLanguage language) async {
    final cached = _cache[language];
    if (cached != null) return cached;

    final dir = '$_root/${language.name}';
    final manifest =
        jsonDecode(await _bundle.loadString('$dir/manifest.json')) as Map;
    final courses = <String, Map<String, dynamic>>{};

    for (final entry in (manifest['courses'] as List).cast<Map>()) {
      final id = entry['id'] as String;
      final levels = jsonDecode(await _bundle.loadString('$dir/$id.json'));
      courses[id] = {
        'courseName': entry['title'] ?? id,
        'image': 'assets/images/${entry['icon']}.png',
        'color': int.parse(entry['color'] as String),
        'levels': (levels as Map)['levels'],
      };
    }

    // `tree` lists course ids row by row; that nesting is what gives the course
    // map its winding shape instead of a straight column.
    final tree = <List<Map<String, dynamic>>>[];
    for (final row in (manifest['tree'] as List).cast<List>()) {
      final group = <Map<String, dynamic>>[];
      for (final id in row.cast<String>()) {
        final course = courses[id];
        if (course == null) {
          logger.e('Course "$id" is in ${language.name}/manifest.json tree '
              'but has no entry in its courses list');
          continue;
        }
        group.add(course);
      }
      if (group.isNotEmpty) tree.add(group);
    }

    // The dictionary only enriches lessons with tap-a-word hints. If it is
    // missing the courses must still open — losing hints is a far better
    // outcome than losing the language.
    var dictionary = <String, String>{};
    try {
      dictionary = (jsonDecode(await _bundle.loadString('$dir/dictionary.json'))
              as Map)
          .map((word, gloss) =>
              MapEntry(normalizeWord(word as String), gloss as String));
    } catch (error) {
      logger.e('No usable dictionary for ${language.name}: $error');
    }

    // Notes are decoration on top of the path; a language without them simply
    // shows a plainer trail.
    final notes = <String, TrailNote>{};
    try {
      final raw = jsonDecode(await _bundle.loadString('$dir/notes.json')) as Map;
      for (final note in (raw['notes'] as List).cast<Map>()) {
        final course = courses[note['after']];
        if (course == null) continue;
        notes[course['courseName'] as String] = TrailNote(
          text: note['text'] as String,
          mood: (note['mood'] as String?) ?? 'cute',
        );
      }
    } catch (_) {
      // No notes for this language yet.
    }

    final content = _LanguageContent(
      tree: tree,
      dictionary: dictionary,
      notes: notes,
    );
    _cache[language] = content;
    return content;
  }

  /// Deep-copies [json], replacing the name placeholder as it goes. A copy is
  /// required because the cached maps are shared across reads.
  dynamic _personalise(dynamic json, String firstName) {
    if (json is String) return json.replaceAll(_namePlaceholder, firstName);
    if (json is List) {
      return json.map((e) => _personalise(e, firstName)).toList();
    }
    if (json is Map) {
      return json.map<String, dynamic>(
        (key, value) => MapEntry(key as String, _personalise(value, firstName)),
      );
    }
    return json;
  }
}

class _LanguageContent {
  const _LanguageContent({
    required this.tree,
    required this.dictionary,
    required this.notes,
  });

  final List<List<Map<String, dynamic>>> tree;
  final Map<String, String> dictionary;

  /// Trail notes keyed by the course title they sit beside.
  final Map<String, TrailNote> notes;
}

/// A short aside from Mala, pinned next to one course on the path — a fact
/// about the language or a usage tip, so the empty side of the winding path
/// teaches something instead of just sitting there.
class TrailNote {
  const TrailNote({required this.text, required this.mood});

  final String text;

  /// Which mascot pose to draw, e.g. `excited` -> `assets/images/mala/mala_excited.png`.
  final String mood;

  String get image => 'assets/images/mala/mala_$mood.png';
}

/// Strips the punctuation a word carries inside a sentence ("enna?" -> "enna")
/// and lowercases it, so dictionary lookups match however the word was written.
String normalizeWord(String word) => word
    .toLowerCase()
    .replaceAll(RegExp(r"^[^a-z0-9]+"), '')
    .replaceAll(RegExp(r"[^a-z0-9]+$"), '');
