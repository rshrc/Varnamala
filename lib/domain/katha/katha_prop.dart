import 'package:freezed_annotation/freezed_annotation.dart';

part 'katha_prop.freezed.dart';
part 'katha_prop.g.dart';

/// Something in a panel that is not a character: a meter, a signal, a cooker.
@Freezed(toJson: false)
abstract class KathaProp with _$KathaProp {
  const factory KathaProp({
    required String id,

    /// What to draw, such as `prop.auto_meter`.
    required String asset,

    /// `<character>.<part>` the prop is mounted on, such as `raju.auto`.
    String? attach,
  }) = _KathaProp;

  factory KathaProp.fromJson(Map<String, dynamic> json) =>
      _$KathaPropFromJson(json);
}
