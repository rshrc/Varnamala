// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/annotations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/language_provider.dart';
import 'package:words625/core/language_info.dart';
import 'package:words625/views/choose_language/components/app_bar.dart';
import 'package:words625/views/choose_language/components/continue_button.dart';
import 'package:words625/views/theme.dart';

@RoutePage()
class LangChoicePage extends StatelessWidget {
  const LangChoicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChooseLanguageAppbar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),
            Text(
              'What do you want to learn?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'For English speakers',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: VarnamalaTheme.textHint,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: supportedLanguages.length,
                itemBuilder: (context, index) =>
                    LanguageOptionTile(supportedLanguages[index]),
              ),
            ),
            const SizedBox(height: 12),
            ContinueButton(context),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class LanguageOptionTile extends StatelessWidget {
  const LanguageOptionTile(this.info, {Key? key}) : super(key: key);

  final LanguageInfo info;

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageState, _) {
        final isSelected = languageState.selectedLanguage == info.language;

        return GestureDetector(
          onTap: () => languageState.setLanguage(info.language),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: isSelected
                  ? VarnamalaTheme.peacockTeal.withValues(alpha: 0.06)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? VarnamalaTheme.peacockTeal
                    : const Color(0xFFE5E5E5),
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? VarnamalaTheme.peacockTeal.withValues(alpha: 0.18)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: isSelected ? 14 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(info.emblem, width: 52, height: 52),
                  const SizedBox(height: 10),
                  Text(
                    info.englishName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    info.nativeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: VarnamalaTheme.textHint,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    info.region,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: VarnamalaTheme.textHint.withValues(alpha: 0.7),
                      fontSize: 11,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
