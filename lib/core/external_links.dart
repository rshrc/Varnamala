// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:url_launcher/url_launcher.dart';

const String _kPatreonUrl = 'https://www.patreon.com/16665184/join';

final Uri patreonUri = Uri.parse(_kPatreonUrl);

/// Opens the Varnamala Patreon creator page.
///
/// [source] must be a low-cardinality identifier such as `home_app_bar` or
/// `onboarding`. Personal data must never be passed here.
///
/// Returns `true` when the URL was launched successfully.
Future<bool> launchPatreon(BuildContext context,
    {required String source}) async {
  await FirebaseAnalytics.instance.logEvent(
    name: 'support_patreon_click',
    parameters: {'source': source},
  );

  try {
    final launched = await launchUrl(
      patreonUri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      _showLaunchError(context);
    }
    return launched;
  } catch (_) {
    if (context.mounted) {
      _showLaunchError(context);
    }
    return false;
  }
}

void _showLaunchError(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Could not open Patreon. Tap to copy the link.'),
      action: SnackBarAction(
        label: 'Copy',
        onPressed: () => Clipboard.setData(
          const ClipboardData(text: _kPatreonUrl),
        ),
      ),
    ),
  );
}
