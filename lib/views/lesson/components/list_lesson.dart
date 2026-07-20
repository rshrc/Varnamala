// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/level_provider.dart';
import 'package:words625/courses/word_dictionary.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/domain/course/course.dart';
import 'package:words625/views/lesson/lesson_screen.dart';
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
                        ? VarnamalaTheme.peacockTurquoise
                            .withValues(alpha: 0.08)
                        : VarnamalaTheme.error.withValues(alpha: 0.06),
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
                                ? VarnamalaTheme.peacockTeal
                                : VarnamalaTheme.error,
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
                                  ? VarnamalaTheme.peacockTeal
                                  : VarnamalaTheme.error,
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
                              ?.copyWith(color: VarnamalaTheme.textHint),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${lessonProvider.currentQuestion?.correctAnswer}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: VarnamalaTheme.error,
                          ),
                        ),
                      ] else if (lessonProvider
                              .currentQuestion?.translatedSentence !=
                          null) ...[
                        const SizedBox(height: 12),
                        Text(
                          lessonProvider
                                  .currentQuestion?.translatedSentence ??
                              "",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: VarnamalaTheme.peacockTeal,
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
                    prompt:
                        lessonProvider.currentQuestion?.prompt ?? "--"),
                const SizedBox(height: 12),
                QuestionRow(question: lessonProvider.currentQuestion),
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
                                  isCorrect:
                                      lessonProvider.isAnswerCorrect,
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
  const QuestionRow({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SpeakButton(sentence: question?.sentence ?? "--"),
          const SizedBox(width: 14),
          Flexible(
            child: question?.sentenceIsTargetLanguage ?? false
                ? RichText(
                    text: TextSpan(
                      children: _buildTextSpans(context),
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

  List<TextSpan> _buildTextSpans(BuildContext context) {
    final words = question?.sentence?.split(' ') ?? [];
    final baseStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          height: 1.4,
        );

    return words.map((word) {
      final meaning = getWordMeaning(word);

      return TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Tooltip(
              key: ValueKey('gloss-$word'),
              triggerMode: TooltipTriggerMode.tap,
              enableFeedback: true,
              // Every target-language word is tappable. A word with no gloss
              // says so rather than opening an empty box.
              message: meaning ?? 'No meaning yet',
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: meaning == null
                    ? VarnamalaTheme.textHint
                    : VarnamalaTheme.peacockTeal,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                word,
                style: baseStyle?.copyWith(
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dotted,
                  decorationThickness: 2,
                  decorationColor:
                      VarnamalaTheme.peacockTeal.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
          const TextSpan(text: ' '),
        ],
      );
    }).toList();
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
    Color textColor = VarnamalaTheme.textPrimary;

    if (lessonState.answerState.isCorrect && isSelected) {
      borderColor = VarnamalaTheme.peacockTurquoise;
      backgroundColor =
          VarnamalaTheme.peacockTurquoise.withValues(alpha: 0.08);
      textColor = VarnamalaTheme.peacockTeal;
    } else if (lessonState.answerState == AnswerState.incorrect &&
        isSelected) {
      borderColor = VarnamalaTheme.error;
      backgroundColor = VarnamalaTheme.error.withValues(alpha: 0.06);
      textColor = VarnamalaTheme.errorDark;
    } else if (lessonState.answerState == AnswerState.selected &&
        isSelected) {
      borderColor = VarnamalaTheme.peacockTeal;
      backgroundColor = VarnamalaTheme.peacockTeal.withValues(alpha: 0.05);
      textColor = VarnamalaTheme.peacockTeal;
    } else {
      borderColor = const Color(0xFFEEF2F1);
      backgroundColor = Colors.white;
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
          borderRadius:
              BorderRadius.circular(VarnamalaTheme.radiusMedium),
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
  final String sentence;
  const SpeakButton({super.key, required this.sentence});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VarnamalaTheme.peacockTeal,
      borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
      child: InkWell(
        onTap: () => getIt<FlutterTts>().speak(sentence),
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: const Icon(
            Icons.volume_up_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}
