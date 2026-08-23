import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../projects/domain/entities/project.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/task_item.dart';

class TaskCommentItem extends Equatable {
  const TaskCommentItem({
    required this.comment,
    required this.author,
  });

  final Comment comment;
  final User author;

  @override
  List<Object?> get props => [comment.id, author.id];
}

class TaskDetailData extends Equatable {
  const TaskDetailData({
    required this.task,
    required this.project,
    required this.assignee,
    required this.comments,
  });

  final TaskItem task;
  final Project project;
  final User? assignee;
  final List<TaskCommentItem> comments;

  @override
  List<Object?> get props => [task.id, project.id, assignee?.id, comments];
}

abstract class TaskDetailState extends Equatable {
  const TaskDetailState();

  @override
  List<Object?> get props => [];
}

class TaskDetailInitial extends TaskDetailState {
  const TaskDetailInitial();
}

class TaskDetailLoading extends TaskDetailState {
  const TaskDetailLoading();
}

class TaskDetailLoaded extends TaskDetailState {
  const TaskDetailLoaded(this.data);

  final TaskDetailData data;

  @override
  List<Object?> get props => [data];
}

class TaskDetailFailure extends TaskDetailState {
  const TaskDetailFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
