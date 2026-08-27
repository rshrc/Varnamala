// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:chiclet/chiclet.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:words625/core/extensions.dart';
import 'package:words625/service/locator.dart';

// Project imports:
import 'package:words625/di/injection.dart'; // for getIt
import 'package:words625/routing/routing.gr.dart'; // for navigation after logout

class LogoutButton extends StatelessWidget {
  const LogoutButton({Key? key}) : super(key: key);

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = getIt<AppPrefs>().preferences;
    // Account state is removed without discarding device-level choices such as
    // dark mode and the local splash-demo count.
    await prefs.remove(PrefsConstants.authUser);

    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;
    context.router.replace(const SplashRoute());
  }

  @override
  Widget build(BuildContext context) {
    return ChicletOutlinedAnimatedButton(
      width: context.width * 0.8,
      borderColor: Colors.redAccent,
      onPressed: () => _handleLogout(context),
      child: const Text(
        'Logout',
        style: TextStyle(
          fontSize: 18,
          color: Colors.redAccent,
        ),
      ),
    );
  }
}
