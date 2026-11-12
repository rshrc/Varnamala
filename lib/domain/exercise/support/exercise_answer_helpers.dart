import 'package:words625/domain/exercise/model/exercise_token.dart';

String normalizeTypedAnswer(String value) => value
    .trim()
    .replaceAll(RegExp(r'\s+'), ' ')
    .replaceFirst(RegExp(r'[.?!]+$'), '')
    .toLowerCase();

bool matchesAnyTokenOrder(
  List<String> response,
  List<List<String>> acceptedOrders,
  List<ExerciseToken> tokens,
) {
  final byId = {for (final token in tokens) token.id: token.text};
  final responseValues = _valuesForIds(response, byId);
  if (responseValues == null) return false;

  return acceptedOrders.any((answer) {
    final answerValues = _valuesForIds(answer, byId);
    if (answerValues == null || answerValues.length != responseValues.length) {
      return false;
    }
    for (var index = 0; index < answerValues.length; index++) {
      if (normalizeTypedAnswer(answerValues[index]) !=
          normalizeTypedAnswer(responseValues[index])) {
        return false;
      }
    }
    return true;
  });
}

List<String> tokensForOrder(List<ExerciseToken> tokens, List<String> order) {
  final byId = {for (final token in tokens) token.id: token.text};
  return order.map((id) => byId[id] ?? id).toList(growable: false);
}

List<String>? _valuesForIds(List<String> ids, Map<String, String> valuesById) {
  final values = <String>[];
  for (final id in ids) {
    final value = valuesById[id];
    if (value == null) return null;
    values.add(value);
  }
  return values;
}
