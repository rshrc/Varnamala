// Dart imports:
import 'dart:collection';

// Project imports:
import 'package:words625/core/answer_similarity.dart';

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
  const ExerciseOption({required this.id, required this.text, this.art});

  final String id;
  final String text;

  /// An illustration to show instead of [text], for picture options. [text]
  /// remains the accessible label.
  final String? art;
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

  /// The authored spelling, when the response was accepted despite not
  /// matching it, and `null` otherwise.
  ///
  /// Only typed exercises can produce one. It is a note to show alongside a
  /// correct verdict, never a reason to mark the answer down.
  String? spellingCorrection(ExerciseResponse response) => null;

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
      _matchesAnyTokenOrder(response.tokenIds, acceptedOrders, tokens);

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
      _matchesAnyTokenOrder(response.tokenIds, acceptedOrders, tokens);

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
    this.wordMeaning,
    this.dictionary = const {},
    this.clueArt,
    super.adaptiveRetry,
  });

  final String beforeBlank;
  final String afterBlank;
  final String clue;

  /// A picture to show above the clue, for word courses where the prompt is
  /// the drawing rather than a sentence with a gap in it.
  final String? clueArt;
  final List<String> acceptedAnswers;
  final String? wordMeaning;

  /// The language's glosses, used to refuse a near miss that is really a
  /// different word. See [judgeTypedAnswer].
  final Map<String, String> dictionary;

  TypedAnswerVerdict _judge(ExerciseResponse response) =>
      response is! TextExerciseResponse
          ? TypedAnswerVerdict.wrong
          : judgeTypedAnswer(
              typed: response.text,
              accepted: acceptedAnswers,
              dictionary: dictionary,
            );

  @override
  bool isCorrect(ExerciseResponse response) =>
      _judge(response) != TypedAnswerVerdict.wrong;

  @override
  String? spellingCorrection(ExerciseResponse response) =>
      // An equally valid romanization is not a misspelling, so only a genuine
      // slip earns the note.
      _judge(response) == TypedAnswerVerdict.nearMiss
          ? acceptedAnswers.first
          : null;

  @override
  String get correctAnswerLabel => acceptedAnswers.first;
}

/// A word taught through a picture rather than a translation.
///
/// Covers three interactions with one shape, because they differ only in what
/// is on which side:
///
/// - see the picture, pick the word;
/// - see (and hear) the word, pick the picture;
/// - hear the word alone, pick the picture.
///
/// A word course cannot be built out of the sentence exercises: there is no
/// sentence yet. This is what the learner meets before Basics.
class PictureChoiceExercise extends InteractiveExercise {
  const PictureChoiceExercise({
    required super.id,
    required super.prompt,
    required super.explanation,
    required this.options,
    required this.correctOptionId,
    this.promptArt,
    this.promptWord,
    this.promptLabel,
    this.optionsArePictures = false,
    super.adaptiveRetry,
  });

  /// The picture the learner is being asked about, if any.
  final String? promptArt;

  /// The target-language word, shown and spoken. Null when the learner is
  /// meant to work from the audio alone.
  final String? promptWord;

  /// The English label for [promptArt].
  final String? promptLabel;

  /// Whether the options are drawn as a grid of pictures rather than as a list
  /// of words.
  final bool optionsArePictures;

  final List<ExerciseOption> options;
  final String correctOptionId;

  /// Whether this exercise gives the learner nothing to read - the audio is
  /// the only prompt, so it must play.
  bool get isListening => promptArt == null && promptWord == null;

  @override
  bool isCorrect(ExerciseResponse response) =>
      response is ChoiceExerciseResponse &&
      response.optionId == correctOptionId;

  @override
  String get correctAnswerLabel =>
      options.firstWhere((option) => option.id == correctOptionId).text;
}

String normalizeTypedAnswer(String value) => value
    .trim()
    .replaceAll(RegExp(r'\s+'), ' ')
    .replaceFirst(RegExp(r'[.?!]+$'), '')
    .toLowerCase();

/// Compares the visible token values instead of their internal drag IDs.
///
/// Repeated letters and words must remain separate draggable objects, but a
/// learner cannot distinguish which identical `a` or `amar` token they used.
/// Treating those IDs as semantically different makes visibly correct answers
/// fail validation.
bool _matchesAnyTokenOrder(
  List<String> response,
  List<List<String>> acceptedOrders,
  List<ExerciseToken> tokens,
) {
  final byId = {for (final token in tokens) token.id: token.text};
  final responseValues = _valuesForIds(response, byId);
  if (responseValues == null) return false;

  return acceptedOrders.any((answer) {
    final answerValues = _valuesForIds(answer, byId);
    if (answerValues == null || answerValues.length != responseValues.length) {
      return false;
    }
    for (var index = 0; index < answerValues.length; index++) {
      if (normalizeTypedAnswer(answerValues[index]) !=
          normalizeTypedAnswer(responseValues[index])) {
        return false;
      }
    }
    return true;
  });
}

List<String>? _valuesForIds(
  List<String> ids,
  Map<String, String> valuesById,
) {
  final values = <String>[];
  for (final id in ids) {
    final value = valuesById[id];
    if (value == null) return null;
    values.add(value);
  }
  return values;
}

List<String> _tokensForOrder(
  List<ExerciseToken> tokens,
  List<String> order,
) {
  final byId = {for (final token in tokens) token.id: token.text};
  return order.map((id) => byId[id] ?? id).toList(growable: false);
}
