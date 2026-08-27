// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:words625/service/demo_lesson_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('demo loads a valid local beginner question', () async {
    final service = DemoLessonService(random: Random(7));

    final question = await service.loadRandomQuestion();

    expect(question.language, isNotEmpty);
    expect(question.nativeLanguage, isNotEmpty);
    expect(question.level, 1);
    expect(question.sentence, isNotEmpty);
    expect(question.options, hasLength(greaterThanOrEqualTo(2)));
    expect(question.options, contains(question.correctAnswer));
    expect(question.sentence, isNot(contains('{name}')));
    expect(question.options, everyElement(isNot(contains('{name}'))));
  });
}
