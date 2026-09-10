// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart';

/// One language-independent idea taught by the First words course.
///
/// The English label and the picture are the same in every language, so they
/// are authored once here rather than repeated thirteen times.
class Concept {
  const Concept({required this.id, required this.label});

  final String id;

  /// What the picture shows, in English.
  final String label;

  /// The illustration for this concept. See `tool/fetch_vocab_art.rb`.
  String get art => 'assets/images/vocab/$id.svg';
}

/// Loads and caches `assets/courses/concepts.json`.
///
/// Deliberately not per language: the whole point of a concept is that it is
/// the part of a word course that does not change between languages.
class ConceptCatalogue {
  ConceptCatalogue({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const String _path = 'assets/courses/concepts.json';

  final AssetBundle _bundle;
  Map<String, Concept>? _cache;
  Future<Map<String, Concept>>? _loading;

  /// Every concept, by id. Warm after the first call.
  Future<Map<String, Concept>> load() {
    final cached = _cache;
    if (cached != null) return Future.value(cached);
    // Several word levels can ask at once while the first read is in flight;
    // sharing the future keeps that to one decode.
    return _loading ??= _read();
  }

  /// The concepts already in memory, or null before the first [load].
  Map<String, Concept>? get cached => _cache;

  Future<Map<String, Concept>> _read() async {
    final raw = jsonDecode(await _bundle.loadString(_path)) as Map;
    final concepts = <String, Concept>{
      for (final entry in (raw['concepts'] as List).cast<Map>())
        entry['id'] as String: Concept(
          id: entry['id'] as String,
          label: entry['label'] as String,
        ),
    };
    _cache = concepts;
    _loading = null;
    return concepts;
  }
}

/// The process-wide catalogue, mirroring `courseRepository`.
final ConceptCatalogue conceptCatalogue = ConceptCatalogue();
