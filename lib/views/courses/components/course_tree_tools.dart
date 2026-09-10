import 'package:flutter/material.dart';
import 'package:words625/views/settings/settings_page.dart';
import 'package:words625/views/theme.dart';

class UnlockedCoursePathNotice extends StatelessWidget {
  const UnlockedCoursePathNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: context.appWarning.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
          border: Border.all(
            color: context.appWarning.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.lock_open_rounded, color: context.appWarning),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Free navigation is on. Completion still follows your real progress.',
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
              child: const Text('MANAGE'),
            ),
          ],
        ),
      ),
    );
  }
}
