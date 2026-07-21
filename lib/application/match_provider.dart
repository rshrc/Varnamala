// Dart imports:
import 'dart:async';
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:words625/application/audio_controller.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/core/extensions.dart';
import 'package:words625/courses/alphabets/resource.dart';
import 'package:words625/courses/courses.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/match_levels.dart';
import 'package:words625/service/locator.dart';

/// What the learner is matching.
enum MatchMode {
  /// English meaning against the romanized word.
  words,

  /// Romanized sound against the letter in the language's own script.
  alphabet;

  String get title => this == MatchMode.words ? 'Word Match' : 'Letter Match';

  String get blurb => this == MatchMode.words
      ? 'Pair each word with its meaning.'
      : 'Pair each letter with its sound.';
}

/// One thing to match: a prompt on the left, its answer on the right.
@immutable
class MatchPair {
  const MatchPair(this.prompt, this.answer);

  final String prompt;
  final String answer;
}

@injectable
class MatchProvider extends ChangeNotifier {
  MatchProvider(this._audioController);

  final AudioController _audioController;
  final Random _random = Random();

  // ---- tuning -------------------------------------------------------------

  /// Pairs visible at once. Small enough to scan without scrolling.
  static const int boardSize = 6;

  /// Matches needed to clear a round and bank more time.
  static const int matchesPerRound = 8;

  static const int startingSeconds = 60;

  /// A wrong pair costs time — the pressure is what makes it a game.
  static const int missPenaltySeconds = 3;

  /// Time for clearing a round, shrinking as rounds go by so the run always
  /// ends eventually however good you are.
  int get _roundBonusSeconds => max(5, 18 - (round * 2));

  /// How many of the (difficulty-sorted) pairs are in play. Widens each round,
  /// which pulls in longer and rarer words without ever dropping the easy ones.
  int get _poolSize => min(_deck.length, 24 + (round * 18));

  // ---- state --------------------------------------------------------------

  MatchMode mode = MatchMode.words;

  List<String> prompts = [];
  List<String> answers = [];
  Map<String, String> pairsInPlay = {};
  Set<String> matchedPrompts = {};
  Set<String> matchedAnswers = {};

  String? selectedPrompt;
  String? selectedAnswer;

  int secondsRemaining = startingSeconds;
  int score = 0;
  int round = 0;
  int combo = 0;
  int bestCombo = 0;
  int matchesThisRound = 0;
  int totalMatches = 0;
  bool isGameOver = false;
  bool isReady = false;

  /// Bumped so the view can fire a one-shot effect without us holding widgets.
  int matchPulse = 0;
  int missPulse = 0;
  int roundPulse = 0;

  /// Points the last match was worth, for the floating score.
  int lastMatchPoints = 0;

  List<MatchPair> _deck = const [];
  Timer? _timer;

  /// Every third match in a row raises the multiplier, up to 5x.
  int get multiplier => min(5, 1 + (combo ~/ 3));

  bool get isRunningLow => secondsRemaining <= 10;

  // ---- lifecycle ----------------------------------------------------------

