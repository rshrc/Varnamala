// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:words625/domain/exercise/interactive_exercise.dart';
import 'package:words625/views/theme.dart';

class InteractiveExerciseHost extends StatelessWidget {
  const InteractiveExerciseHost({
    required this.exercise,
    required this.onResponseChanged,
    super.key,
  });

  final InteractiveExercise exercise;
  final ValueChanged<ExerciseResponse?> onResponseChanged;

  @override
  Widget build(BuildContext context) => switch (exercise) {
        final WordBankExercise item => _TokenBankExerciseView(
            sourceLabel: 'TRANSLATE',
            sourceText: item.sourceText,
            tokens: item.tokens,
            joinWithoutSpaces: false,
            onChanged: onResponseChanged,
          ),
        final SentenceOrderExercise item => _SentenceOrderExerciseView(
            exercise: item,
            onChanged: onResponseChanged,
          ),
        final FillBlankChoiceExercise item => _FillBlankChoiceExerciseView(
            exercise: item,
            onChanged: onResponseChanged,
          ),
        final FillBlankTextExercise item => _FillBlankTextExerciseView(
            exercise: item,
            onChanged: onResponseChanged,
          ),
        final GuessWordExercise item => _TokenBankExerciseView(
            sourceLabel: 'CLUE',
            sourceText: item.clue,
            tokens: item.tokens,
            joinWithoutSpaces: true,
            onChanged: onResponseChanged,
          ),
      };
}

class _TokenBankExerciseView extends StatefulWidget {
  const _TokenBankExerciseView({
    required this.sourceLabel,
    required this.sourceText,
    required this.tokens,
    required this.joinWithoutSpaces,
    required this.onChanged,
  });

  final String sourceLabel;
  final String sourceText;
  final List<ExerciseToken> tokens;
  final bool joinWithoutSpaces;
  final ValueChanged<ExerciseResponse?> onChanged;

  @override
  State<_TokenBankExerciseView> createState() => _TokenBankExerciseViewState();
}

class _TokenBankExerciseViewState extends State<_TokenBankExerciseView> {
  late final Map<String, ExerciseToken> _tokens = {
    for (final token in widget.tokens) token.id: token,
  };
  late final List<String> _available = widget.tokens
      .map((token) => token.id)
      .toList()
    ..shuffle(math.Random(widget.sourceText.hashCode));
  final List<String> _selected = [];
  final Map<String, int> _dropVersions = {};

  void _emit() {
    widget.onChanged(
      _selected.isEmpty ? null : OrderedExerciseResponse(_selected),
    );
  }

  void _moveToAnswer(String id, {String? beforeId}) {
    setState(() {
      _available.remove(id);
      _selected.remove(id);
      final beforeIndex = beforeId == null ? -1 : _selected.indexOf(beforeId);
      if (beforeIndex == -1) {
        _selected.add(id);
      } else {
        _selected.insert(beforeIndex, id);
      }
      _dropVersions[id] = (_dropVersions[id] ?? 0) + 1;
    });
    _emit();
  }

