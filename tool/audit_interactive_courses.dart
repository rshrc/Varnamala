// Dart imports:
import 'dart:convert';
import 'dart:io';

// Project imports:
import 'package:words625/application/lesson/course_exercise_factory.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/domain/course/course.dart';

Future<void> main() async {
  const factory = CourseExerciseFactory();
  final root = Directory('assets/courses');
  if (!root.existsSync()) {
    stderr.writeln('Run from the Varnamala repository root.');
    exitCode = 2;
    return;
  }

  var totalQuestions = 0;
  var totalLessons = 0;
  var totalFallbacks = 0;
  var failedMixes = 0;

  stdout.writeln(
    'language     questions  lessons  fallbacks  levels below 3 types',
  );
  for (final language in TargetLanguage.values) {
    final directory = Directory('${root.path}/${language.name}');
    final manifest = await _readMap('${directory.path}/manifest.json');
    final dictionary = (await _readMap('${directory.path}/dictionary.json'))
        .map((key, value) => MapEntry(key.toLowerCase(), value as String));
    var questions = 0;
    var lessons = 0;
    var fallbacks = 0;
    var weakMixes = 0;

    for (final courseEntry in (manifest['courses'] as List).cast<Map>()) {
      final courseId = courseEntry['id'] as String;
      final course = await _readMap('${directory.path}/$courseId.json');
      for (final rawLevel in (course['levels'] as List).cast<Map>()) {
        final levelNumber = rawLevel['level'] as int;
        final sourceQuestions = (rawLevel['questions'] as List)
            .cast<Map>()
            .map((raw) => Question.fromJson(raw.cast<String, dynamic>()))
            .toList(growable: false);
        final stages = factory.buildStages(
          context: CourseExerciseContext(
            language: language,
            courseId: courseId,
            levelNumber: levelNumber,
            dictionary: dictionary,
          ),
          questions: sourceQuestions,
        );
        questions += sourceQuestions.length;
        lessons += stages.length;
        for (final stage in stages) {
          fallbacks +=
              stage.exercises.where((exercise) => exercise.usedFallback).length;
          if (stage.exercises.map((exercise) => exercise.kind).toSet().length <
              3) {
            weakMixes += 1;
          }
        }
      }
    }

    totalQuestions += questions;
    totalLessons += lessons;
    totalFallbacks += fallbacks;
    failedMixes += weakMixes;
    stdout.writeln(
      '${language.name.padRight(12)}'
      '${questions.toString().padLeft(9)}  '
      '${lessons.toString().padLeft(7)}  '
      '${fallbacks.toString().padLeft(9)}  '
      '${weakMixes.toString().padLeft(20)}',
    );
  }

  stdout.writeln(
    '\n$totalQuestions source questions -> $totalLessons playable lessons; '
    '$totalFallbacks safe fallbacks; $failedMixes weak mixes.',
  );
  if (totalQuestions != 10530 || failedMixes != 0) exitCode = 1;
}

Future<Map<String, dynamic>> _readMap(String path) async =>
    (jsonDecode(await File(path).readAsString()) as Map)
        .cast<String, dynamic>();
