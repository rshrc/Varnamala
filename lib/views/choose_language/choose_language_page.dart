// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/annotations.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/language_provider.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/core/extensions.dart';
import 'package:words625/gen/assets.gen.dart';
import 'package:words625/views/choose_language/components/app_bar.dart';
import 'package:words625/views/choose_language/components/continue_button.dart';

// Include path to assets as necessary

@RoutePage()
class LangChoicePage extends StatefulWidget {
  const LangChoicePage({Key? key}) : super(key: key);

  @override
  State<LangChoicePage> createState() => _LangChoicePageState();
}

class _LangChoicePageState extends State<LangChoicePage> {
  final List<Map<String, dynamic>> _languages = [
    {
      'language': TargetLanguage.kannada,
      'flag': Assets.images.karnatakaFlag.path,
      'script': 'ಕನ್ನಡ',
    },
    {
      'language': TargetLanguage.tamil,
      'flag': Assets.images.tamilNaduFlag.path,
      'script': 'தமிழ்',
    },
    {
      'language': TargetLanguage.telugu,
      'flag': Assets.images.telenganaFlag.path,
      'script': 'తెలుగు',
    },
    {
      'language': TargetLanguage.malayalam,
      'flag': Assets.images.malayalamFlag.path,
      'script': 'മലയാളം',
    },
    {
      'language': TargetLanguage.hindi,
      'flag': Assets.images.book.path,
      'script': 'हिन्दी',
    },
    {
      'language': TargetLanguage.bengali,
      'flag': Assets.images.book.path,
      'script': 'বাংলা',
    },
    {
      'language': TargetLanguage.odia,
      'flag': Assets.images.book.path,
      'script': 'ଓଡ଼ିଆ',
    },
    {
      'language': TargetLanguage.nepali,
      'flag': Assets.images.book.path,
      'script': 'नेपाली',
    },
    {
      'language': TargetLanguage.assamese,
      'flag': Assets.images.book.path,
      'script': 'অসমীয়া',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChooseLanguageAppbar(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'What do you want to learn?',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'For English speakers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.2,
                ),
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final lang = _languages[index];
                  return LanguageOptionTile(
                    targetLanguage: lang['language'] as TargetLanguage,
                    flagAsset: lang['flag'] as String,
                    languageScript: lang['script'] as String,
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.bottomCenter,
              child: ContinueButton(context),
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageOptionTile extends StatelessWidget {
  final TargetLanguage targetLanguage;
  final String flagAsset;
  final String languageScript;

  const LanguageOptionTile({
    Key? key,
    required this.targetLanguage,
    required this.flagAsset,
    required this.languageScript,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(builder: (context, languageState, _) {
      bool isSelected = languageState.selectedLanguage == targetLanguage;
      return GestureDetector(
        onTap: () {
          languageState.setLanguage(targetLanguage);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.green : const Color(0xFFE5E5E5),
              width: isSelected ? 3 : 2,
            ),
            boxShadow: [
              if (isSelected)
                const BoxShadow(
                  color: Colors.greenAccent,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                flagAsset,
                width: 60,
                height: 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 12),
              Text(
                targetLanguage.name.toTitleCase,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                languageScript,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
