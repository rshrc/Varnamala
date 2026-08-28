import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:words625/application/course_provider.dart';
import 'package:words625/application/language_provider.dart';
import 'package:words625/service/locator.dart';
import 'package:words625/views/choose_language/choose_language_page.dart';
import 'package:words625/views/theme.dart';

void main() {
  testWidgets('first-time learner must explicitly choose a language',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    debugResetStreamingSharedPreferencesInstance();
    final preferences = await StreamingSharedPreferences.instance;
    final languageProvider = LanguageProvider(AppPrefs(preferences));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: languageProvider),
          ChangeNotifierProvider(create: (_) => CourseProvider()),
        ],
        child: MaterialApp(
          theme: VarnamalaTheme.lightTheme,
          home: const LangChoicePage(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('What do you want to learn?'), findsOneWidget);
    final languageGrid = tester.widget<GridView>(find.byType(GridView));
    expect(languageGrid.childrenDelegate.estimatedChildCount, 13);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
    expect(languageProvider.canConfirmSelection, isFalse);

    await tester.tap(find.text('Assamese'));
    await tester.pump();

    expect(languageProvider.canConfirmSelection, isTrue);
  });
}
