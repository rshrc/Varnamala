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
