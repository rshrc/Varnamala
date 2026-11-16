import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:words625/application/language_provider.dart';
import 'package:words625/service/locator.dart';
import 'package:words625/views/katha/shelf/katha_shelf.dart';
import 'package:words625/views/theme.dart';

void main() {
  testWidgets('the Katha info button explains visual and audio learning', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    debugResetStreamingSharedPreferencesInstance();
    final preferences = await StreamingSharedPreferences.instance;

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LanguageProvider(AppPrefs(preferences)),
        child: MaterialApp(
          theme: VarnamalaTheme.lightTheme,
          home: const Scaffold(body: KathaShelf()),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text(
        'Watch, listen, and follow Dev through the city while picking up '
        'Kannada in context.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('katha-info')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('A story you can learn from'), findsOneWidget);
    expect(find.text('See what the words mean'), findsOneWidget);
    expect(find.text('Hear the whole exchange'), findsOneWidget);
    expect(find.text('Read without getting stuck'), findsOneWidget);
    expect(find.text('Remember the situation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
