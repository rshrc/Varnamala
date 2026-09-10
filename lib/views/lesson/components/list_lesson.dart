// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/level_provider.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/domain/course/course.dart';
import 'package:words625/service/speech_service.dart';
import 'package:words625/views/lesson/components/legacy_lesson_controls.dart';
import 'package:words625/views/lesson/exercises/widgets/tappable_gloss_text.dart';
import 'package:words625/views/theme.dart';

class ListLesson extends StatefulWidget {
  final Course course;
  final Question question;

  const ListLesson(this.question, {Key? key, required this.course})
      : super(key: key);

  @override
  State<ListLesson> createState() => _ListLessonState();
}

class _ListLessonState extends State<ListLesson> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setCourse(widget.course);
    });
  }

  setCourse(Course course) {
    final lessonProvider = context.read<LessonProvider>();
    lessonProvider.setCourse(course);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LessonProvider>(
      builder: (context, lessonProvider, child) {
        return Stack(
          children: [
            // Answer feedback panel
            if (lessonProvider.answerState == AnswerState.correct ||
                lessonProvider.answerState == AnswerState.incorrect ||
                lessonProvider.answerState == AnswerState.readyForNext)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: lessonProvider.answerState.isCorrect
                        ? context.appSuccess.withValues(alpha: 0.12)
                        : context.appDanger.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            lessonProvider.answerState.isCorrect
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: lessonProvider.answerState.isCorrect
                                ? context.appSuccess
                                : context.appDanger,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            lessonProvider.answerState.isCorrect
                                ? "Correct!"
                                : "Incorrect",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              color: lessonProvider.answerState.isCorrect
                                  ? context.appSuccess
                                  : context.appDanger,
                            ),
                          ),
                        ],
                      ),
                      if (lessonProvider.answerState.isIncorrect) ...[
                        const SizedBox(height: 12),
                        Text(
                          "Correct answer:",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: context.appTextSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${lessonProvider.currentQuestion?.correctAnswer}",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: context.appDanger,
                          ),
                        ),
                      ] else if (lessonProvider
                              .currentQuestion?.translatedSentence !=
                          null) ...[
                        const SizedBox(height: 12),
                        Text(
                          lessonProvider.currentQuestion?.translatedSentence ??
                              "",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: context.appSuccess,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            // Main content
            Column(
              children: [
                Instruction(
                    prompt: lessonProvider.currentQuestion?.prompt ?? "--"),
                const SizedBox(height: 12),
                QuestionRow(
                  question: lessonProvider.currentQuestion,
                  language: targetLanguageNamed(widget.course.language),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        ...lessonProvider.currentQuestion?.options
                                ?.map((option) {
                              final selectedAnswer =
                                  lessonProvider.selectedAnswer;
                              return GestureDetector(
                                onTap: () {
                                  lessonProvider.selectAnswer(option);
                                },
                                child: ListChoice(
                                  title: option,
                                  isSelected: selectedAnswer == option,
                                  isCorrect: lessonProvider.isAnswerCorrect,
                                ),
                              );
                            }).toList() ??
                            [],
                      ],
                    ),
                  ),
                ),
                const CheckButton(),
              ],
            ),
          ],
        );
      },
    );
  }
}

class Instruction extends StatelessWidget {
  final String prompt;
  const Instruction({super.key, required this.prompt});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
        child: Text(
          prompt,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                height: 1.3,
              ),
        ),
      ),
    );
  }
}

class QuestionRow extends StatelessWidget {
  final Question? question;

  /// So the sentence is read by a voice that speaks it.
  final TargetLanguage? language;

  const QuestionRow({super.key, required this.question, this.language});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SpeakButton(
            sentence: question?.sentence ?? "--",
            language: language,
          ),
          const SizedBox(width: 14),
          Flexible(
            child: question?.sentenceIsTargetLanguage ?? false
                ? TappableGlossText(
                    text: question?.sentence ?? '--',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                  )
                : Text(
                    question?.sentence ?? "--",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                  ),
          ),
        ],
      ),
    );
  }
}

class ListChoice extends StatelessWidget {
  final String title;
  final bool isSelected;
  final bool isCorrect;

  const ListChoice({
    Key? key,
    required this.title,
    this.isSelected = false,
    this.isCorrect = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lessonState = context.watch<LessonProvider>();

    Color borderColor;
    Color backgroundColor;
    Color textColor = context.appTextPrimary;

    if (lessonState.answerState.isCorrect && isSelected) {
      borderColor = context.appSuccess;
      backgroundColor = context.appSuccess.withValues(alpha: 0.12);
      textColor = context.appSuccess;
    } else if (lessonState.answerState == AnswerState.incorrect && isSelected) {
      borderColor = context.appDanger;
      backgroundColor = context.appDanger.withValues(alpha: 0.1);
      textColor = context.appDanger;
    } else if (lessonState.answerState == AnswerState.selected && isSelected) {
      borderColor = context.appInfo;
      backgroundColor = context.appInfo.withValues(alpha: 0.12);
      textColor = context.appInfo;
    } else {
      borderColor = context.appBorder;
      backgroundColor = context.appSurface;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
          border: Border.all(
            width: isSelected ? 2.0 : 1.5,
            color: borderColor,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: textColor,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}

class SpeakButton extends StatelessWidget {
  const SpeakButton({
    super.key,
    required this.sentence,
    this.language,
    this.showSlow = true,
  });

  final String sentence;

  /// The language this text is in. Without it the reader falls back to an
  /// English voice, which is what made every course sound English.
  final TargetLanguage? language;

  /// The slow reader sits beside the normal one rather than hiding behind a
  /// long press: a learner who cannot catch a word needs to *see* that hearing
  /// it again slowly is an option.
  final bool showSlow;

  void _speak(SpeechPace pace) =>
      getIt<SpeechService>().speak(sentence, language: language, pace: pace);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SpeakerButton(
          icon: Icons.volume_up_rounded,
          size: 26,
          tooltip: 'Listen',
          background: context.appInfo,
          onTap: () => _speak(SpeechPace.normal),
        ),
        if (showSlow) ...[
          const SizedBox(width: 8),
          _SpeakerButton(
            // A tortoise is the convention for "same thing, slower", and it
            // survives having no room for a label.
            icon: Icons.slow_motion_video_rounded,
            size: 20,
            tooltip: 'Listen slowly',
            background: context.appInfo.withValues(alpha: 0.16),
            foreground: context.appInfo,
            onTap: () => _speak(SpeechPace.slow),
          ),
        ],
      ],
    );
  }
}

class _SpeakerButton extends StatelessWidget {
  const _SpeakerButton({
    required this.icon,
    required this.size,
    required this.tooltip,
    required this.background,
    required this.onTap,
    this.foreground,
  });

  final IconData icon;
  final double size;
  final String tooltip;
  final Color background;
  final Color? foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(VarnamalaTheme.radiusMedium);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Semantics(
            button: true,
            label: tooltip,
            child: Container(
              // Never below the 44x44 floor, whichever glyph is inside.
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              child: Icon(
                icon,
                // Derived from this button's own fill.
                color: foreground ?? context.appOn(background),
                size: size,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