  void _moveToBank(String id) {
    if (!_selected.contains(id)) return;
    setState(() {
      _selected.remove(id);
      _available.add(id);
      _dropVersions[id] = (_dropVersions[id] ?? 0) + 1;
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SourceCard(label: widget.sourceLabel, text: widget.sourceText),
        const SizedBox(height: 22),
        Text(
          widget.joinWithoutSpaces ? 'Build the word' : 'Build your answer',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: context.appTextSecondary,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        DragTarget<String>(
          onWillAcceptWithDetails: (_) => true,
          onAcceptWithDetails: (details) => _moveToAnswer(details.data),
          builder: (context, candidates, _) => AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: const BoxConstraints(minHeight: 92),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: candidates.isEmpty
                  ? context.appElevatedSurface
                  : context.appInfo.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
              border: Border.all(
                color: candidates.isEmpty ? context.appBorder : context.appInfo,
                width: candidates.isEmpty ? 1.5 : 2,
              ),
            ),
            child: _selected.isEmpty
                ? Center(
                    child: Text(
                      'Drag words here · tap also works',
                      style: TextStyle(color: context.appTextSecondary),
                    ),
                  )
                : Wrap(
                    spacing: widget.joinWithoutSpaces ? 3 : 8,
                    runSpacing: 8,
                    children: [
                      for (final id in _selected)
                        DragTarget<String>(
                          key: ValueKey('answer-target-$id'),
                          onWillAcceptWithDetails: (details) =>
                              details.data != id,
                          onAcceptWithDetails: (details) =>
                              _moveToAnswer(details.data, beforeId: id),
                          builder: (context, hovering, _) => AnimatedPadding(
                            duration: const Duration(milliseconds: 120),
                            curve: Curves.easeOutCubic,
                            padding: EdgeInsets.only(
                              left: hovering.isEmpty ? 0 : 10,
                            ),
                            child: _DropSettledToken(
                              key: ValueKey(
                                'answer-$id-${_dropVersions[id] ?? 0}',
                              ),
                              animate: (_dropVersions[id] ?? 0) > 0,
                              child: _DraggableToken(
                                token: _tokens[id]!,
                                selected: hovering.isNotEmpty,
                                onTap: () => _moveToBank(id),
                                semanticHint: 'Tap to return to word bank',
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'WORD BANK',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: context.appTextSecondary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
        ),
        const SizedBox(height: 8),
        DragTarget<String>(
          onWillAcceptWithDetails: (details) =>
              _selected.contains(details.data),
          onAcceptWithDetails: (details) => _moveToBank(details.data),
          builder: (context, candidates, _) => AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: candidates.isEmpty
                  ? Colors.transparent
                  : context.appDanger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final id in _available)
                  _DropSettledToken(
                    key: ValueKey('bank-$id-${_dropVersions[id] ?? 0}'),
                    animate: (_dropVersions[id] ?? 0) > 0,
                    child: _DraggableToken(
                      token: _tokens[id]!,
                      onTap: () => _moveToAnswer(id),
                      semanticHint: 'Tap to add to answer',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SentenceOrderExerciseView extends StatefulWidget {
  const _SentenceOrderExerciseView({
    required this.exercise,
    required this.onChanged,
  });

  final SentenceOrderExercise exercise;
  final ValueChanged<ExerciseResponse?> onChanged;

  @override
  State<_SentenceOrderExerciseView> createState() =>
      _SentenceOrderExerciseViewState();
}

class _SentenceOrderExerciseViewState
    extends State<_SentenceOrderExerciseView> {
  late final Map<String, ExerciseToken> _tokens = {
    for (final token in widget.exercise.tokens) token.id: token,
  };
  late final List<String> _ordered = _initialOrder();
  String? _tapSelection;
  final Map<String, int> _dropVersions = {};

  List<String> _initialOrder() {
    final ids = widget.exercise.tokens.map((token) => token.id).toList()
      ..shuffle(math.Random(widget.exercise.id.hashCode));
    if (widget.exercise.acceptedOrders
            .any((answer) => listEquals(answer, ids)) &&
        ids.length > 1) {
      ids.add(ids.removeAt(0));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _emit());
    return ids;
  }

  void _emit() => widget.onChanged(OrderedExerciseResponse(_ordered));

  void _tap(String id) {
    final selected = _tapSelection;
    if (selected == null) {
      setState(() => _tapSelection = id);
      return;
    }
    if (selected == id) {
      setState(() => _tapSelection = null);
      return;
    }
    setState(() {
      final first = _ordered.indexOf(selected);
      final second = _ordered.indexOf(id);
      final value = _ordered[first];
      _ordered[first] = _ordered[second];
      _ordered[second] = value;
      _dropVersions[selected] = (_dropVersions[selected] ?? 0) + 1;
      _dropVersions[id] = (_dropVersions[id] ?? 0) + 1;
      _tapSelection = null;
    });
    _emit();
  }

  void _moveBefore(String movingId, String targetId) {
    if (movingId == targetId) return;
    setState(() {
      _ordered.remove(movingId);
      _ordered.insert(_ordered.indexOf(targetId), movingId);
      _dropVersions[movingId] = (_dropVersions[movingId] ?? 0) + 1;
      _tapSelection = null;
    });
    _emit();
  }

  void _moveToEnd(String movingId) {
    if (_ordered.last == movingId) return;
    setState(() {
      _ordered
        ..remove(movingId)
        ..add(movingId);
      _dropVersions[movingId] = (_dropVersions[movingId] ?? 0) + 1;
      _tapSelection = null;
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SourceCard(label: 'MEANING', text: widget.exercise.translation),
        const SizedBox(height: 24),
        Text(
          'Drag a word into position. Tap two words to swap them.',
          style: TextStyle(color: context.appTextSecondary, height: 1.35),
        ),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.appElevatedSurface,
            borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
            border: Border.all(color: context.appBorder, width: 1.5),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 10,
            children: [
              for (var index = 0; index < _ordered.length; index++)
                DragTarget<String>(
                  key: ValueKey('order-target-${_ordered[index]}'),
                  onWillAcceptWithDetails: (details) =>
                      details.data != _ordered[index],
                  onAcceptWithDetails: (details) =>
                      _moveBefore(details.data, _ordered[index]),
                  builder: (context, hovering, _) => AnimatedPadding(
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.only(
                      left: hovering.isEmpty ? 0 : 12,
                    ),
                    child: _DropSettledToken(
                      key: ValueKey(
                        'order-${_ordered[index]}-'
                        '${_dropVersions[_ordered[index]] ?? 0}',
                      ),
                      animate: (_dropVersions[_ordered[index]] ?? 0) > 0,
                      child: _DraggableToken(
                        token: _tokens[_ordered[index]]!,
                        selected: _tapSelection == _ordered[index] ||
                            hovering.isNotEmpty,
                        onTap: () => _tap(_ordered[index]),
                        semanticHint:
                            'Position ${index + 1} of ${_ordered.length}. Tap another word to swap.',
                      ),
                    ),
                  ),
                ),
              DragTarget<String>(
                onWillAcceptWithDetails: (details) =>
                    details.data != _ordered.last,
                onAcceptWithDetails: (details) => _moveToEnd(details.data),
                builder: (context, hovering, _) => AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOutCubic,
                  width: hovering.isEmpty ? 18 : 32,
                  height: 46,
                  decoration: BoxDecoration(
                    color: hovering.isEmpty
                        ? Colors.transparent
                        : context.appInfo.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(VarnamalaTheme.radiusSmall),
                    border: hovering.isEmpty
                        ? null
                        : Border.all(color: context.appInfo, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FillBlankChoiceExerciseView extends StatefulWidget {
  const _FillBlankChoiceExerciseView({
    required this.exercise,
    required this.onChanged,
  });

  final FillBlankChoiceExercise exercise;
  final ValueChanged<ExerciseResponse?> onChanged;

  @override
  State<_FillBlankChoiceExerciseView> createState() =>
      _FillBlankChoiceExerciseViewState();
}

class _FillBlankChoiceExerciseViewState
    extends State<_FillBlankChoiceExerciseView> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SourceCard(label: 'CLUE', text: widget.exercise.clue),
        const SizedBox(height: 24),
        _SentenceWithBlank(
          before: widget.exercise.beforeBlank,
          after: widget.exercise.afterBlank,
          answer: _selectedId == null
              ? null
              : widget.exercise.options
                  .firstWhere((option) => option.id == _selectedId)
                  .text,
        ),
        const SizedBox(height: 24),
        for (final option in widget.exercise.options)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ChoiceTile(
              text: option.text,
              selected: _selectedId == option.id,
              onTap: () {
                setState(() => _selectedId = option.id);
                widget.onChanged(ChoiceExerciseResponse(option.id));
              },
            ),
          ),
      ],
    );
  }
}

class _FillBlankTextExerciseView extends StatefulWidget {
  const _FillBlankTextExerciseView({
    required this.exercise,
    required this.onChanged,
  });

  final FillBlankTextExercise exercise;
  final ValueChanged<ExerciseResponse?> onChanged;

  @override
  State<_FillBlankTextExerciseView> createState() =>
      _FillBlankTextExerciseViewState();
}

class _FillBlankTextExerciseViewState
    extends State<_FillBlankTextExerciseView> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocus);
  }

  void _handleFocus() {
    if (mounted) setState(() => _hasFocus = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocus)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SourceCard(label: 'CLUE', text: widget.exercise.clue),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              widget.exercise.beforeBlank,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOutCubic,
              width: math.min(180, MediaQuery.sizeOf(context).width * 0.42),
              padding: const EdgeInsets.fromLTRB(4, 6, 4, 5),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _hasFocus ? context.appInfo : context.appBorder,
                    width: _hasFocus ? 2.25 : 1.75,
                  ),
                ),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: context.appInfo,
                      fontWeight: FontWeight.w800,
                    ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  filled: false,
                  fillColor: Colors.transparent,
                  hintText: 'type here',
                  hintStyle: TextStyle(
                    color: context.appTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onChanged: (value) => widget.onChanged(
                  value.trim().isEmpty ? null : TextExerciseResponse(value),
                ),
              ),
            ),
            Text(
              widget.exercise.afterBlank,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appInfo.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
        border: Border.all(color: context.appInfo.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.appInfo,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
          ),
        ],
      ),
    );
  }
}

class _SentenceWithBlank extends StatelessWidget {
  const _SentenceWithBlank({
    required this.before,
    required this.after,
    required this.answer,
  });

  final String before;
  final String after;
  final String? answer;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          before,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minWidth: 92, minHeight: 42),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: answer == null
                ? context.appElevatedSurface
                : context.appInfo.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(VarnamalaTheme.radiusSmall),
            border: Border.all(
              color: answer == null ? context.appBorder : context.appInfo,
              width: 2,
            ),
          ),
          child: Text(
            answer ?? '________',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: answer == null
                      ? context.appTextSecondary
                      : context.appInfo,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        Text(
          after,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? context.appInfo.withValues(alpha: 0.12)
            : context.appSurface,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 54),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
              border: Border.all(
                color: selected ? context.appInfo : context.appBorder,
                width: selected ? 2 : 1.5,
              ),
            ),
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: selected ? context.appInfo : context.appTextPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DraggableToken extends StatefulWidget {
  const _DraggableToken({
    required this.token,
    required this.onTap,
    required this.semanticHint,
    this.selected = false,
  });

  final ExerciseToken token;
  final VoidCallback onTap;
  final String semanticHint;
  final bool selected;

  @override
  State<_DraggableToken> createState() => _DraggableTokenState();
}

class _DraggableTokenState extends State<_DraggableToken> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final chip = _TokenChip(
      text: widget.token.text,
      selected: widget.selected,
      onTap: widget.onTap,
      semanticHint: widget.semanticHint,
    );
    return Draggable<String>(
      data: widget.token.id,
      dragAnchorStrategy: childDragAnchorStrategy,
      rootOverlay: true,
      onDragStarted: () => setState(() => _dragging = true),
      onDragEnd: (_) {
        if (mounted) setState(() => _dragging = false);
      },
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.035,
          child: _TokenChip(
            text: widget.token.text,
            selected: true,
            semanticHint: 'Dragging ${widget.token.text}',
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.16, child: chip),
      child: MouseRegion(
        cursor:
            _dragging ? SystemMouseCursors.grabbing : SystemMouseCursors.grab,
        child: AnimatedScale(
          scale: _dragging ? 0.97 : 1,
          duration: const Duration(milliseconds: 90),
          child: chip,
        ),
      ),
    );
  }
}

class _DropSettledToken extends StatelessWidget {
  const _DropSettledToken({
    required this.animate,
    required this.child,
    super.key,
  });

  final bool animate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!animate) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 170),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final settled = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: 0.72 + (0.28 * settled),
          child: Transform.scale(
            scale: 0.94 + (0.06 * settled),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _TokenChip extends StatelessWidget {
  const _TokenChip({
    required this.text,
    required this.semanticHint,
    this.selected = false,
    this.onTap,
  });

  final String text;
  final String semanticHint;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: text,
      hint: semanticHint,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected
              ? context.appInfo.withValues(alpha: 0.16)
              : context.appSurface,
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusSmall),
          border: Border.all(
            color: selected ? context.appInfo : context.appBorder,
            width: selected ? 2 : 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: context.appInfo.withValues(alpha: 0.16),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusSmall),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(VarnamalaTheme.radiusSmall),
            child: Container(
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
