// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

// Project imports:
import 'package:words625/application/lesson/course_exercise_factory.dart';
import 'package:words625/application/lesson/interactive_course_progress.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/domain/course/course.dart';
import 'package:words625/service/locator.dart';
import 'package:words625/views/courses/components/course_node.dart';
import 'package:words625/views/theme.dart';

void main() {
  const course = Course(
    courseName: 'Basics',
    courseId: 'basics',
    language: 'hindi',
    levels: [
      Level(level: 1, questions: []),
      Level(level: 2, questions: []),
    ],
  );

  late InteractiveCourseProgress progress;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'Basics': 1});
    debugResetStreamingSharedPreferencesInstance();
    final preferences = await StreamingSharedPreferences.instance;
    if (getIt.isRegistered<AppPrefs>()) {
      await getIt.unregister<AppPrefs>();
    }
    getIt.registerSingleton<AppPrefs>(AppPrefs(preferences));
    progress = const InteractiveCourseProgress();
  });

  tearDown(() async {
    if (getIt.isRegistered<AppPrefs>()) {
      await getIt.unregister<AppPrefs>();
    }
  });

  test('legacy authored progress maps to all three completed stages', () {
    final snapshot = progress.read(course);
    expect(snapshot.completedUnits, 1);
    expect(snapshot.completedPlayableLessons, 3);
    expect(snapshot.totalPlayableLessons, 6);
    expect(snapshot.currentUnitIndex, 1);
    expect(snapshot.currentStage, LessonStageKind.discover);
  });

  test('legacy progress is claimed by one language instead of leaking',
      () async {
    expect(progress.read(course).completedUnits, 1);
    await Future<void>.delayed(Duration.zero);

    const kannadaCourse = Course(
      courseName: 'Basics',
      courseId: 'basics',
      language: 'kannada',
      levels: [
        Level(level: 1, questions: []),
        Level(level: 2, questions: []),
      ],
    );
    expect(progress.read(kannadaCourse).completedUnits, 0);
  });

  test('Discover, Build, and Recall advance once and complete the unit',
      () async {
    final discover = await progress.advance(
      course: course,
      expectedUnitIndex: 1,
      expectedStage: LessonStageKind.discover,
      stageWasPerfect: true,
    );
    expect(discover.committed, isTrue);
    expect(discover.unitCompleted, isFalse);
    expect(progress.read(course).currentStage, LessonStageKind.build);

    final duplicate = await progress.advance(
      course: course,
      expectedUnitIndex: 1,
      expectedStage: LessonStageKind.discover,
      stageWasPerfect: true,
    );
    expect(duplicate.committed, isFalse);

    await progress.advance(
      course: course,
      expectedUnitIndex: 1,
      expectedStage: LessonStageKind.build,
      stageWasPerfect: false,
    );
    expect(progress.read(course).currentStage, LessonStageKind.recall);

    final recall = await progress.advance(
      course: course,
      expectedUnitIndex: 1,
      expectedStage: LessonStageKind.recall,
      stageWasPerfect: true,
    );
    expect(recall.committed, isTrue);
    expect(recall.unitCompleted, isTrue);
    expect(recall.courseCompleted, isTrue);
    expect(recall.unitWasPerfect, isFalse);
    expect(progress.read(course).isComplete, isTrue);
    expect(progress.read(course).completedPlayableLessons, 6);
  });

  testWidgets('a completed course node is golden and remains a practice button',
      (tester) async {
    await getIt<AppPrefs>().preferences.setInt(
          'interactiveProgress.v1.hindi.basics.units',
          2,
        );

    await tester.pumpWidget(
      MaterialApp(
        theme: VarnamalaTheme.lightTheme,
        home: const Scaffold(body: Center(child: CourseNode(course))),
      ),
    );

    expect(courseIsComplete(course), isTrue);
    expect(courseProgress(course), 6);
    expect(find.text('6 lessons · practise anytime'), findsOneWidget);
    expect(find.byIcon(Icons.workspace_premium_rounded), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'Basics, course complete. Tap to practise any lesson.',
      ),
      findsOneWidget,
    );
  });
}
