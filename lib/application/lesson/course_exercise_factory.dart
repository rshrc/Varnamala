// Dart imports:
import 'dart:math' as math;

// Package imports:
import 'package:characters/characters.dart';

// Project imports:
import 'package:words625/core/stable_hash.dart';
import 'package:words625/core/text_normalization.dart';
import 'package:words625/domain/course/course.dart';
import 'package:words625/domain/exercise/generated_course_exercise.dart';
import 'package:words625/domain/exercise/interactive_exercise.dart';

export 'package:words625/domain/exercise/generated_course_exercise.dart';

/// Converts the reviewed v1 course questions into varied interactions without
/// changing JSON or inventing new language content.
class CourseExerciseFactory {
  const CourseExerciseFactory();

  static const Map<LessonStageKind, List<GeneratedExerciseKind>> _patterns = {
    LessonStageKind.discover: [
      GeneratedExerciseKind.choice,
      GeneratedExerciseKind.wordBank,
      GeneratedExerciseKind.choice,
      GeneratedExerciseKind.fillBlankChoice,
      GeneratedExerciseKind.wordBank,
      GeneratedExerciseKind.sentenceOrder,
    ],
    LessonStageKind.build: [
      GeneratedExerciseKind.wordBank,
      GeneratedExerciseKind.sentenceOrder,
      GeneratedExerciseKind.fillBlankChoice,
      GeneratedExerciseKind.wordBank,
      GeneratedExerciseKind.sentenceOrder,
      GeneratedExerciseKind.fillBlankText,
      GeneratedExerciseKind.guessWord,
      GeneratedExerciseKind.choice,
    ],
    LessonStageKind.recall: [
      GeneratedExerciseKind.fillBlankText,
      GeneratedExerciseKind.guessWord,
      GeneratedExerciseKind.sentenceOrder,
      GeneratedExerciseKind.fillBlankText,
      GeneratedExerciseKind.wordBank,
      GeneratedExerciseKind.guessWord,
    ],
  };

  List<GeneratedLessonStage> buildStages({
    required CourseExerciseContext context,
    required List<Question> questions,
  }) =>
      LessonStageKind.values
          .map(
            (stage) => buildStage(
              context: context,
              questions: questions,
              stage: stage,
            ),
          )
          .toList(growable: false);

  GeneratedLessonStage buildStage({
    required CourseExerciseContext context,
    required List<Question> questions,
    required LessonStageKind stage,
  }) {
    if (questions.isEmpty) {
      throw ArgumentError.value(questions, 'questions', 'must not be empty');
    }

    final pattern = _patterns[stage]!;
    final count = pattern.length.clamp(1, questions.length);
    final start = switch (stage) {
      LessonStageKind.discover => 0,
      LessonStageKind.build => 3 % questions.length,
      LessonStageKind.recall => 6 % questions.length,
    };
    final generated = <GeneratedExercise>[];

    for (var position = 0; position < count; position++) {
      final question = questions[(start + position) % questions.length];
      generated.add(
        generate(
          context: context,
          question: question,
          preferredKind: pattern[position],
        ),
      );
    }

    return GeneratedLessonStage(
      id: '${context.language.name}:${context.courseId}:'
          'unit-${context.levelNumber}:${stage.name}:'
          'v${context.generationVersion}',
      kind: stage,
      unitNumber: context.levelNumber,
      exercises: List.unmodifiable(generated),
    );
  }

  GeneratedExercise generate({
    required CourseExerciseContext context,
    required Question question,
    required GeneratedExerciseKind preferredKind,
  }) {
    final sourceId = _questionId(context, question);
    final fallbackOrder = _fallbackOrder(preferredKind);

    for (final kind in fallbackOrder) {
      final exercise = _build(
        kind: kind,
        context: context,
        question: question,
        sourceId: sourceId,
        includeRetry: true,
      );
      if (exercise != null) {
        return GeneratedExercise(
          exercise: exercise,
          sourceQuestionId: sourceId,
          sourceSentence: question.sentence ?? '',
          kind: kind,
          usedFallback: kind != preferredKind,
          fallbackReason:
              kind == preferredKind ? null : '${preferredKind.name}_ineligible',
        );
      }
    }

    // Choice is deliberately universal for valid v1 questions, so reaching
    // this point means the source itself is malformed rather than merely
    // unsuitable for generation.
    throw FormatException('Question $sourceId has no playable representation');
  }

