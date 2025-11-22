
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payload.g.dart';

@JsonSerializable(explicitToJson: true)
class Payload extends Equatable {
  Payload({
    this.id,
    // this.notificationType,
  });

  /// Factory which converts a [Map<String, dynamic>] into a [Payload].
  factory Payload.fromJson(Map<String, dynamic> json) =>
      _$PayloadFromJson(json);

  /// Converts the current [Payload] into a [Map<String, dynamic>].
  Map<String, dynamic> toJson() => _$PayloadToJson(this);

  final String? id;

  /// Notification Type
  // @JsonKey(name: 'notification_type')
  // final NotificationType? notificationType;

  @override
  List<Object> get props => [
        id!,
        // notificationType!,
      ];
}
