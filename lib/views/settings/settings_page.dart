// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

// Project imports:
import 'package:words625/application/theme_provider.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/service/locator.dart';
import 'package:words625/views/auth/components/logout_button.dart';
import 'package:words625/views/theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final demoCount = getIt<AppPrefs>()
        .preferences
        .getInt(PrefsConstants.demoCount, defaultValue: 0)
        .getValue();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _SettingsCard(
            title: 'Appearance',
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_rounded,
                      color: context.appInfo),
                  label: const Text('System'),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon:
                      Icon(Icons.light_mode_rounded, color: context.appWarning),
                  label: const Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_rounded, color: context.appViolet),
                  label: const Text('Dark'),
                ),
              ],
              selected: {theme.themeMode},
              onSelectionChanged: (selection) {
                theme.setThemeMode(selection.first);
              },
              showSelectedIcon: false,
            ),
          ),
          const SizedBox(height: 14),
          _SettingsCard(
            title: 'Learning path',
            child: PreferenceBuilder<bool>(
              preference: getIt<AppPrefs>().preferences.getBool(
                    PrefsConstants.unlockAllLevels,
                    defaultValue: false,
                  ),
              builder: (context, unlocked) => SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  unlocked
                      ? Icons.lock_open_rounded
                      : Icons.lock_outline_rounded,
                  color: unlocked ? context.appWarning : context.appSuccess,
                ),
                title: const Text('Unlock all levels'),
                subtitle: Text(
                  unlocked
                      ? 'Free navigation is on. Your actual progress is unchanged.'
                      : 'Levels unlock gradually as you complete the path.',
                ),
                value: unlocked,
                onChanged: (value) => _setAllLevelsUnlocked(context, value),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _SettingsCard(
            title: 'Demo privacy',
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.privacy_tip_outlined,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              title: Text('$demoCount demos started on this device'),
              subtitle: const Text(
                'Demo questions, answers, and progress are not written to Firebase.',
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _SettingsCard(
            title: 'Account',
            child: Column(
              children: [
                Text(
                  'Signing out removes this account from the app. Your theme and local demo count stay on this device.',
                ),
                SizedBox(height: 18),
                LogoutButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setAllLevelsUnlocked(
    BuildContext context,
    bool unlocked,
  ) async {
    if (unlocked) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: Icon(Icons.warning_amber_rounded, color: context.appWarning),
          title: const Text('Unlock every level?'),
          content: const Text(
            'Locking is there to make sure learning is enforced and gradual, '
            'and to help maintain discipline.\n\n'
            'Unlocking lets you jump around, but it does not mark anything '
            'complete or award XP and gems. You can lock the path again at '
            'any time and it will return to your real progress.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('KEEP LOCKED'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('UNLOCK ALL'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    await getIt<AppPrefs>().setBool(
      PrefsConstants.unlockAllLevels,
      value: unlocked,
    );
    if (!context.mounted || unlocked) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('The learning path now follows your progress again.'),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
