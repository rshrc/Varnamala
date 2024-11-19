// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:chiclet/chiclet.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/course_provider.dart';
import 'package:words625/application/language_provider.dart';
import 'package:words625/core/extensions.dart';
import 'package:words625/views/theme.dart';

class ContinueButton extends StatelessWidget {
  final BuildContext context;
  const ContinueButton(this.context, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, CourseProvider>(
      builder: (context, languageState, courseState, child) {
        return ChicletAnimatedButton(
          backgroundColor: primaryColor,
          width: context.width,
          onPressed: () {
            languageState.cacheLanguage();
            courseState.getCourses(languageState.selectedLanguage);
            context.router.back();
          },
          child: const Text(
            'Continue',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
