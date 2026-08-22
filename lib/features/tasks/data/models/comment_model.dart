import 'package:json_annotation/json_annotation.dart';

part 'comment_model.g.dart';

@JsonSerializable()
class CommentModel {
  final String id;
  @JsonKey(name: 'task_id')
  final String taskId;
  @JsonKey(name: 'author_id')
  final String authorId;
  final String body;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.taskId,
    required this.authorId,
    required this.body,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);
}
