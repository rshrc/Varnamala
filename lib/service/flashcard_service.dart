// Dart imports:
import 'dart:convert';
import 'dart:math' as math;

// Project imports:
import 'package:words625/core/enums.dart';
import 'package:words625/courses/courses.dart';
import 'package:words625/service/locator.dart';

enum FlashcardRating { again, hard, good, easy }

class Flashcard {
  const Flashcard(
      {required this.id, required this.term, required this.meaning});

  final String id;
  final String term;
  final String meaning;
}

class FlashcardProgress {
  const FlashcardProgress({
    required this.dueAt,
    this.intervalDays = 0,
    this.ease = 2.5,
    this.repetitions = 0,
    this.lapses = 0,
  });

  final DateTime dueAt;
  final int intervalDays;
  final double ease;
  final int repetitions;
  final int lapses;

  factory FlashcardProgress.fromJson(Map<String, dynamic> json) {
    return FlashcardProgress(
      dueAt: DateTime.tryParse(json['dueAt'] as String? ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      intervalDays: (json['intervalDays'] as num? ?? 0).toInt(),
      ease: (json['ease'] as num? ?? 2.5).toDouble(),
      repetitions: (json['repetitions'] as num? ?? 0).toInt(),
      lapses: (json['lapses'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'dueAt': dueAt.toUtc().toIso8601String(),
        'intervalDays': intervalDays,
        'ease': ease,
        'repetitions': repetitions,
        'lapses': lapses,
      };
}

class FlashcardStats {
  const FlashcardStats({
    required this.total,
    required this.newCards,
    required this.due,
    required this.learning,
    required this.mastered,
  });

  final int total;
  final int newCards;
  final int due;
  final int learning;
  final int mastered;
}

FlashcardProgress scheduleFlashcardReview({
  FlashcardProgress? current,
  required FlashcardRating rating,
  required DateTime now,
}) {
  final previous = current ?? FlashcardProgress(dueAt: now.toUtc());
  final utcNow = now.toUtc();

  switch (rating) {
    case FlashcardRating.again:
      return FlashcardProgress(
        dueAt: utcNow.add(const Duration(minutes: 10)),
        ease: math.max(1.3, previous.ease - 0.2),
        lapses: previous.lapses + 1,
      );
    case FlashcardRating.hard:
      final interval = previous.intervalDays == 0
          ? 1
          : math.max(1, (previous.intervalDays * 1.2).round());
      return FlashcardProgress(
        dueAt: utcNow.add(Duration(days: interval)),
        intervalDays: interval,
        ease: math.max(1.3, previous.ease - 0.15),
        repetitions: math.max(1, previous.repetitions),
        lapses: previous.lapses,
      );
    case FlashcardRating.good:
      final interval = switch (previous.repetitions) {
        0 => 1,
        1 => 3,
        _ => math.max(1, (previous.intervalDays * previous.ease).round()),
      };
      return FlashcardProgress(
        dueAt: utcNow.add(Duration(days: interval)),
        intervalDays: interval,
        ease: previous.ease,
        repetitions: previous.repetitions + 1,
        lapses: previous.lapses,
      );
    case FlashcardRating.easy:
      final interval = previous.repetitions == 0
          ? 4
          : math.max(
              4,
              (previous.intervalDays * (previous.ease + 0.15)).round(),
            );
      return FlashcardProgress(
        dueAt: utcNow.add(Duration(days: interval)),
        intervalDays: interval,
        ease: math.min(3.2, previous.ease + 0.15),
        repetitions: previous.repetitions + 1,
        lapses: previous.lapses,
      );
  }
}

class FlashcardService {
  FlashcardService(this._prefs, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final AppPrefs _prefs;
  final DateTime Function() _now;
  TargetLanguage? _language;
  Map<String, FlashcardProgress> _progress = {};

  Future<List<Flashcard>> load(TargetLanguage language) async {
    _language = language;
    _progress = _readProgress(language);
    final dictionary = await courseRepository.dictionary(language);
    final cards = dictionary.entries
        .where((entry) =>
            entry.key.trim().isNotEmpty && entry.value.trim().isNotEmpty)
        .map(
          (entry) => Flashcard(
            id: entry.key,
            term: entry.key,
            meaning: entry.value,
          ),
        )
        .toList()
      ..sort((a, b) => a.term.compareTo(b.term));
    return cards;
  }

  FlashcardStats stats(List<Flashcard> cards) {
    final now = _now().toUtc();
    var newCards = 0;
    var due = 0;
    var learning = 0;
    var mastered = 0;

    for (final card in cards) {
      final progress = _progress[card.id];
      if (progress == null) {
        newCards++;
      } else {
        if (!progress.dueAt.isAfter(now)) due++;
        if (progress.repetitions >= 3 && progress.intervalDays >= 21) {
          mastered++;
        } else {
          learning++;
        }
      }
    }

    return FlashcardStats(
      total: cards.length,
      newCards: newCards,
      due: due,
      learning: learning,
      mastered: mastered,
    );
  }

  List<Flashcard> queue(List<Flashcard> cards, {required int limit}) {
    final now = _now().toUtc();
    final due = cards.where((card) {
      final progress = _progress[card.id];
      return progress != null && !progress.dueAt.isAfter(now);
    }).toList()
      ..sort(
          (a, b) => _progress[a.id]!.dueAt.compareTo(_progress[b.id]!.dueAt));

    final fresh = cards
        .where((card) => !_progress.containsKey(card.id))
        .toList()
      ..shuffle(math.Random(now.year * 1000 + now.dayOfYear));

    return [...due, ...fresh].take(limit).toList();
  }

  Future<FlashcardProgress> rate(
    Flashcard card,
    FlashcardRating rating,
  ) async {
    final language = _language;
    if (language == null) throw StateError('Load a flashcard deck first.');
    final next = scheduleFlashcardReview(
      current: _progress[card.id],
      rating: rating,
      now: _now(),
    );
    _progress[card.id] = next;
    await _writeProgress(language);
    return next;
  }

  Future<void> reset(TargetLanguage language) async {
    _progress = {};
    await _prefs.setString(_storageKey(language), '{}');
  }

  Map<String, FlashcardProgress> _readProgress(TargetLanguage language) {
    try {
      final raw = _prefs.preferences
          .getString(_storageKey(language), defaultValue: '{}')
          .getValue();
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (id, value) => MapEntry(
          id,
          FlashcardProgress.fromJson((value as Map).cast<String, dynamic>()),
        ),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeProgress(TargetLanguage language) {
    return _prefs.setString(
      _storageKey(language),
      jsonEncode(
          _progress.map((id, progress) => MapEntry(id, progress.toJson()))),
    );
  }

  String _storageKey(TargetLanguage language) =>
      '${PrefsConstants.flashcardProgressPrefix}${language.name}';
}

extension on DateTime {
  int get dayOfYear => difference(DateTime(year)).inDays + 1;
}
