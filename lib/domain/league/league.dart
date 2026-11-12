import 'package:freezed_annotation/freezed_annotation.dart';

part 'league.freezed.dart';

@freezed
abstract class League with _$League {
  const factory League({
    required String id,
    required String name,
    required int tier,
  }) = _League;
}
