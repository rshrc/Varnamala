// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

// Project imports:
import 'package:words625/application/theme_provider.dart';
import 'package:words625/core/responsive.dart';
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
      body: ContentBounds(
        child: ListView(
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
                    icon: Icon(Icons.light_mode_rounded,
                        color: context.appWarning),
                    label: const Text('Light'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon:
                        Icon(Icons.dark_mode_rounded, color: context.appViolet),
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
              title: 'Colour theme',
              child: _PalettePicker(
                selected: theme.palette,
                onSelected: theme.setPalette,
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

/// A swatch per palette, showing the actual colours rather than only a name -
/// nobody can pick "Terracotta" from a word.
class _PalettePicker extends StatelessWidget {
  const _PalettePicker({required this.selected, required this.onSelected});

  final AppPalette selected;
  final ValueChanged<AppPalette> onSelected;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Every theme has a light and a dark version, so this and the setting '
          'above are independent.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.appTextSecondary,
              ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final palette in appPalettes)
              _PaletteSwatch(
                palette: palette,
                brightness: brightness,
                isSelected: palette.id == selected.id,
                onTap: () => onSelected(palette),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          selected.description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.appTextSecondary,
                fontStyle: FontStyle.italic,
              ),
        ),
      ],
    );
  }
}

class _PaletteSwatch extends StatelessWidget {
  const _PaletteSwatch({
    required this.palette,
    required this.brightness,
    required this.isSelected,
    required this.onTap,
  });

  final AppPalette palette;
  final Brightness brightness;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Built in the brightness the learner is actually looking at, so the
    // swatch previews the real thing rather than an approximation of it.
    final scheme = buildAppTheme(palette, brightness).colorScheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${palette.name} theme',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
        child: SizedBox(
          width: 84,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 56,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius:
                      BorderRadius.circular(VarnamalaTheme.radiusLarge),
                  border: Border.all(
                    color: isSelected ? context.appAccent : context.appBorder,
                    width: isSelected ? 2.5 : 1.2,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final color in [
                        scheme.primary,
                        scheme.secondary,
                        scheme.tertiary,
                      ])
                        Container(
                          width: 16,
                          height: 16,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                palette.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.2,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color:
                      isSelected ? context.appAccent : context.appTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