  String _questionId(CourseExerciseContext context, Question question) =>
      stableContentId(
        '${context.language.name}-${context.courseId}',
        [question.type, question.sentence, question.correctAnswer],
      );

  List<GeneratedExerciseKind> _fallbackOrder(
    GeneratedExerciseKind preferred,
  ) =>
      switch (preferred) {
        GeneratedExerciseKind.choice => const [GeneratedExerciseKind.choice],
        GeneratedExerciseKind.wordBank => const [
            GeneratedExerciseKind.wordBank,
            GeneratedExerciseKind.choice,
          ],
        GeneratedExerciseKind.sentenceOrder => const [
            GeneratedExerciseKind.sentenceOrder,
            GeneratedExerciseKind.wordBank,
            GeneratedExerciseKind.choice,
          ],
        GeneratedExerciseKind.fillBlankChoice => const [
            GeneratedExerciseKind.fillBlankChoice,
            GeneratedExerciseKind.fillBlankText,
            GeneratedExerciseKind.wordBank,
            GeneratedExerciseKind.choice,
          ],
        GeneratedExerciseKind.fillBlankText => const [
            GeneratedExerciseKind.fillBlankText,
            GeneratedExerciseKind.wordBank,
            GeneratedExerciseKind.sentenceOrder,
            GeneratedExerciseKind.choice,
          ],
        GeneratedExerciseKind.guessWord => const [
            GeneratedExerciseKind.guessWord,
            GeneratedExerciseKind.fillBlankText,
            GeneratedExerciseKind.wordBank,
            GeneratedExerciseKind.choice,
          ],
      };

  InteractiveExercise? _build({
    required GeneratedExerciseKind kind,
    required CourseExerciseContext context,
    required Question question,
    required String sourceId,
    required bool includeRetry,
  }) {
    final target = _targetAnswer(question);
    final clue = _learnerClue(question);
    final id = '$sourceId:${kind.name}';
    final retry = includeRetry
        ? _buildRetry(
            baseKind: kind,
            context: context,
            question: question,
            sourceId: sourceId,
          )
        : null;

    return switch (kind) {
      GeneratedExerciseKind.choice => _choice(
          question: question,
          id: id,
          adaptiveRetry: retry,
        ),
      GeneratedExerciseKind.wordBank => _wordBank(
          target: target,
          clue: clue,
          id: id,
          adaptiveRetry: retry,
        ),
      GeneratedExerciseKind.sentenceOrder => _sentenceOrder(
          target: target,
          clue: clue,
          id: id,
          adaptiveRetry: retry,
        ),
      GeneratedExerciseKind.fillBlankChoice => _fillBlankChoice(
          question: question,
          clue: clue,
          id: id,
          adaptiveRetry: retry,
        ),
      GeneratedExerciseKind.fillBlankText => _fillBlankText(
          target: target,
          clue: clue,
          dictionary: context.dictionary,
          id: id,
          adaptiveRetry: retry,
        ),
      GeneratedExerciseKind.guessWord => _guessWord(
          target: target,
          dictionary: context.dictionary,
          id: id,
          adaptiveRetry: retry,
        ),
    };
  }

  InteractiveExercise? _buildRetry({
    required GeneratedExerciseKind baseKind,
    required CourseExerciseContext context,
    required Question question,
    required String sourceId,
  }) {
    final preferred = switch (baseKind) {
      GeneratedExerciseKind.choice => GeneratedExerciseKind.wordBank,
      GeneratedExerciseKind.wordBank => GeneratedExerciseKind.choice,
      GeneratedExerciseKind.sentenceOrder => GeneratedExerciseKind.wordBank,
      GeneratedExerciseKind.fillBlankChoice => GeneratedExerciseKind.wordBank,
      GeneratedExerciseKind.fillBlankText => GeneratedExerciseKind.wordBank,
      GeneratedExerciseKind.guessWord => GeneratedExerciseKind.wordBank,
    };

    return _build(
          kind: preferred,
          context: context,
          question: question,
          sourceId: '$sourceId:retry',
          includeRetry: false,
        ) ??
        _build(
          kind: GeneratedExerciseKind.choice,
          context: context,
          question: question,
          sourceId: '$sourceId:retry',
          includeRetry: false,
        );
  }

