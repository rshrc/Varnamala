import 'package:flutter_test/flutter_test.dart';
import 'package:words625/service/flashcard_service.dart';

void main() {
  final now = DateTime.utc(2026, 8, 27, 10);

  test('again schedules a short retry and records a lapse', () {
    final next = scheduleFlashcardReview(
      rating: FlashcardRating.again,
      now: now,
    );

    expect(next.dueAt, now.add(const Duration(minutes: 10)));
    expect(next.intervalDays, 0);
    expect(next.repetitions, 0);
    expect(next.lapses, 1);
  });

  test('good grows intervals as recall succeeds', () {
    final first = scheduleFlashcardReview(
      rating: FlashcardRating.good,
      now: now,
    );
    final second = scheduleFlashcardReview(
      current: first,
      rating: FlashcardRating.good,
      now: first.dueAt,
    );
    final third = scheduleFlashcardReview(
      current: second,
      rating: FlashcardRating.good,
      now: second.dueAt,
    );

    expect(first.intervalDays, 1);
    expect(second.intervalDays, 3);
    expect(third.intervalDays, greaterThan(second.intervalDays));
    expect(third.repetitions, 3);
  });

  test('easy starts later and increases the ease factor', () {
    final next = scheduleFlashcardReview(
      rating: FlashcardRating.easy,
      now: now,
    );

    expect(next.intervalDays, 4);
    expect(next.dueAt, now.add(const Duration(days: 4)));
    expect(next.ease, greaterThan(2.5));
  });

  test('hard never reduces the interval below one day', () {
    final next = scheduleFlashcardReview(
      current: FlashcardProgress(
        dueAt: now,
        intervalDays: 1,
        repetitions: 1,
      ),
      rating: FlashcardRating.hard,
      now: now,
    );

    expect(next.intervalDays, 1);
    expect(next.repetitions, 1);
  });
}
