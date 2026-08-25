import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:words625/views/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('tour explains Varnamala before returning to sign in',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: OnboardingScreen()),
    );

    expect(find.text('A language app built for everyone'), findsOneWidget);
    expect(find.textContaining('Android, iOS, and the web'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Read, write, listen, and play'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Languages deserve better'), findsOneWidget);
    expect(find.text('Back to sign in'), findsOneWidget);
  });
}
