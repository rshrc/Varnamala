import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web app uses clean path URLs with a Hosting SPA fallback', () {
    final webStrategy = File('lib/core/app_url_strategy_web.dart')
        .readAsStringSync();
    expect(webStrategy, contains('usePathUrlStrategy()'));

    final firebaseConfig = jsonDecode(
      File('firebase.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final hosting = firebaseConfig['hosting'] as Map<String, dynamic>;
    final rewrites = hosting['rewrites'] as List<dynamic>;

    expect(
      rewrites.whereType<Map<String, dynamic>>(),
      contains(
        predicate<Map<String, dynamic>>(
          (rewrite) =>
              rewrite['source'] == '**' &&
              rewrite['destination'] == '/index.html',
        ),
      ),
    );

    final headers = hosting['headers'] as List<dynamic>;
    expect(
      headers.whereType<Map<String, dynamic>>(),
      contains(
        predicate<Map<String, dynamic>>((rule) => rule['regex'] == r'^/[^.]*$'),
      ),
      reason: 'rewritten app routes need app-shell headers before the rewrite',
    );
  });

  test('legacy hash links are upgraded before Flutter starts', () {
    final index = File('web/index.html').readAsStringSync();

    expect(index, contains("window.location.hash.startsWith('#/')"));
    expect(index, contains('window.history.replaceState'));
  });
}
