// ignore_for_file: doc_directive_unknown

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:push_notification_service/push_notification_service.dart';

part 'push_notification.g.dart';

@JsonSerializable(explicitToJson: true)
class PushNotification extends Equatable {
  PushNotification({
    this.title,
    this.body,
    this.payload,
  });

  /// Factory which converts a [Map<String, dynamic>] into a [PushNotification].
  factory PushNotification.fromJson(Map<String, dynamic> json) =>
      _$PushNotificationFromJson(json);

  /// Converts the current [PushNotification] into a [Map<String, dynamic>].
  Map<String, dynamic> toJson() => _$PushNotificationToJson(this);

  /// Title of the PN
  final String? title;

  /// Body of the PN
  final String? body;

  /// Payload containing data
  final Payload? payload;

  @override
  List<Object?> get props => [
        title,
        body,
        payload,
      ];
}
