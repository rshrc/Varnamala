import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('screen navigation is exclusively handled by AutoRoute', () {
    final violations = <String>[];
    final forbidden = <RegExp, String>{
      RegExp(r'\bNavigator\s*\.'): 'Navigator static API',
      RegExp(r'\bNavigator\s*\.of\s*\('): 'Navigator.of',
      RegExp(r'\bMaterialPageRoute\b'): 'MaterialPageRoute',
      RegExp(r'\bCupertinoPageRoute\b'): 'CupertinoPageRoute',
      RegExp(r'\bPageRouteBuilder\b'): 'PageRouteBuilder',
      RegExp(r'\bpushNamed\s*\('): 'named Navigator route',
    };

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      for (final entry in forbidden.entries) {
        if (entry.key.hasMatch(source)) {
          violations.add('${entity.path}: ${entry.value}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Use a generated PageRouteInfo through context.router instead.',
    );
  });
}
