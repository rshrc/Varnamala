import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:words625/views/theme.dart';

void main() {
  testWidgets('light, dark, and system theme transitions do not throw',
      (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(
      tester.platformDispatcher.clearPlatformBrightnessTestValue,
    );

    final mode = ValueNotifier(ThemeMode.light);
    addTearDown(mode.dispose);

    await tester.pumpWidget(
      ValueListenableBuilder<ThemeMode>(
        valueListenable: mode,
        builder: (context, value, _) => MaterialApp(
          theme: VarnamalaTheme.lightTheme,
          darkTheme: VarnamalaTheme.darkTheme,
          themeMode: value,
          home: const _ThemeComponents(),
        ),
      ),
    );

    for (final nextMode in [
      ThemeMode.dark,
      ThemeMode.light,
      ThemeMode.system,
    ]) {
      mode.value = nextMode;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}

class _ThemeComponents extends StatelessWidget {
  const _ThemeComponents();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        actions: const [Icon(Icons.settings_rounded)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: ListTile(
              leading: Icon(Icons.dark_mode_rounded),
              title: Text('Theme preview'),
              subtitle: Text('Readable in every mode'),
              trailing: Chip(label: Text('System')),
            ),
          ),
          const TextField(decoration: InputDecoration(labelText: 'Example')),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: const {ThemeMode.system},
            onSelectionChanged: (_) {},
          ),
          Tooltip(
            message: 'Tooltip preview',
            child: FilledButton(
              onPressed: () {},
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_rounded),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'A'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'B',
          ),
        ],
      ),
    );
  }
}
