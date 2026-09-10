// Dart imports:
import 'dart:math' as math;

// Project imports:
import 'package:words625/core/stable_hash.dart';
import 'package:words625/courses/concept_catalogue.dart';
import 'package:words625/domain/course/course.dart';
import 'package:words625/domain/exercise/generated_course_exercise.dart';
import 'package:words625/domain/exercise/interactive_exercise.dart';

export 'package:words625/domain/exercise/generated_course_exercise.dart';

/// How one word is being tested.
enum VocabularyExerciseKind {
  /// Picture and English label, pick the target-language word.
  pictureToWord,

  /// Target-language word, shown and spoken, pick the picture.
  wordToPicture,

  /// The word spoken and nothing else, pick the picture.
  listenToPicture,

  /// Picture and English label, type the word.
  typeWord,
}

/// Builds a lesson out of bare words and pictures.
///
/// The sentence factory cannot be reused here, because a word course has no
/// sentences to take apart - which is the whole reason it exists. Learners
/// were being asked to assemble sentences from vocabulary nobody had taught
/// them, so First words comes before Basics and teaches the words on their own.
///
/// Mirrors [CourseExerciseFactory]'s shape - `buildStage` returning a
/// [GeneratedLessonStage] - so the engine, the host and the lesson screen do
/// not need to know which kind of course they are playing.
class VocabularyExerciseFactory {
  const VocabularyExerciseFactory();

  /// Distractors per question, including the answer.
  static const int _optionCount = 4;

  /// See it, then say it, then write it.
  static const Map<LessonStageKind, List<VocabularyExerciseKind>> _patterns = {
    // Nothing is asked of the learner yet except to look and connect.
    LessonStageKind.discover: [
      VocabularyExerciseKind.pictureToWord,
      VocabularyExerciseKind.pictureToWord,
      VocabularyExerciseKind.wordToPicture,
      VocabularyExerciseKind.pictureToWord,
      VocabularyExerciseKind.wordToPicture,
      VocabularyExerciseKind.pictureToWord,
    ],
    // The word starts arriving through the ear as well as the eye.
    LessonStageKind.build: [
      VocabularyExerciseKind.wordToPicture,
      VocabularyExerciseKind.listenToPicture,
      VocabularyExerciseKind.pictureToWord,
      VocabularyExerciseKind.wordToPicture,
      VocabularyExerciseKind.listenToPicture,
      VocabularyExerciseKind.wordToPicture,
      VocabularyExerciseKind.pictureToWord,
      VocabularyExerciseKind.wordToPicture,
    ],
    // Half of recall is producing the word from nothing but the picture.
    LessonStageKind.recall: [
      VocabularyExerciseKind.typeWord,
      VocabularyExerciseKind.wordToPicture,
      VocabularyExerciseKind.typeWord,
      VocabularyExerciseKind.listenToPicture,
      VocabularyExerciseKind.typeWord,
      VocabularyExerciseKind.wordToPicture,
    ],
  };

