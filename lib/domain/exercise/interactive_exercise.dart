// Dart imports:
import 'dart:collection';

sealed class ExerciseResponse {
  const ExerciseResponse();
}

class ChoiceExerciseResponse extends ExerciseResponse {
  const ChoiceExerciseResponse(this.optionId);

  final String optionId;
}

class OrderedExerciseResponse extends ExerciseResponse {
  OrderedExerciseResponse(List<String> tokenIds)
      : tokenIds = UnmodifiableListView(tokenIds);

  final List<String> tokenIds;
}

class TextExerciseResponse extends ExerciseResponse {
  const TextExerciseResponse(this.text);

  final String text;
}

class ExerciseToken {
  const ExerciseToken({required this.id, required this.text});

  final String id;
  final String text;
}

class ExerciseOption {
  const ExerciseOption({required this.id, required this.text});

  final String id;
  final String text;
}

sealed class InteractiveExercise {
  const InteractiveExercise({
    required this.id,
    required this.prompt,
    required this.explanation,
    this.adaptiveRetry,
  });

  final String id;
  final String prompt;
  final String explanation;
  final InteractiveExercise? adaptiveRetry;

  bool isCorrect(ExerciseResponse response);

  String get correctAnswerLabel;
}

class ChoiceExercise extends InteractiveExercise {
  const ChoiceExercise({
    required super.id,
    required super.prompt,
    required super.explanation,
    required this.sentence,
    required this.options,
    required this.correctOptionId,
    this.sentenceIsTargetLanguage = true,
    super.adaptiveRetry,
  });

  final String sentence;
  final bool sentenceIsTargetLanguage;
  final List<ExerciseOption> options;
  final String correctOptionId;

  @override
  bool isCorrect(ExerciseResponse response) =>
      response is ChoiceExerciseResponse &&
      response.optionId == correctOptionId;

  @override
  String get correctAnswerLabel =>
      options.firstWhere((option) => option.id == correctOptionId).text;
}

class WordBankExercise extends InteractiveExercise {
  const WordBankExercise({
    required super.id,
    required super.prompt,
    required super.explanation,
    required this.sourceText,
    required this.tokens,
    required this.acceptedOrders,
    super.adaptiveRetry,
  });

  final String sourceText;
  final List<ExerciseToken> tokens;
  final List<List<String>> acceptedOrders;

  @override
  bool isCorrect(ExerciseResponse response) =>
      response is OrderedExerciseResponse &&
      _matchesAnyOrder(response.tokenIds, acceptedOrders);

  @override
  String get correctAnswerLabel =>
      _tokensForOrder(tokens, acceptedOrders.first).join(' ');
}

class SentenceOrderExercise extends InteractiveExercise {
  const SentenceOrderExercise({
    required super.id,
    required super.prompt,
    required super.explanation,
    required this.translation,
    required this.tokens,
    required this.acceptedOrders,
    super.adaptiveRetry,
  });

  final String translation;
  final List<ExerciseToken> tokens;
  final List<List<String>> acceptedOrders;

  @override
  bool isCorrect(ExerciseResponse response) =>
      response is OrderedExerciseResponse &&
      _matchesAnyOrder(response.tokenIds, acceptedOrders);

  @override
  String get correctAnswerLabel =>
      _tokensForOrder(tokens, acceptedOrders.first).join(' ');
}

class FillBlankChoiceExercise extends InteractiveExercise {
  const FillBlankChoiceExercise({
    required super.id,
    required super.prompt,
    required super.explanation,
    required this.beforeBlank,
    required this.afterBlank,
    required this.clue,
    required this.options,
    required this.correctOptionId,
    super.adaptiveRetry,
  });

  final String beforeBlank;
  final String afterBlank;
  final String clue;
  final List<ExerciseOption> options;
  final String correctOptionId;

  @override
  bool isCorrect(ExerciseResponse response) =>
      response is ChoiceExerciseResponse &&
      response.optionId == correctOptionId;

  @override
  String get correctAnswerLabel =>
      options.firstWhere((option) => option.id == correctOptionId).text;
}

class FillBlankTextExercise extends InteractiveExercise {
  const FillBlankTextExercise({
    required super.id,
    required super.prompt,
    required super.explanation,
    required this.beforeBlank,
    required this.afterBlank,
    required this.clue,
    required this.acceptedAnswers,
    super.adaptiveRetry,
  });

  final String beforeBlank;
  final String afterBlank;
  final String clue;
  final List<String> acceptedAnswers;

  @override
  bool isCorrect(ExerciseResponse response) =>
      response is TextExerciseResponse &&
      acceptedAnswers.any(
        (answer) =>
            normalizeTypedAnswer(answer) == normalizeTypedAnswer(response.text),
      );

  @override
  String get correctAnswerLabel => acceptedAnswers.first;
}

class GuessWordExercise extends InteractiveExercise {
  const GuessWordExercise({
    required super.id,
    required super.prompt,
    required super.explanation,
    required this.clue,
    required this.tokens,
    required this.acceptedOrders,
    this.maxHints = 1,
    super.adaptiveRetry,
  });

  final String clue;
  final List<ExerciseToken> tokens;
  final List<List<String>> acceptedOrders;
  final int maxHints;

  @override
  bool isCorrect(ExerciseResponse response) =>
      response is OrderedExerciseResponse &&
      _matchesAnyOrder(response.tokenIds, acceptedOrders);

  @override
  String get correctAnswerLabel =>
      _tokensForOrder(tokens, acceptedOrders.first).join();
}

String normalizeTypedAnswer(String value) => value
    .trim()
    .replaceAll(RegExp(r'\s+'), ' ')
    .replaceFirst(RegExp(r'[.?!]+$'), '')
    .toLowerCase();

bool _matchesAnyOrder(
  List<String> response,
  List<List<String>> acceptedOrders,
) =>
    acceptedOrders.any(
      (answer) =>
          answer.length == response.length &&
          List.generate(
                  answer.length, (index) => answer[index] == response[index])
              .every((matches) => matches),
    );

List<String> _tokensForOrder(
  List<ExerciseToken> tokens,
  List<String> order,
) {
  final byId = {for (final token in tokens) token.id: token.text};
  return order.map((id) => byId[id] ?? id).toList(growable: false);
}