  ChoiceExercise? _choice({
    required Question question,
    required String id,
    required InteractiveExercise? adaptiveRetry,
  }) {
    final options = question.options;
    final correct = question.correctAnswer;
    final sentence = question.sentence;
    if (options == null ||
        options.isEmpty ||
        correct == null ||
        sentence == null ||
        !options.contains(correct)) {
      return null;
    }
    final exerciseOptions = <ExerciseOption>[
      for (var index = 0; index < options.length; index++)
        ExerciseOption(id: '$id:o$index', text: options[index]),
    ]..shuffle(math.Random(stableHash32(id)));
    final correctIndex = options.indexOf(correct);
    return ChoiceExercise(
      id: id,
      prompt: question.prompt ?? 'Choose the correct answer',
      sentence: sentence,
      sentenceIsTargetLanguage: question.sentenceIsTargetLanguage ?? true,
      options: exerciseOptions,
      correctOptionId: '$id:o$correctIndex',
      explanation: _learnerClue(question),
      adaptiveRetry: adaptiveRetry,
    );
  }

  WordBankExercise? _wordBank({
    required String target,
    required String clue,
    required String id,
    required InteractiveExercise? adaptiveRetry,
  }) {
    final words = _wordTokens(target);
    if (words.length < 2 || words.length > 18 || clue.isEmpty) return null;
    final tokens = [
      for (var index = 0; index < words.length; index++)
        ExerciseToken(id: '$id:t$index', text: words[index]),
    ];
    return WordBankExercise(
      id: id,
      prompt: 'Build the sentence',
      sourceText: clue,
      tokens: tokens,
      acceptedOrders: [tokens.map((token) => token.id).toList()],
      explanation: '$target — $clue',
      adaptiveRetry: adaptiveRetry,
    );
  }

  SentenceOrderExercise? _sentenceOrder({
    required String target,
    required String clue,
    required String id,
    required InteractiveExercise? adaptiveRetry,
  }) {
    final words = _wordTokens(target);
    if (words.length < 3 || words.length > 18 || clue.isEmpty) return null;
    final tokens = [
      for (var index = 0; index < words.length; index++)
        ExerciseToken(id: '$id:t$index', text: words[index]),
    ];
    return SentenceOrderExercise(
      id: id,
      prompt: 'Put the words in order',
      translation: clue,
      tokens: tokens,
      acceptedOrders: [tokens.map((token) => token.id).toList()],
      explanation: '$target — $clue',
      adaptiveRetry: adaptiveRetry,
    );
  }

  FillBlankTextExercise? _fillBlankText({
    required String target,
    required String clue,
    required Map<String, String> dictionary,
    required String id,
    required InteractiveExercise? adaptiveRetry,
  }) {
    final blank = _blankCandidate(target, dictionary);
    if (blank == null || clue.isEmpty) return null;
    return FillBlankTextExercise(
      id: id,
      prompt: 'Type the missing word',
      beforeBlank: blank.before,
      afterBlank: blank.after,
      clue: clue,
      acceptedAnswers: [blank.answer],
      explanation: '${blank.answer} — ${blank.gloss}',
      adaptiveRetry: adaptiveRetry,
    );
  }

  FillBlankChoiceExercise? _fillBlankChoice({
    required Question question,
    required String clue,
    required String id,
    required InteractiveExercise? adaptiveRetry,
  }) {
    if (question.type != 'multiple_choice' || clue.isEmpty) return null;
    final options = question.options;
    final correct = question.correctAnswer;
    if (options == null || correct == null || options.length < 3) return null;
    final contrast = _contrastSet(options, correct);
    if (contrast == null) return null;
    final exerciseOptions = <ExerciseOption>[
      for (var index = 0; index < contrast.answers.length; index++)
        ExerciseOption(id: '$id:o$index', text: contrast.answers[index]),
    ]..shuffle(math.Random(stableHash32(id)));
    return FillBlankChoiceExercise(
      id: id,
      prompt: 'Choose the missing word',
      beforeBlank: contrast.before,
      afterBlank: contrast.after,
      clue: clue,
      options: exerciseOptions,
      correctOptionId: '$id:o${contrast.correctIndex}',
      explanation: '${contrast.answers[contrast.correctIndex]} completes the '
          'reviewed answer.',
      adaptiveRetry: adaptiveRetry,
    );
  }

