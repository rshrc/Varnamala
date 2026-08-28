import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:words625/domain/exercise/interactive_exercise.dart';
import 'package:words625/views/lesson/exercises/widgets/exercise_source_card.dart';
import 'package:words625/views/lesson/exercises/widgets/exercise_token.dart';
import 'package:words625/views/theme.dart';

class TokenBankExerciseView extends StatefulWidget {
  const TokenBankExerciseView({
    required this.sourceLabel,
    required this.sourceText,
    required this.tokens,
    required this.acceptedOrders,
    required this.shuffleSeed,
    required this.joinWithoutSpaces,
    required this.onChanged,
    super.key,
  });

  final String sourceLabel;
  final String sourceText;
  final List<ExerciseToken> tokens;
  final List<List<String>> acceptedOrders;
  final int shuffleSeed;
  final bool joinWithoutSpaces;
  final ValueChanged<ExerciseResponse?> onChanged;

  @override
  State<TokenBankExerciseView> createState() => TokenBankExerciseViewState();
}

class TokenBankExerciseViewState extends State<TokenBankExerciseView> {
  late final Map<String, ExerciseToken> tokensById = {
    for (final token in widget.tokens) token.id: token,
  };
  late final List<String> availableTokenIds = initialAvailableTokenIds();
  final List<String> selectedTokenIds = [];
  final Map<String, int> dropVersions = {};

  List<String> initialAvailableTokenIds() {
    final ids = widget.tokens.map((token) => token.id).toList()
      ..shuffle(math.Random(widget.shuffleSeed));
    if (ids.length > 1 &&
        widget.acceptedOrders.any((answer) => listEquals(answer, ids))) {
      ids.add(ids.removeAt(0));
    }
    return ids;
  }

  void emitResponse() {
    widget.onChanged(
      selectedTokenIds.isEmpty
          ? null
          : OrderedExerciseResponse(selectedTokenIds),
    );
  }

  void moveToAnswer(String id, {String? beforeId}) {
    setState(() {
      availableTokenIds.remove(id);
      selectedTokenIds.remove(id);
      final beforeIndex =
          beforeId == null ? -1 : selectedTokenIds.indexOf(beforeId);
      if (beforeIndex == -1) {
        selectedTokenIds.add(id);
      } else {
        selectedTokenIds.insert(beforeIndex, id);
      }
      dropVersions[id] = (dropVersions[id] ?? 0) + 1;
    });
    emitResponse();
  }

  void moveToBank(String id) {
    if (!selectedTokenIds.contains(id)) return;
    setState(() {
      selectedTokenIds.remove(id);
      availableTokenIds.add(id);
      dropVersions[id] = (dropVersions[id] ?? 0) + 1;
    });
    emitResponse();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExerciseSourceCard(label: widget.sourceLabel, text: widget.sourceText),
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
          onAcceptWithDetails: (details) => moveToAnswer(details.data),
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
            child: selectedTokenIds.isEmpty
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
                      for (final id in selectedTokenIds)
                        DragTarget<String>(
                          key: ValueKey('answer-target-$id'),
                          onWillAcceptWithDetails: (details) =>
                              details.data != id,
                          onAcceptWithDetails: (details) =>
                              moveToAnswer(details.data, beforeId: id),
                          builder: (context, hovering, _) => AnimatedPadding(
                            duration: const Duration(milliseconds: 120),
                            curve: Curves.easeOutCubic,
                            padding: EdgeInsets.only(
                              left: hovering.isEmpty ? 0 : 10,
                            ),
                            child: SettledExerciseToken(
                              key: ValueKey(
                                'answer-$id-${dropVersions[id] ?? 0}',
                              ),
                              animate: (dropVersions[id] ?? 0) > 0,
                              child: DraggableExerciseToken(
                                token: tokensById[id]!,
                                selected: hovering.isNotEmpty,
                                onTap: () => moveToBank(id),
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
              selectedTokenIds.contains(details.data),
          onAcceptWithDetails: (details) => moveToBank(details.data),
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
                for (final id in availableTokenIds)
                  SettledExerciseToken(
                    key: ValueKey('bank-$id-${dropVersions[id] ?? 0}'),
                    animate: (dropVersions[id] ?? 0) > 0,
                    child: DraggableExerciseToken(
                      token: tokensById[id]!,
                      onTap: () => moveToAnswer(id),
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
