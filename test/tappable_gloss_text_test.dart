import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:words625/views/lesson/exercises/widgets/tappable_gloss_text.dart';

void main() {
  testWidgets('tapping a target word shows its dictionary meaning',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TappableGlossText(
            text: 'Amar bari.',
            style: const TextStyle(fontSize: 24),
            meaningLookup: (word) => switch (word) {
              'Amar' => 'my',
              'bari.' => 'house',
              _ => null,
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Amar'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('my'), findsOneWidget);
  });
}