  GuessWordExercise? _guessWord({
    required String target,
    required Map<String, String> dictionary,
    required String id,
    required InteractiveExercise? adaptiveRetry,
  }) {
    final candidate = _blankCandidate(target, dictionary);
    if (candidate == null) return null;
    final graphemes = candidate.answer.characters.toList(growable: false);
    if (graphemes.length < 2 || graphemes.length > 12) return null;
    final tokens = [
      for (var index = 0; index < graphemes.length; index++)
        ExerciseToken(id: '$id:t$index', text: graphemes[index]),
    ];
    return GuessWordExercise(
      id: id,
      prompt: 'Guess the word',
      clue: candidate.gloss,
      tokens: tokens,
      acceptedOrders: [tokens.map((token) => token.id).toList()],
      explanation: '${candidate.answer} — ${candidate.gloss}',
      adaptiveRetry: adaptiveRetry,
    );
  }

  String _targetAnswer(Question question) => question.type == 'translate'
      ? question.sentence?.trim() ?? ''
      : question.correctAnswer?.trim() ?? '';

  String _learnerClue(Question question) => question.type == 'translate'
      ? question.correctAnswer?.trim() ?? ''
      : question.translatedSentence?.trim() ?? '';

  List<String> _wordTokens(String value) => value
      .trim()
      .split(RegExp(r'\s+'))
      .map(exerciseTokenText)
      .where((token) => token.isNotEmpty)
      .toList(growable: false);

  _BlankCandidate? _blankCandidate(
    String target,
    Map<String, String> dictionary,
  ) {
    final matches = RegExp(r"[A-Za-z0-9]+(?:['-][A-Za-z0-9]+)*")
        .allMatches(target)
        .toList();
    final normalizedCounts = <String, int>{};
    for (final match in matches) {
      final normalized = normalizeWord(match.group(0)!);
      normalizedCounts[normalized] = (normalizedCounts[normalized] ?? 0) + 1;
    }

    final candidates = <_BlankCandidate>[];
    for (final match in matches) {
      final answer = match.group(0)!;
      final normalized = normalizeWord(answer);
      final gloss = dictionary[normalized]?.trim();
      if (normalized.isEmpty ||
          gloss == null ||
          gloss.isEmpty ||
          gloss == 'your name' ||
          (normalizedCounts[normalized] ?? 0) != 1) {
        continue;
      }
      candidates.add(
        _BlankCandidate(
          before: target.substring(0, match.start).trimRight(),
          after: target.substring(match.end).trimLeft(),
          answer: answer,
          gloss: gloss,
        ),
      );
    }
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      final length = b.answer.length.compareTo(a.answer.length);
      return length != 0 ? length : a.answer.compareTo(b.answer);
    });
    return candidates.first;
  }

  _ContrastSet? _contrastSet(List<String> options, String correct) {
    final tokenized = options
        .map((option) => RegExp(r"[A-Za-z0-9]+(?:['-][A-Za-z0-9]+)*")
            .allMatches(option)
            .toList())
        .toList();
    if (tokenized.any((tokens) => tokens.isEmpty) ||
        tokenized.any((tokens) => tokens.length != tokenized.first.length)) {
      return null;
    }

    final differing = <int>[];
    for (var position = 0; position < tokenized.first.length; position++) {
      final values = tokenized
          .map((tokens) => normalizeWord(tokens[position].group(0)!))
          .toSet();
      if (values.length > 1) differing.add(position);
    }
    if (differing.length != 1) return null;
    final position = differing.single;
    final answers = tokenized
        .map((tokens) => tokens[position].group(0)!)
        .toList(growable: false);
    if (answers.toSet().length != answers.length) return null;
    final correctIndex = options.indexOf(correct);
    if (correctIndex < 0) return null;
    final match = tokenized[correctIndex][position];
    return _ContrastSet(
      before: correct.substring(0, match.start).trimRight(),
      after: correct.substring(match.end).trimLeft(),
      answers: answers,
      correctIndex: correctIndex,
    );
  }
}

class _BlankCandidate {
  const _BlankCandidate({
    required this.before,
    required this.after,
    required this.answer,
    required this.gloss,
  });

  final String before;
  final String after;
  final String answer;
  final String gloss;
}

class _ContrastSet {
  const _ContrastSet({
    required this.before,
    required this.after,
    required this.answers,
    required this.correctIndex,
  });

  final String before;
  final String after;
  final List<String> answers;
  final int correctIndex;
}
