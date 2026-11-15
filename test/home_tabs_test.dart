import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:words625/views/home/components/bottom_navigator.dart';
import 'package:words625/views/home/components/home_destinations.dart';
import 'package:words625/views/theme_palette.dart';

void main() {
  // Six tabs since Stories joined: every label still has to fit on the
  // narrowest phone the app supports, without overflowing.
  for (final width in [320.0, 360.0, 390.0]) {
    testWidgets(
      'the bottom bar fits all ${homeDestinations.length} tabs at $width px',
      (tester) async {
        tester.view.physicalSize = Size(width * 3, 800 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(appPalettes.first, Brightness.light),
            home: Scaffold(
              bottomNavigationBar: BottomNavigator(
                currentIndex: 1,
                onPress: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Stories'), findsOneWidget);
      },
    );
  }
}
