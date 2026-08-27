// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:words625/core/enums.dart';
import 'package:words625/core/language_info.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/service/flashcard_service.dart';
import 'package:words625/service/locator.dart';
import 'package:words625/service/speech_service.dart';
import 'package:words625/views/theme.dart';

class FlashcardsPage extends StatefulWidget {
  const FlashcardsPage({required this.language, super.key});

  final TargetLanguage language;

  @override
  State<FlashcardsPage> createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> {
  late final FlashcardService _service = FlashcardService(getIt<AppPrefs>());
  List<Flashcard>? _cards;
  List<Flashcard> _queue = [];
  FlashcardStats? _stats;
  Object? _error;
  bool _sessionStarted = false;
  bool _revealed = false;
  bool _reverse = false;
  bool _saving = false;
  int _sessionSize = 20;
  int _index = 0;
  int _reviewed = 0;
  String _query = '';
  final Map<FlashcardRating, int> _ratings = {
    for (final rating in FlashcardRating.values) rating: 0,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _cards = null;
      _error = null;
    });
    try {
      final cards = await _service.load(widget.language);
      if (!mounted) return;
      setState(() {
        _cards = cards;
        _stats = _service.stats(cards);
        _queue = [];
        _sessionStarted = false;
        _index = 0;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  void _startSession() {
    final cards = _cards;
    if (cards == null) return;
    setState(() {
      _queue = _service.queue(cards, limit: _sessionSize);
      _sessionStarted = true;
      _index = 0;
      _reviewed = 0;
      _revealed = false;
      for (final rating in FlashcardRating.values) {
        _ratings[rating] = 0;
      }
    });
  }

  Future<void> _rate(FlashcardRating rating) async {
    if (_saving || _index >= _queue.length) return;
    setState(() => _saving = true);
    try {
      await _service.rate(_queue[_index], rating);
      if (!mounted) return;
      setState(() {
        _ratings[rating] = (_ratings[rating] ?? 0) + 1;
        _reviewed++;
        _index++;
        _revealed = false;
        _stats = _service.stats(_cards!);
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _resetSchedule() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.restart_alt_rounded, color: context.appDanger),
        title: const Text('Reset flashcard schedule?'),
        content: const Text(
          'Every card in this language will become new again. Course and '
          'lesson progress will not be changed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('RESET'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _service.reset(widget.language);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final info = languageInfo(widget.language);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flashcards'),
          actions: [
            IconButton(
              tooltip: 'Reset flashcard schedule',
              onPressed: _cards == null ? null : _resetSchedule,
              icon: Icon(Icons.restart_alt_rounded, color: context.appWarning),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.style_rounded), text: 'Review'),
              Tab(icon: Icon(Icons.search_rounded), text: 'Browse'),
            ],
          ),
        ),
        body: _body(info),
      ),
    );
  }

