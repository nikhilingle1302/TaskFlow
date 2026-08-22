import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel {
  final String id;
  @JsonKey(name: 'project_id')
  final String projectId;
  final String title;
  final String description;
  final String status;
  final String priority;
  @JsonKey(name: 'assignee_id')
  final String? assigneeId;
  @JsonKey(name: 'due_date')
  final DateTime? dueDate;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.assigneeId,
    this.dueDate,
    required this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  TaskModel copyWith({
    String? title,
    String? description,
    String? status,
    String? priority,
    String? assigneeId,
    DateTime? dueDate,
    bool clearAssignee = false,
    bool clearDueDate = false,
  }) {
    return TaskModel(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assigneeId: clearAssignee ? null : (assigneeId ?? this.assigneeId),
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      createdAt: createdAt,
    );
  }
}
