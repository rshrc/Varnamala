// Flutter imports:
import 'package:flutter/material.dart';

import 'package:words625/views/theme.dart';

class PolicyText extends StatelessWidget {
  const PolicyText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: 14.0,
          height: 1.5,
          color: context.appTextSecondary,
        ),
        children: const <TextSpan>[
          TextSpan(text: 'By signing in to words625, you agree to our '),
          TextSpan(
              text: 'Terms', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: ' and '),
          TextSpan(
              text: '\nPrivacy Policy',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
