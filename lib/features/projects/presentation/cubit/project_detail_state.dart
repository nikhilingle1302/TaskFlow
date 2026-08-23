import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../tasks/domain/entities/comment.dart';
import '../../../tasks/domain/entities/task_item.dart';
import '../../domain/entities/project.dart';

class ProjectDetailData extends Equatable {
  const ProjectDetailData({
    required this.project,
    required this.taskSummary,
    required this.tasks,
    required this.members,
    required this.comments,
    required this.isAdmin,
  });

  final Project project;
  final Map<String, int> taskSummary;
  final List<TaskItem> tasks;
  final List<User> members;
  final List<Comment> comments;
  final bool isAdmin;

  int get totalTasks => taskSummary.values.fold(0, (a, b) => a + b);

  int get doneTasks => taskSummary['done'] ?? 0;

  double get progress => totalTasks == 0 ? 0 : doneTasks / totalTasks;

  int get progressPercent => (progress * 100).round();

  @override
  List<Object?> get props => [
        project.id,
        taskSummary,
        tasks,
        members,
        comments,
        isAdmin,
      ];
}

abstract class ProjectDetailState extends Equatable {
  const ProjectDetailState();

  @override
  List<Object?> get props => [];
}

class ProjectDetailInitial extends ProjectDetailState {
  const ProjectDetailInitial();
}

class ProjectDetailLoading extends ProjectDetailState {
  const ProjectDetailLoading();
}

class ProjectDetailLoaded extends ProjectDetailState {
  const ProjectDetailLoaded(this.data);

  final ProjectDetailData data;

  @override
  List<Object?> get props => [data];
}

class ProjectDetailFailure extends ProjectDetailState {
  const ProjectDetailFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
