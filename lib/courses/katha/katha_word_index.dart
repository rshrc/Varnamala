import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// The recorded words on a language's site: a word to its recording's
/// address. Fetched once per site and shared by every episode.
class KathaWordIndex {
  KathaWordIndex({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final Map<String, Future<Map<String, String>>> _bySite = {};

  /// The index on the site at [base]; empty if it cannot be reached, so
  /// tapped words fall back to the device voice. A failed fetch is tried
  /// again on the next call.
  Future<Map<String, String>> at(String base) => _bySite[base] ??= _fetch(base);

  Future<Map<String, String>> _fetch(String base) async {
    // Only the web build plays recordings; tests and tools stay offline.
    if (!kIsWeb) return const {};
    try {
      final response = await _client
          .get(Uri.parse('${base}words/index.json'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        throw http.ClientException('HTTP ${response.statusCode}');
      }
      final index = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      return {
        for (final MapEntry(:key, :value) in (index['words'] as Map).entries)
          key as String: '${base}words/$value',
      };
    } catch (_) {
      _bySite.remove(base);
      return const {};
    }
  }
}