  GeneratedLessonStage buildStage({
    required CourseExerciseContext context,
    required List<VocabularyWord> words,
    required Map<String, Concept> concepts,
    required LessonStageKind stage,
  }) {
    if (words.isEmpty) {
      throw ArgumentError.value(words, 'words', 'must not be empty');
    }

    // A word with no concept has no picture and no English label, so there is
    // nothing to build an exercise out of. The validator rejects these, but a
    // remote course release can still arrive with one.
    final usable = words
        .where((word) => concepts.containsKey(word.concept))
        .toList(growable: false);
    if (usable.isEmpty) {
      throw FormatException(
        'None of ${context.courseId} unit ${context.levelNumber}\'s words '
        'name a concept in concepts.json',
      );
    }

    final pattern = _patterns[stage]!;
    final generated = <GeneratedExercise>[];

    // Each stage starts at a different word so the three passes over one level
    // do not drill them in the same order three times.
    final start = switch (stage) {
      LessonStageKind.discover => 0,
      LessonStageKind.build => usable.length ~/ 3,
      LessonStageKind.recall => (usable.length * 2) ~/ 3,
    };

    for (var position = 0; position < pattern.length; position++) {
      final word = usable[(start + position) % usable.length];
      generated.add(
        generate(
          context: context,
          word: word,
          pool: usable,
          concepts: concepts,
          kind: pattern[position],
          position: position,
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
    required VocabularyWord word,
    required List<VocabularyWord> pool,
    required Map<String, Concept> concepts,
    required VocabularyExerciseKind kind,
    required int position,
  }) {
    final sourceId = _wordId(context, word);
    final id = '$sourceId:${kind.name}:$position';
    final label = _label(word, concepts);

    // Typing is only fair once the learner has seen the word several times, and
    // it is the one kind that cannot fall back to a picture grid.
    final exercise = switch (kind) {
      VocabularyExerciseKind.typeWord => _typeWord(
          word: word,
          label: label,
          concepts: concepts,
          pool: pool,
          id: id,
          adaptiveRetry: _retry(
            context: context,
            word: word,
            pool: pool,
            concepts: concepts,
            sourceId: sourceId,
          ),
        ),
      _ => _pictureChoice(
          context: context,
          word: word,
          label: label,
          pool: pool,
          concepts: concepts,
          kind: kind,
          id: id,
          adaptiveRetry: _retry(
            context: context,
            word: word,
            pool: pool,
            concepts: concepts,
            sourceId: sourceId,
          ),
        ),
    };

    return GeneratedExercise(
      exercise: exercise,
      sourceQuestionId: sourceId,
      sourceSentence: word.word,
      // The shared enum describes sentence interactions; a word exercise is
      // reported as the nearest one so mistake reporting keeps working.
      kind: kind == VocabularyExerciseKind.typeWord
          ? GeneratedExerciseKind.fillBlankText
          : GeneratedExerciseKind.choice,
      usedFallback: false,
    );
  }

  /// A missed word comes back as the easiest form: picture in front of you,
  /// pick the word. Getting it wrong twice should not become a wall.
  InteractiveExercise _retry({
    required CourseExerciseContext context,
    required VocabularyWord word,
    required List<VocabularyWord> pool,
    required Map<String, Concept> concepts,
    required String sourceId,
  }) =>
      _pictureChoice(
        context: context,
        word: word,
        label: _label(word, concepts),
        pool: pool,
        concepts: concepts,
        kind: VocabularyExerciseKind.pictureToWord,
        id: '$sourceId:retry',
        adaptiveRetry: null,
      );

  PictureChoiceExercise _pictureChoice({
    required CourseExerciseContext context,
    required VocabularyWord word,
    required String label,
    required List<VocabularyWord> pool,
    required Map<String, Concept> concepts,
    required VocabularyExerciseKind kind,
    required String id,
    required InteractiveExercise? adaptiveRetry,
  }) {
    final optionsArePictures = kind != VocabularyExerciseKind.pictureToWord;
    final choices = _choices(word: word, pool: pool, id: id);
    final options = <ExerciseOption>[
      for (var index = 0; index < choices.length; index++)
        ExerciseOption(
          id: '$id:o$index',
          text: optionsArePictures
              ? _label(choices[index], concepts)
              : choices[index].word,
          art:
              optionsArePictures ? concepts[choices[index].concept]!.art : null,
        ),
    ];
    final correctIndex = choices.indexWhere(
      (choice) => choice.concept == word.concept,
    );

    return PictureChoiceExercise(
      id: id,
      prompt: switch (kind) {
        VocabularyExerciseKind.pictureToWord => 'Which word is this?',
        VocabularyExerciseKind.wordToPicture => 'Which picture is this?',
        VocabularyExerciseKind.listenToPicture => 'What do you hear?',
        VocabularyExerciseKind.typeWord => 'Type the word',
      },
      promptArt: kind == VocabularyExerciseKind.pictureToWord
          ? concepts[word.concept]!.art
          : null,
      promptWord:
          kind == VocabularyExerciseKind.wordToPicture ? word.word : null,
      promptLanguage: context.language.name,
      promptLabel: kind == VocabularyExerciseKind.pictureToWord ? label : null,
      optionsArePictures: optionsArePictures,
      options: options,
      correctOptionId: '$id:o$correctIndex',
      explanation: '${word.word} - $label',
      adaptiveRetry: adaptiveRetry,
    );
  }

  FillBlankTextExercise _typeWord({
    required VocabularyWord word,
    required String label,
    required Map<String, Concept> concepts,
    required List<VocabularyWord> pool,
    required String id,
    required InteractiveExercise? adaptiveRetry,
  }) =>
      FillBlankTextExercise(
        id: id,
        prompt: 'Type the word',
        // The picture is the prompt, so there is no sentence to sit either
        // side of the blank.
        beforeBlank: '',
        afterBlank: '',
        clue: label,
        clueArt: concepts[word.concept]!.art,
        acceptedAnswers: [word.word],
        // Every other word in the level, so a near miss that is really one of
        // them is refused rather than forgiven.
        dictionary: {
          for (final other in pool) other.word: _label(other, concepts),
        },
        explanation: '${word.word} - $label',
        adaptiveRetry: adaptiveRetry,
      );

  /// The answer plus distractors, in a stable shuffled order.
  ///
  /// Distractors are the level's own other words, so a wrong pick is always a
  /// word the learner is currently being taught rather than a stranger.
  List<VocabularyWord> _choices({
    required VocabularyWord word,
    required List<VocabularyWord> pool,
    required String id,
  }) {
    final random = math.Random(stableHash32(id));
    final others = pool.where((other) => other.concept != word.concept).toList()
      ..shuffle(random);
    return <VocabularyWord>[
      word,
      ...others.take(_optionCount - 1),
    ]..shuffle(math.Random(stableHash32('$id:order')));
  }

  String _label(VocabularyWord word, Map<String, Concept> concepts) =>
      word.gloss ?? concepts[word.concept]?.label ?? word.concept;

  /// Stable across reordering of the JSON, like the sentence factory's ids, so
  /// that a reported mistake keeps pointing at the same word.
  String _wordId(CourseExerciseContext context, VocabularyWord word) =>
      stableContentId(
        '${context.language.name}-${context.courseId}',
        [word.concept, word.word],
      );
}
