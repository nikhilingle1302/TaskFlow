import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String type;
  @JsonKey(name: 'task_id')
  final String taskId;
  final String message;
  final bool read;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.taskId,
    required this.message,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationModel copyWith({bool? read}) {
    return NotificationModel(
      id: id,
      userId: userId,
      type: type,
      taskId: taskId,
      message: message,
      read: read ?? this.read,
      createdAt: createdAt,
    );
  }
}
