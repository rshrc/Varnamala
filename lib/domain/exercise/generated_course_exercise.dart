import 'package:words625/core/enums.dart';
import 'package:words625/domain/exercise/interactive_exercise.dart';

enum LessonStageKind { discover, build, recall }

extension LessonStageKindX on LessonStageKind {
  String get label => switch (this) {
        LessonStageKind.discover => 'Discover',
        LessonStageKind.build => 'Build',
        LessonStageKind.recall => 'Recall',
      };

  String get description => switch (this) {
        LessonStageKind.discover => 'Meet the words with plenty of support',
        LessonStageKind.build => 'Put phrases and sentences together',
        LessonStageKind.recall => 'Bring the language back from memory',
      };
}

enum GeneratedExerciseKind {
  choice,
  wordBank,
  sentenceOrder,
  fillBlankChoice,
  fillBlankText,
  guessWord,
}

class CourseExerciseContext {
  const CourseExerciseContext({
    required this.language,
    required this.courseId,
    required this.levelNumber,
    required this.dictionary,
    this.generationVersion = 1,
  });

  final TargetLanguage language;
  final String courseId;
  final int levelNumber;
  final Map<String, String> dictionary;
  final int generationVersion;
}

class GeneratedExercise {
  const GeneratedExercise({
    required this.exercise,
    required this.sourceQuestionId,
    required this.sourceSentence,
    required this.kind,
    required this.usedFallback,
    this.fallbackReason,
  });

  final InteractiveExercise exercise;
  final String sourceQuestionId;
  final String sourceSentence;
  final GeneratedExerciseKind kind;
  final bool usedFallback;
  final String? fallbackReason;
}

class GeneratedLessonStage {
  const GeneratedLessonStage({
    required this.id,
    required this.kind,
    required this.unitNumber,
    required this.exercises,
  });

  final String id;
  final LessonStageKind kind;
  final int unitNumber;
  final List<GeneratedExercise> exercises;
}
