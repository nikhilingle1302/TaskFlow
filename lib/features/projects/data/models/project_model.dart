import 'package:json_annotation/json_annotation.dart';

part 'project_model.g.dart';

@JsonSerializable()
class ProjectModel {
  final String id;
  @JsonKey(name: 'org_id')
  final String orgId;
  final String name;
  final String description;
  @JsonKey(name: 'task_count')
  final int taskCount;
  final String status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const ProjectModel({
    required this.id,
    required this.orgId,
    required this.name,
    required this.description,
    required this.taskCount,
    required this.status,
    required this.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);

  ProjectModel copyWith({
    String? name,
    String? description,
    int? taskCount,
    String? status,
  }) {
    return ProjectModel(
      id: id,
      orgId: orgId,
      name: name ?? this.name,
      description: description ?? this.description,
      taskCount: taskCount ?? this.taskCount,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
