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

    final dictionary = (jsonDecode(await _bundle.loadString(
      '$dir/dictionary.json',
    )) as Map)
        .map((word, gloss) =>
            MapEntry(normalizeWord(word as String), gloss as String));

    final content = _LanguageContent(tree: tree, dictionary: dictionary);
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
  const _LanguageContent({required this.tree, required this.dictionary});

  final List<List<Map<String, dynamic>>> tree;
  final Map<String, String> dictionary;
}

/// Strips the punctuation a word carries inside a sentence ("enna?" -> "enna")
/// and lowercases it, so dictionary lookups match however the word was written.
String normalizeWord(String word) => word
    .toLowerCase()
    .replaceAll(RegExp(r"^[^a-z0-9]+"), '')
    .replaceAll(RegExp(r"[^a-z0-9]+$"), '');