  void start(MatchMode mode) {
    this.mode = mode;
    _deck = _buildDeck(mode);

    prompts = [];
    answers = [];
    pairsInPlay = {};
    matchedPrompts = {};
    matchedAnswers = {};
    selectedPrompt = null;
    selectedAnswer = null;
    secondsRemaining = startingSeconds;
    score = 0;
    round = 0;
    combo = 0;
    bestCombo = 0;
    matchesThisRound = 0;
    totalMatches = 0;
    isGameOver = false;
    isReady = _deck.length >= boardSize;

    if (isReady) _dealBoard();
    notifyListeners();
    if (isReady) _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsRemaining > 0) {
        secondsRemaining--;
        notifyListeners();
      } else {
        _endGame();
      }
    });
  }

  void _endGame() {
    _timer?.cancel();
    isGameOver = true;
    notifyListeners();
  }

  // ---- play ---------------------------------------------------------------

  void selectPrompt(String prompt) {
    if (isGameOver || matchedPrompts.contains(prompt)) return;
    selectedPrompt = selectedPrompt == prompt ? null : prompt;
    _resolve();
  }

  void selectAnswer(String answer) {
    if (isGameOver) return;
    selectedAnswer = selectedAnswer == answer ? null : answer;
    _resolve();
  }

  Future<void> _resolve() async {
    notifyListeners();
    final prompt = selectedPrompt;
    final answer = selectedAnswer;
    if (prompt == null || answer == null) return;

    if (pairsInPlay[prompt] == answer) {
      combo++;
      bestCombo = max(bestCombo, combo);
      lastMatchPoints = 10 * multiplier;
      score += lastMatchPoints;
      matchesThisRound++;
      totalMatches++;
      matchPulse++;
      matchedPrompts.add(prompt);
      matchedAnswers.add(answer);
      _audioController.playRandomLevelUpSound();
      notifyListeners();

      // Hold the green "got it" state long enough to register before the tile
      // animates out and its replacement animates in.
      await Future<void>.delayed(const Duration(milliseconds: 420));

      selectedPrompt = null;
      selectedAnswer = null;
      matchedPrompts.remove(prompt);
      matchedAnswers.remove(answer);
      _replace(prompt, answer);

      if (matchesThisRound >= matchesPerRound) _clearRound();
      notifyListeners();
    } else {
      combo = 0;
      missPulse++;
      secondsRemaining = max(0, secondsRemaining - missPenaltySeconds);
      _audioController.playRandomErrorSound();
      notifyListeners();

      await Future<void>.delayed(const Duration(milliseconds: 260));
      selectedPrompt = null;
      selectedAnswer = null;
      if (secondsRemaining == 0) {
        _endGame();
      } else {
        notifyListeners();
      }
    }
  }

  void _clearRound() {
    secondsRemaining += _roundBonusSeconds;
    round++;
    matchesThisRound = 0;
    roundPulse++;
  }

  // ---- board --------------------------------------------------------------

  void _dealBoard() {
    pairsInPlay = {};
    for (var i = 0; i < boardSize; i++) {
      final pair = _drawPair();
      if (pair == null) break;
      pairsInPlay[pair.prompt] = pair.answer;
    }
    prompts = pairsInPlay.keys.toList()..shuffle(_random);
    answers = pairsInPlay.values.toList()..shuffle(_random);
  }

  /// Swaps the cleared pair out **in place**.
  ///
  /// Reshuffling both columns after every match would move all twelve tiles, so
  /// nothing could animate and the learner would lose their place mid-scan.
  /// Only the two cleared slots change; the rest hold still.
  void _replace(String prompt, String answer) {
    final promptSlot = prompts.indexOf(prompt);
    final answerSlot = answers.indexOf(answer);
    pairsInPlay.remove(prompt);

    final pair = _drawPair();
    if (pair == null) {
      if (promptSlot >= 0) prompts.removeAt(promptSlot);
      if (answerSlot >= 0) answers.removeAt(answerSlot);
      return;
    }

    pairsInPlay[pair.prompt] = pair.answer;
    if (promptSlot >= 0) prompts[promptSlot] = pair.prompt;
    if (answerSlot >= 0) answers[answerSlot] = pair.answer;

    // The columns were dealt independently, so a replacement normally lands on
    // two different rows. When it does not, the new pair would sit side by side
    // and give itself away — so bump it to another row.
    if (promptSlot == answerSlot && answers.length > 1) {
      final other = (answerSlot + 1 + _random.nextInt(answers.length - 1)) %
          answers.length;
      final swapped = answers[other];
      answers[other] = answers[answerSlot];
      answers[answerSlot] = swapped;
    }
  }

  /// Draws from the front of the difficulty-sorted deck, within a window that
  /// widens as the run goes on.
  MatchPair? _drawPair() {
    final pool = _deck.take(_poolSize).where((pair) {
      return !pairsInPlay.containsKey(pair.prompt) &&
          !pairsInPlay.containsValue(pair.answer);
    }).toList(growable: false);

    if (pool.isEmpty) return null;
    return pool[_random.nextInt(pool.length)];
  }

  // ---- decks --------------------------------------------------------------

  TargetLanguage get _language =>
      getIt<AppPrefs>().currentLanguage.getValue().getEnumValue();

  List<MatchPair> _buildDeck(MatchMode mode) =>
      mode == MatchMode.words ? _wordDeck() : _alphabetDeck();

  /// Prefers the language's full lesson dictionary — a couple of thousand words
  /// that can actually get harder — and falls back to the small starter list if
  /// no course has been opened yet this session.
  List<MatchPair> _wordDeck() {
    final dictionary = courseRepository.activeDictionary;
    final pairs = <MatchPair>[];
    final seenGlosses = <String>{};
    final seenWords = <String>{};

    if (dictionary != null && dictionary.isNotEmpty) {
      for (final entry in dictionary.entries) {
        final word = entry.key;
        final gloss = entry.value.trim();
        if (!_isGoodGloss(gloss)) continue;
        if (!seenGlosses.add(gloss.toLowerCase())) continue;
        if (!seenWords.add(word.toLowerCase())) continue;
        pairs.add(MatchPair(gloss, word));
      }
    }

    if (pairs.length < boardSize) {
      pairs.clear();
      seenGlosses.clear();
      seenWords.clear();
      for (final entry in (wordsMap[_language] ?? const {}).entries) {
        if (!seenGlosses.add(entry.key.toLowerCase())) continue;
        if (!seenWords.add(entry.value.toLowerCase())) continue;
        pairs.add(MatchPair(entry.key, entry.value));
      }
    }

    pairs.sort((a, b) => _difficulty(a).compareTo(_difficulty(b)));
    return pairs;
  }

  /// A gloss has to work as a tile: short, plain, and not a grammar note like
  /// "(question marker)".
  bool _isGoodGloss(String gloss) {
    if (gloss.isEmpty || gloss.length > 20) return false;
    if (gloss.contains('(') || gloss.contains('/')) return false;
    return gloss.split(' ').length <= 2;
  }

  /// Short common words first, longer and wordier ones later.
  int _difficulty(MatchPair pair) =>
      pair.answer.length + (pair.prompt.split(' ').length * 3);

  /// Letters in teaching order, which is already easiest-first. Sounds shared by
  /// more than one letter are dropped — with two tiles reading "ta" there would
  /// be no right answer.
  List<MatchPair> _alphabetDeck() {
    final sounds = getLanguageSounds(_language);
    final bySound = <String, String>{};
    final ambiguous = <String>{};

    for (final entry in sounds.entries) {
      final sound = entry.value.trim();
      if (sound.isEmpty || sound.contains('(')) continue;
      if (bySound.containsKey(sound)) {
        ambiguous.add(sound);
        continue;
      }
      bySound[sound] = entry.key;
    }
    for (final sound in ambiguous) {
      bySound.remove(sound);
    }

    // Prompt is the sound, answer is the letter — the same shape as word mode,
    // where the left column is what you already know and the right column is
    // the language you are learning.
    return [
      for (final entry in bySound.entries) MatchPair(entry.key, entry.value),
    ];
  }
}