  Widget _body(LanguageInfo info) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 48, color: context.appDanger),
              const SizedBox(height: 12),
              const Text('Could not load this vocabulary deck.'),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _load, child: const Text('TRY AGAIN')),
            ],
          ),
        ),
      );
    }
    final cards = _cards;
    if (cards == null) {
      return Center(child: CircularProgressIndicator(color: context.appAccent));
    }
    return TabBarView(
      children: [
        _reviewTab(info, cards),
        _browseTab(info, cards),
      ],
    );
  }

  Widget _reviewTab(LanguageInfo info, List<Flashcard> cards) {
    if (!_sessionStarted) return _deckOverview(info);
    if (_queue.isEmpty) return _caughtUp();
    if (_index >= _queue.length) return _sessionSummary();

    final card = _queue[_index];
    final front = _reverse ? card.meaning : card.term;
    final back = _reverse ? card.term : card.meaning;
    final progress = (_index + (_revealed ? 0.5 : 0)) / _queue.length;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(VarnamalaTheme.radiusRound),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 9,
                  backgroundColor: context.appBorder,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${_index + 1}/${_queue.length}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Semantics(
          button: !_revealed,
          label: _revealed ? 'Flashcard answer: $back' : 'Flashcard: $front',
          child: GestureDetector(
            onTap: _revealed ? null : () => setState(() => _revealed = true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              constraints: const BoxConstraints(minHeight: 330),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: _revealed
                    ? Theme.of(context).colorScheme.primaryContainer
                    : context.appSurface,
                borderRadius:
                    BorderRadius.circular(VarnamalaTheme.radiusXLarge),
                border: Border.all(
                  color: _revealed ? context.appAccent : context.appBorder,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.appAccent.withValues(alpha: 0.12),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _reverse ? 'ENGLISH' : info.englishName.toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: _revealed
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : context.appTextSecondary,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    front,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: _revealed
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : context.appTextPrimary,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                  ),
                  const SizedBox(height: 14),
                  IconButton.filledTonal(
                    tooltip: 'Hear ${card.term}',
                    onPressed: () => getIt<SpeechService>().speak(card.term),
                    icon: const Icon(Icons.volume_up_rounded),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    child: _revealed
                        ? Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Divider(),
                              ),
                              Text(
                                back,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          )
                        : const Padding(
                            padding: EdgeInsets.only(top: 28),
                            child: Text('Tap the card to reveal the answer'),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (!_revealed)
          FilledButton.icon(
            onPressed: () => setState(() => _revealed = true),
            icon: const Icon(Icons.visibility_rounded),
            label: const Text('SHOW ANSWER'),
          )
        else
          _ratingButtons(),
      ],
    );
  }

  Widget _deckOverview(LanguageInfo info) {
    final stats = _stats!;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(VarnamalaTheme.radiusXLarge),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome_rounded,
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
              const SizedBox(height: 12),
              Text(
                '${info.englishName} · ${info.nativeName}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Spaced repetition brings difficult words back sooner and '
                'lets familiar words rest longer.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _statsGrid(stats),
        const SizedBox(height: 22),
        Text('Card direction', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(
              value: false,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(info.englishName),
            ),
            const ButtonSegment(
              value: true,
              icon: Icon(Icons.arrow_back_rounded),
              label: Text('English'),
            ),
          ],
          selected: {_reverse},
          onSelectionChanged: (selection) =>
              setState(() => _reverse = selection.first),
        ),
        const SizedBox(height: 20),
        Text('Session size', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [10, 20, 50]
              .map(
                (size) => ChoiceChip(
                  label: Text('$size cards'),
                  selected: _sessionSize == size,
                  onSelected: (_) => setState(() => _sessionSize = size),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _startSession,
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(
            stats.due > 0 ? 'REVIEW ${stats.due} DUE CARDS' : 'LEARN NEW CARDS',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_android_rounded, size: 16, color: context.appInfo),
            const SizedBox(width: 6),
            Text(
              'Review schedules stay on this device.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _statsGrid(FlashcardStats stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.1,
      children: [
        _StatTile('New', stats.newCards, context.appInfo),
        _StatTile('Due', stats.due, context.appDanger),
        _StatTile('Learning', stats.learning, context.appWarning),
        _StatTile('Mastered', stats.mastered, context.appSuccess),
      ],
    );
  }

  Widget _ratingButtons() {
    return Column(
      children: [
        Text(
          'How well did you remember?',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _RatingButton(
              label: 'Again',
              interval: '10m',
              color: context.appDanger,
              onTap: () => _rate(FlashcardRating.again),
              enabled: !_saving,
            ),
            const SizedBox(width: 7),
            _RatingButton(
              label: 'Hard',
              interval: '1d',
              color: context.appWarning,
              onTap: () => _rate(FlashcardRating.hard),
              enabled: !_saving,
            ),
            const SizedBox(width: 7),
            _RatingButton(
              label: 'Good',
              interval: '1–3d',
              color: context.appInfo,
              onTap: () => _rate(FlashcardRating.good),
              enabled: !_saving,
            ),
            const SizedBox(width: 7),
            _RatingButton(
              label: 'Easy',
              interval: '4d+',
              color: context.appSuccess,
              onTap: () => _rate(FlashcardRating.easy),
              enabled: !_saving,
            ),
          ],
        ),
      ],
    );
  }

  Widget _caughtUp() {
    return _CenteredMessage(
      icon: Icons.task_alt_rounded,
      color: context.appSuccess,
      title: 'You are caught up',
      message: 'No cards are due and there are no new cards in this deck.',
      actionLabel: 'BACK TO DECK',
      onAction: () => setState(() => _sessionStarted = false),
    );
  }

  Widget _sessionSummary() {
    return _CenteredMessage(
      icon: Icons.celebration_rounded,
      color: context.appWarning,
      title: 'Session complete',
      message: '$_reviewed cards reviewed · '
          '${_ratings[FlashcardRating.again]} again · '
          '${_ratings[FlashcardRating.good]} good · '
          '${_ratings[FlashcardRating.easy]} easy',
      actionLabel: 'REVIEW MORE',
      onAction: _startSession,
    );
  }

  Widget _browseTab(LanguageInfo info, List<Flashcard> cards) {
    final needle = _query.trim().toLowerCase();
    final filtered = needle.isEmpty
        ? cards
        : cards
            .where((card) =>
                card.term.toLowerCase().contains(needle) ||
                card.meaning.toLowerCase().contains(needle))
            .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search ${info.englishName} or English',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixText: '${filtered.length}/${cards.length}',
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'No matching cards',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : ListView.separated(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final card = filtered[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: context.appSurface,
                        borderRadius:
                            BorderRadius.circular(VarnamalaTheme.radiusMedium),
                        border: Border.all(color: context.appBorder),
                      ),
                      child: ListTile(
                        title: Text(
                          card.term,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(card.meaning),
                        trailing: IconButton(
                          tooltip: 'Hear ${card.term}',
                          onPressed: () =>
                              getIt<SpeechService>().speak(card.term),
                          icon: Icon(Icons.volume_up_rounded,
                              color: context.appInfo),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Text(
            '$value',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: context.appTextSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({
    required this.label,
    required this.interval,
    required this.color,
    required this.onTap,
    required this.enabled,
  });

  final String label;
  final String interval;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: enabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.7)),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        ),
        child: Column(
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(interval, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 62, color: color),
            const SizedBox(height: 18),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 22),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
