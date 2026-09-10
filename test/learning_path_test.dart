// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:words625/views/courses/course_tree.dart';

void main() {
  test('unlock override opens future courses without changing current progress',
      () {
    expect(
      pathCourseIsLocked(
        courseIndex: 8,
        unlockedThrough: 2,
        unlockAll: true,
      ),
      isFalse,
    );
  });

  test('turning override off restores locks from the current progress', () {
    expect(
      pathCourseIsLocked(
        courseIndex: 1,
        unlockedThrough: 2,
        unlockAll: false,
      ),
      isFalse,
    );
    expect(
      pathCourseIsLocked(
        courseIndex: 3,
        unlockedThrough: 2,
        unlockAll: false,
      ),
      isTrue,
    );
    expect(
      pathCourseIsLocked(
        courseIndex: 2,
        unlockedThrough: 2,
        unlockAll: false,
      ),
      isFalse,
      reason: 'the course you are on is the one you are meant to play',
    );
  });

  group('pathUnlockedThrough', () {
    test('opens First words and Basics on a fresh install', () {
      // Nothing completed, so the watermark comes from the free-course floor.
      expect(pathUnlockedThrough(unfinished(16)), kFreeCourseCount - 1);
      expect(
        pathCourseIsLocked(
          courseIndex: 1,
          unlockedThrough: pathUnlockedThrough(unfinished(16)),
          unlockAll: false,
        ),
        isFalse,
        reason: 'Basics must be open beside First words, not behind it',
      );
      expect(
        pathCourseIsLocked(
          courseIndex: 2,
          unlockedThrough: pathUnlockedThrough(unfinished(16)),
          unlockAll: false,
        ),
        isTrue,
      );
    });

    test('opens one course past the last one finished', () {
      expect(pathUnlockedThrough(completedThrough(4, of: 16)), 5);
    });

    test('a course inserted at the front does not re-lock finished ones', () {
      // The regression this rule exists for. A learner had finished the first
      // eight courses of the old fifteen; First words is then inserted at the
      // head of the path, unfinished. Reading the watermark off the first
      // unfinished course would put it at 0 and padlock all eight - and
      // because the node checks its lock before its completion, their golden
      // nodes would stop opening at all.
      final courses = [
        false, // the newly inserted First words
        for (var index = 0; index < 8; index++) true,
        for (var index = 0; index < 7; index++) false,
      ];

      final unlockedThrough = pathUnlockedThrough(courses);
      expect(unlockedThrough, 9);

      for (var index = 0; index <= 8; index++) {
        expect(
          pathCourseIsLocked(
            courseIndex: index,
            unlockedThrough: unlockedThrough,
            unlockAll: false,
          ),
          isFalse,
          reason: 'course $index was already finished and must stay open',
        );
      }
      expect(
        pathCourseIsLocked(
          courseIndex: 10,
          unlockedThrough: unlockedThrough,
          unlockAll: false,
        ),
        isTrue,
      );
    });
  });
}

List<bool> unfinished(int count) => List.filled(count, false);

List<bool> completedThrough(int lastIndex, {required int of}) =>
    [for (var index = 0; index < of; index++) index <= lastIndex];
