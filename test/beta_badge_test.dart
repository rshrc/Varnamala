import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:words625/views/widgets/beta_badge.dart';

void main() {
  testWidgets('beta badge is visible and exposes an accessible status',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: BetaBadge())),
      ),
    );

    expect(find.text('BETA'), findsOneWidget);
    expect(find.bySemanticsLabel('Beta feature'), findsOneWidget);
  });
}
