import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:words625/core/stable_hash.dart';
import 'package:words625/domain/exercise/interactive_exercise.dart';
import 'package:words625/views/lesson/exercises/widgets/exercise_source_card.dart';
import 'package:words625/views/lesson/exercises/widgets/exercise_token.dart';
import 'package:words625/views/theme.dart';

class SentenceOrderExerciseView extends StatefulWidget {
  const SentenceOrderExerciseView({
    required this.exercise,
    required this.onChanged,
    super.key,
  });

  final SentenceOrderExercise exercise;
  final ValueChanged<ExerciseResponse?> onChanged;

  @override
  State<SentenceOrderExerciseView> createState() =>
      SentenceOrderExerciseViewState();
}

class SentenceOrderExerciseViewState extends State<SentenceOrderExerciseView> {
  late final Map<String, ExerciseToken> tokensById = {
    for (final token in widget.exercise.tokens) token.id: token,
  };
  late final List<String> orderedTokenIds = initialOrder();
  String? tapSelection;
  final Map<String, int> dropVersions = {};

  List<String> initialOrder() {
    final ids = widget.exercise.tokens.map((token) => token.id).toList()
      ..shuffle(math.Random(stableHash32(widget.exercise.id)));
    if (widget.exercise.acceptedOrders
            .any((answer) => listEquals(answer, ids)) &&
        ids.length > 1) {
      ids.add(ids.removeAt(0));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => emitResponse());
    return ids;
  }

  void emitResponse() =>
      widget.onChanged(OrderedExerciseResponse(orderedTokenIds));

  void handleTap(String id) {
    final selected = tapSelection;
    if (selected == null) {
      setState(() => tapSelection = id);
      return;
    }
    if (selected == id) {
      setState(() => tapSelection = null);
      return;
    }
    setState(() {
      final first = orderedTokenIds.indexOf(selected);
      final second = orderedTokenIds.indexOf(id);
      final value = orderedTokenIds[first];
      orderedTokenIds[first] = orderedTokenIds[second];
      orderedTokenIds[second] = value;
      dropVersions[selected] = (dropVersions[selected] ?? 0) + 1;
      dropVersions[id] = (dropVersions[id] ?? 0) + 1;
      tapSelection = null;
    });
    emitResponse();
  }

  void moveBefore(String movingId, String targetId) {
    if (movingId == targetId) return;
    setState(() {
      orderedTokenIds.remove(movingId);
      orderedTokenIds.insert(orderedTokenIds.indexOf(targetId), movingId);
      dropVersions[movingId] = (dropVersions[movingId] ?? 0) + 1;
      tapSelection = null;
    });
    emitResponse();
  }

  void moveToEnd(String movingId) {
    if (orderedTokenIds.last == movingId) return;
    setState(() {
      orderedTokenIds
        ..remove(movingId)
        ..add(movingId);
      dropVersions[movingId] = (dropVersions[movingId] ?? 0) + 1;
      tapSelection = null;
    });
    emitResponse();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExerciseSourceCard(
          label: 'MEANING',
          text: widget.exercise.translation,
        ),
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
              for (var index = 0; index < orderedTokenIds.length; index++)
                DragTarget<String>(
                  key: ValueKey('order-target-${orderedTokenIds[index]}'),
                  onWillAcceptWithDetails: (details) =>
                      details.data != orderedTokenIds[index],
                  onAcceptWithDetails: (details) =>
                      moveBefore(details.data, orderedTokenIds[index]),
                  builder: (context, hovering, _) => AnimatedPadding(
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.only(
                      left: hovering.isEmpty ? 0 : 12,
                    ),
                    child: SettledExerciseToken(
                      key: ValueKey(
                        'order-${orderedTokenIds[index]}-'
                        '${dropVersions[orderedTokenIds[index]] ?? 0}',
                      ),
                      animate: (dropVersions[orderedTokenIds[index]] ?? 0) > 0,
                      child: DraggableExerciseToken(
                        token: tokensById[orderedTokenIds[index]]!,
                        selected: tapSelection == orderedTokenIds[index] ||
                            hovering.isNotEmpty,
                        onTap: () => handleTap(orderedTokenIds[index]),
                        semanticHint:
                            'Position ${index + 1} of ${orderedTokenIds.length}. Tap another word to swap.',
                      ),
                    ),
                  ),
                ),
              DragTarget<String>(
                onWillAcceptWithDetails: (details) =>
                    details.data != orderedTokenIds.last,
                onAcceptWithDetails: (details) => moveToEnd(details.data),
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
