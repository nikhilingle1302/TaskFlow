import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../projects/domain/entities/project.dart';
import '../../domain/entities/task_item.dart';

class TaskListItem extends Equatable {
  const TaskListItem({
    required this.task,
    required this.projectName,
    this.assignee,
  });

  final TaskItem task;
  final String projectName;
  final User? assignee;

  @override
  List<Object?> get props => [task.id, projectName, assignee?.id];
}

class TaskSectionGroup extends Equatable {
  const TaskSectionGroup({
    required this.title,
    required this.items,
  });

  final String title;
  final List<TaskListItem> items;

  @override
  List<Object?> get props => [title, items];
}

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TaskLoaded extends TaskState {
  const TaskLoaded({
    required this.allItems,
    required this.sections,
    required this.flatItems,
    required this.query,
    required this.status,
    required this.priority,
    required this.projectId,
    required this.assigneeId,
    required this.projects,
    required this.members,
  });

  final List<TaskListItem> allItems;
  final List<TaskSectionGroup> sections;
  final List<TaskListItem> flatItems;
  final String query;
  final String? status;
  final String? priority;
  final String? projectId;
  final String? assigneeId;
  final List<Project> projects;
  final List<User> members;

  bool get useSections => status == null;

  int get activeFilterCount {
    var count = 0;
    if (priority != null) count++;
    if (projectId != null) count++;
    if (assigneeId != null) count++;
    return count;
  }

  TaskLoaded copyWith({
    List<TaskListItem>? allItems,
    List<TaskSectionGroup>? sections,
    List<TaskListItem>? flatItems,
    String? query,
    String? status,
    String? priority,
    String? projectId,
    String? assigneeId,
    List<Project>? projects,
    List<User>? members,
    bool clearStatus = false,
    bool clearPriority = false,
    bool clearProjectId = false,
    bool clearAssigneeId = false,
  }) {
    return TaskLoaded(
      allItems: allItems ?? this.allItems,
      sections: sections ?? this.sections,
      flatItems: flatItems ?? this.flatItems,
      query: query ?? this.query,
      status: clearStatus ? null : (status ?? this.status),
      priority: clearPriority ? null : (priority ?? this.priority),
      projectId: clearProjectId ? null : (projectId ?? this.projectId),
      assigneeId: clearAssigneeId ? null : (assigneeId ?? this.assigneeId),
      projects: projects ?? this.projects,
      members: members ?? this.members,
    );
  }

  @override
  List<Object?> get props => [
        allItems,
        sections,
        flatItems,
        query,
        status,
        priority,
        projectId,
        assigneeId,
        projects,
        members,
      ];
}

class TaskEmpty extends TaskState {
  const TaskEmpty({
    required this.projects,
    required this.members,
  });

  final List<Project> projects;
  final List<User> members;

  @override
  List<Object?> get props => [projects, members];
}

class TaskActionFailure extends TaskState {
  const TaskActionFailure({
    required this.message,
    required this.previous,
  });

  final String message;
  final TaskState previous;

  @override
  List<Object?> get props => [message, previous];
}

class TaskFailure extends TaskState {
  const TaskFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
