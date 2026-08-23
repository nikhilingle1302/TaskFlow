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
    this.isMutating = false,
  });

  final Project project;
  final Map<String, int> taskSummary;
  final List<TaskItem> tasks;
  final List<User> members;
  final List<Comment> comments;
  final bool isAdmin;
  final bool isMutating;

  int get totalTasks => taskSummary.values.fold(0, (a, b) => a + b);

  int get doneTasks => taskSummary['done'] ?? 0;

  double get progress => totalTasks == 0 ? 0 : doneTasks / totalTasks;

  int get progressPercent => (progress * 100).round();

  ProjectDetailData copyWith({
    List<User>? members,
    bool? isMutating,
  }) {
    return ProjectDetailData(
      project: project,
      taskSummary: taskSummary,
      tasks: tasks,
      members: members ?? this.members,
      comments: comments,
      isAdmin: isAdmin,
      isMutating: isMutating ?? this.isMutating,
    );
  }

  @override
  List<Object?> get props => [
        project.id,
        taskSummary,
        tasks,
        members,
        comments,
        isAdmin,
        isMutating,
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

class ProjectDetailActionFailure extends ProjectDetailState {
  const ProjectDetailActionFailure({
    required this.message,
    required this.previous,
  });

  final String message;
  final ProjectDetailLoaded previous;

  @override
  List<Object?> get props => [message, previous];
}

class ProjectDetailFailure extends ProjectDetailState {
  const ProjectDetailFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
