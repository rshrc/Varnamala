// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

// Project imports:
import 'package:words625/application/course_provider.dart';
import 'package:words625/application/language_provider.dart';
import 'package:words625/core/responsive.dart';
import 'package:words625/service/locator.dart';
import 'package:words625/views/choose_language/choose_language_page.dart';
import 'package:words625/views/home/components/bottom_navigator.dart';
import 'package:words625/views/home/components/side_navigator.dart';
import 'package:words625/views/theme.dart';

/// Puts [child] on screen at an exact window size, so each expectation is
/// about one specific breakpoint rather than the test harness default.
Future<void> pumpAtSize(
  WidgetTester tester,
  Size size,
  Widget child,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(theme: VarnamalaTheme.lightTheme, home: Scaffold(body: child)),
  );
  await tester.pump();
}

void main() {
  group('breakpoints', () {
    test('window widths map to the size class they look like', () {
      expect(Breakpoint.of(390), Breakpoint.compact); // phone
      expect(Breakpoint.of(599), Breakpoint.compact);
      expect(Breakpoint.of(768), Breakpoint.medium); // iPad portrait
      expect(Breakpoint.of(1024), Breakpoint.expanded); // iPad landscape
      expect(Breakpoint.of(1600), Breakpoint.large); // desktop
    });

    test('side navigation appears only once there is room for it', () {
      expect(Breakpoint.compact.hasSideNavigation, isFalse);
      expect(Breakpoint.medium.hasSideNavigation, isFalse);
      expect(Breakpoint.expanded.hasSideNavigation, isTrue);
      expect(Breakpoint.large.hasSideNavigation, isTrue);
      expect(Breakpoint.expanded.hasExtendedSideNavigation, isFalse);
      expect(Breakpoint.large.hasExtendedSideNavigation, isTrue);
    });
  });

  group('ContentBounds', () {
    testWidgets('fills a phone screen', (tester) async {
      await pumpAtSize(
        tester,
        const Size(390, 844),
        const ContentBounds(child: SizedBox(height: 10, key: Key('content'))),
      );

      expect(tester.getSize(find.byKey(const Key('content'))).width, 390);
    });

    testWidgets('caps and centres the column on a desktop window',
        (tester) async {
      await pumpAtSize(
        tester,
        const Size(1600, 900),
        const ContentBounds(child: SizedBox(height: 10, key: Key('content'))),
      );

      final content = find.byKey(const Key('content'));
      expect(tester.getSize(content).width, ContentWidth.column);
      // Equal space either side: the column sits in the middle, not pinned to
      // the leading edge.
      expect(tester.getTopLeft(content).dx, 1600 / 2 - ContentWidth.column / 2);
    });
  });

  group('home navigation', () {
    testWidgets('bottom bar keeps its tabs together on a tablet',
        (tester) async {
      await pumpAtSize(
        tester,
        const Size(1024, 768),
        BottomNavigator(currentIndex: 0, onPress: (_) {}),
      );

      final learn = tester.getTopLeft(find.text('Learn')).dx;
      final shop = tester.getTopRight(find.text('Shop')).dx;
      expect(shop - learn, lessThan(ContentWidth.column));
    });

    testWidgets('side rail shows every destination and labels them when wide',
        (tester) async {
      await pumpAtSize(
        tester,
        const Size(1600, 900),
        SideNavigator(
          currentIndex: 0,
          onPress: (_) {},
          onOpenFlashcards: () {},
          onOpenSettings: () {},
        ),
      );

      for (final label in ['Learn', 'Script', 'Profile', 'Leagues', 'Shop']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(
          tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
          isTrue);
      // The rail has vertical room a bottom bar does not, so it also reaches
      // the two places that otherwise hide behind the course path.
      expect(find.text('Flashcards'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('every rail icon sits on the same vertical line',
        (tester) async {
      // Laid out the way the home shell does it, so the rail takes its own
      // width instead of being stretched across the window.
      await pumpAtSize(
        tester,
        const Size(1600, 900),
        Row(
          children: [
            SideNavigator(
              currentIndex: 0,
              onPress: (_) {},
              onOpenFlashcards: () {},
              onOpenSettings: () {},
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      );

      // The secondary entries at the bottom used their own padding rather than
      // the rail's icon column, so they sat visibly off-axis.
      double iconCentre(IconData icon) =>
          tester.getCenter(find.byIcon(icon).first).dx;

      final destination = iconCentre(Icons.school_rounded);
      expect(iconCentre(Icons.style_rounded), closeTo(destination, 0.5));
      expect(iconCentre(Icons.settings_rounded), closeTo(destination, 0.5));
    });

    testWidgets('bottom bar stays five tabs and no more', (tester) async {
      await pumpAtSize(
        tester,
        const Size(390, 844),
        BottomNavigator(currentIndex: 0, onPress: (_) {}),
      );

      // Flashcards and Settings are rail-only: a phone reaches them from the
      // course path and the profile bar instead of a cramped sixth tab.
      expect(find.text('Flashcards'), findsNothing);
      expect(find.text('Settings'), findsNothing);
    });
  });

  testWidgets(
      'language picker reflows from two columns to more as the window grows',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    debugResetStreamingSharedPreferencesInstance();
    final preferences = await StreamingSharedPreferences.instance;

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => LanguageProvider(AppPrefs(preferences)),
          ),
          ChangeNotifierProvider(create: (_) => CourseProvider()),
        ],
        child: MaterialApp(
          theme: VarnamalaTheme.lightTheme,
          home: const LangChoicePage(),
        ),
      ),
    );
    await tester.pump();

    // On a phone the third tile has wrapped onto a second row.
    expect(
      tester.getTopLeft(find.text('Gujarati')).dy,
      greaterThan(tester.getTopLeft(find.text('Assamese')).dy),
    );

    // Widening the window - rotating an iPad, or resizing on desktop - adds
    // columns rather than blowing the same two tiles up to fill the space.
    tester.view.physicalSize = const Size(1400, 900);
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('Gujarati')).dy,
      tester.getTopLeft(find.text('Assamese')).dy,
    );
    expect(
      tester.getSize(find.byType(LanguageOptionTile).first).width,
      lessThanOrEqualTo(210),
    );
  });

  group('snackbars', () {
    Future<double> snackBarWidth(WidgetTester tester, Size window) async {
      tester.view.physicalSize = window;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: VarnamalaTheme.lightTheme,
          // Exactly how Words625App wires it, so the test covers the real
          // question: does a Theme injected under MaterialApp.builder reach a
          // SnackBar that a Scaffold renders further down?
          builder: (context, child) => SnackBarWidthCap(child: child!),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved.')),
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      // The SnackBar's own box always spans the window; the sized box that
      // actually bounds the pill sits inside it, around the Material.
      return tester
          .getSize(
            find
                .descendant(
                  of: find.byType(SnackBar),
                  matching: find.byType(Material),
                )
                .first,
          )
          .width;
    }

    testWidgets('a desktop window does not turn a message into a banner',
        (tester) async {
      expect(await snackBarWidth(tester, const Size(1440, 900)),
          ContentWidth.column);
    });

    testWidgets('a phone keeps the snackbar on the edges it should use',
        (tester) async {
      // Full width less the floating inset, not the desktop cap.
      final width = await snackBarWidth(tester, const Size(390, 844));
      expect(width, lessThan(390));
      expect(width, isNot(ContentWidth.column));
    });
  });
}
