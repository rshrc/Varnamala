import 'package:flutter_test/flutter_test.dart';
import 'package:words625/views/courses/course_tree.dart';

void main() {
  test('unlock override opens future courses without changing current progress',
      () {
    expect(
      pathCourseIsLocked(
        courseIndex: 8,
        currentIndex: 2,
        unlockAll: true,
      ),
      isFalse,
    );
  });

  test('turning override off restores locks from the current progress', () {
    expect(
      pathCourseIsLocked(
        courseIndex: 1,
        currentIndex: 2,
        unlockAll: false,
      ),
      isFalse,
    );
    expect(
      pathCourseIsLocked(
        courseIndex: 3,
        currentIndex: 2,
        unlockAll: false,
      ),
      isTrue,
    );
  });
}
