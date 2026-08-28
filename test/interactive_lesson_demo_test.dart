import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:words625/views/debug/interactive_lesson_demo_page.dart';
import 'package:words625/views/theme.dart';

void main() {
  testWidgets('debug lesson supports tap-built word bank submission',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: VarnamalaTheme.darkTheme,
        home: const InteractiveLessonDemoPage(),
      ),
    );
    await tester.pump();

    expect(find.text('Interactive lesson lab'), findsOneWidget);
    expect(find.textContaining('progress is not saved'), findsOneWidget);
    expect(find.byType(Draggable<String>), findsNWidgets(4));

    await tester.tap(find.text('Nanna'));
    await tester.tap(find.text('hesaru'));
    await tester.tap(find.text('Ravi.'));
    await tester.pump();

    final check = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'CHECK'),
    );
    expect(check.onPressed, isNotNull);

    await tester.tap(find.widgetWithText(ElevatedButton, 'CHECK'));
    await tester.pump();

    expect(find.text('Correct'), findsOneWidget);
  });

  testWidgets('word-bank tokens can be dragged into the answer area',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: InteractiveLessonDemoPage()),
    );
    await tester.pump();

    final from = tester.getCenter(find.text('Nanna'));
    final to = tester.getCenter(find.text('Drag words here · tap also works'));
    final gesture = await tester.startGesture(from);
    await tester.pump(const Duration(milliseconds: 40));
    await gesture.moveTo(to);
    await tester.pump(const Duration(milliseconds: 200));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Drag words here · tap also works'), findsNothing);

    await tester.tap(find.text('hesaru'));
    await tester.tap(find.text('Ravi.'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'CHECK'));
    await tester.pump();

    expect(find.text('Correct'), findsOneWidget);
  });

  testWidgets('sentence token attaches to the pointer during direct drag',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: InteractiveLessonDemoPage()),
    );
    await _completeFirstWordBank(tester);

    expect(find.text('Put the words in the correct order'), findsOneWidget);

    final from = tester.getCenter(find.text('Idu'));
    final gesture = await tester.startGesture(from);
    await gesture.moveBy(const Offset(24, 0));
    await tester.pump(const Duration(milliseconds: 40));

    // One copy remains faintly at the origin and one is the pointer-attached
    // overlay feedback.
    expect(find.text('Idu'), findsNWidgets(2));

    await gesture.moveTo(tester.getCenter(find.text('mane.').first));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('typed blank is inline without a Material field label',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: VarnamalaTheme.darkTheme,
        home: const InteractiveLessonDemoPage(),
      ),
    );
    await _completeFirstWordBank(tester);

    // The sentence-order response is initialized automatically. Its result is
    // irrelevant here; continue into the choice blank.
    await tester.tap(find.widgetWithText(ElevatedButton, 'CHECK'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'CONTINUE'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('manege'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'CHECK'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'CONTINUE'));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration?.labelText, isNull);
    expect(field.decoration?.prefixIcon, isNull);
    expect(field.decoration?.focusedBorder, InputBorder.none);
    expect(field.decoration?.filled, isFalse);
    expect(find.text('type here'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'ishta');
    await tester.pump();
    final check = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'CHECK'),
    );
    expect(check.onPressed, isNotNull);
  });

  testWidgets('adaptive retry is visibly identified as a previous mistake',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: InteractiveLessonDemoPage()),
    );
    await tester.pump();

    // Submit an intentionally incorrect first exercise.
    await tester.tap(find.text('Nimma'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'CHECK'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'CONTINUE'));
    await tester.pumpAndSettle();

    // Sentence order is the first intervening exercise.
    await tester.tap(find.widgetWithText(ElevatedButton, 'CHECK'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'CONTINUE'));
    await tester.pumpAndSettle();

    // Fill-choice is the second intervening exercise.
    await tester.tap(find.text('manege'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'CHECK'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'CONTINUE'));
    await tester.pumpAndSettle();

    expect(find.text('MISTAKE REVIEW'), findsOneWidget);
    expect(
      find.text('This revisits something you missed earlier.'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        'Mistake review. This exercise revisits something you missed earlier.',
      ),
      findsOneWidget,
    );
  });
}

Future<void> _completeFirstWordBank(WidgetTester tester) async {
  await tester.pump();
  await tester.tap(find.text('Nanna'));
  await tester.tap(find.text('hesaru'));
  await tester.tap(find.text('Ravi.'));
  await tester.pump();
  await tester.tap(find.widgetWithText(ElevatedButton, 'CHECK'));
  await tester.pump();
  await tester.tap(find.widgetWithText(ElevatedButton, 'CONTINUE'));
  await tester.pumpAndSettle();
}
