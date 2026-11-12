import 'package:freezed_annotation/freezed_annotation.dart';

part 'question.freezed.dart';
part 'question.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
abstract class Question with _$Question {
  const factory Question({
    String? type,
    String? prompt,
    String? sentence,
    bool? sentenceIsTargetLanguage,
    List<String>? options,
    String? correctAnswer,
    String? translatedSentence,
  }) = _Question;

  const Question._();

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  List<String> get shuffledOptions {
    final options = List<String>.from(this.options ?? []);
    options.shuffle();
    return options;
  }
}
