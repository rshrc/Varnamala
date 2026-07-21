// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:chiclet/chiclet.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/identity_provider.dart';
import 'package:words625/views/theme.dart';
import 'package:words625/views/widgets/identicon.dart';

Future<void> showEditIdentitySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _EditIdentitySheet(),
  );
}

class _EditIdentitySheet extends StatefulWidget {
  const _EditIdentitySheet();

  @override
  State<_EditIdentitySheet> createState() => _EditIdentitySheetState();
}

class _EditIdentitySheetState extends State<_EditIdentitySheet> {
  late final TextEditingController _controller = TextEditingController(
    text: context.read<IdentityProvider>().handle ?? '',
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final identity = context.read<IdentityProvider>();
    final problem = await identity.setHandle(_controller.text);
    if (!mounted) return;
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final identity = context.watch<IdentityProvider>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: VarnamalaTheme.textHint.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'How others see you',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Identicon(
                  seed: identity.avatarSeed ?? identity.handle ?? 'varnamala',
                  size: 68,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: identity.shuffleAvatar,
                    icon: const Icon(Icons.casino_rounded, size: 20),
                    label: const Text('New avatar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: VarnamalaTheme.peacockTeal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color:
                            VarnamalaTheme.peacockTeal.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              maxLength: 16,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                labelText: 'Handle',
                errorText: _error,
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _PrivacyNote(),
            const SizedBox(height: 22),
            ChicletAnimatedButton(
              width: double.infinity,
              height: 50,
              backgroundColor: VarnamalaTheme.peacockTeal,
              onPressed: identity.isSaving ? null : _save,
              child: Text(
                identity.isSaving ? 'Saving...' : 'Save',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The reason this screen exists, said plainly and where it is relevant.
class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: VarnamalaTheme.peacockTeal.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_rounded,
              size: 20, color: VarnamalaTheme.peacockTeal),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Only your handle and this avatar are ever shown to other '
              'learners. Your real name, your email address and your Google '
              'photo stay private — a leaderboard should not tell strangers '
              'who you are or how to contact you.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: VarnamalaTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
