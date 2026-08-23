import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/repositories/org_repository.dart';
import '../../../projects/domain/repositories/project_repository.dart';
import '../../domain/entities/task_item.dart';
import '../../domain/repositories/task_repository.dart';
import 'task_detail_state.dart';

export 'task_detail_state.dart';

class TaskDetailCubit extends Cubit<TaskDetailState> {
  TaskDetailCubit({
    required TaskRepository taskRepository,
    required ProjectRepository projectRepository,
    required OrgRepository orgRepository,
    required String taskId,
    required String orgId,
    required String userId,
  })  : _taskRepository = taskRepository,
        _projectRepository = projectRepository,
        _orgRepository = orgRepository,
        _taskId = taskId,
        _orgId = orgId,
        _userId = userId,
        super(const TaskDetailInitial());

  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;
  final OrgRepository _orgRepository;
  final String _taskId;
  final String _orgId;
  final String _userId;

  Future<void> load() async {
    emit(const TaskDetailLoading());
    try {
      final task = await _taskRepository.getTaskById(_taskId);
      final project = await _projectRepository.getProjectById(task.projectId);

      if (project.orgId != _orgId) {
        emit(const TaskDetailFailure(message: 'Task not found.'));
        return;
      }

      final members = await _orgRepository.getMembers(_orgId);
      final memberMap = {for (final member in members) member.id: member};

      final assignee = task.assigneeId == null
          ? null
          : memberMap[task.assigneeId];

      final rawComments = await _taskRepository.getComments(task.id);
      rawComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final comments = rawComments.map((comment) {
        final author = memberMap[comment.authorId] ??
            User(
              id: comment.authorId,
              name: 'Unknown user',
              email: '',
            );
        return TaskCommentItem(comment: comment, author: author);
      }).toList();

      emit(
        TaskDetailLoaded(
          TaskDetailData(
            task: task,
            project: project,
            assignee: assignee,
            comments: comments,
            members: members,
          ),
        ),
      );
    } catch (_) {
      emit(const TaskDetailFailure(message: 'Could not load task.'));
    }
  }

  Future<void> updateStatus(String status) async {
    await _updateTask(
      (task) => task.copyWith(status: status),
    );
  }

  Future<void> updatePriority(String priority) async {
    await _updateTask(
      (task) => task.copyWith(priority: priority),
    );
  }

  Future<void> assign(String? userId) async {
    final current = state;
    if (current is! TaskDetailLoaded) return;

    try {
      await _taskRepository.assignTask(
        orgId: _orgId,
        taskId: _taskId,
        userId: userId,
      );
      await load();
    } on AppException {
      rethrow;
    }
  }

  Future<void> updateTask(TaskItem task) async {
    try {
      await _taskRepository.updateTask(orgId: _orgId, task: task);
      await load();
    } on AppException {
      rethrow;
    }
  }

  Future<void> delete() async {
    await _taskRepository.deleteTask(_taskId);
  }

  Future<void> addComment(String body) async {
    try {
      await _taskRepository.addComment(
        taskId: _taskId,
        authorId: _userId,
        body: body,
      );
      await load();
    } on AppException {
      rethrow;
    }
  }

  Future<void> _updateTask(TaskItem Function(TaskItem task) transform) async {
    final current = state;
    if (current is! TaskDetailLoaded) return;

    try {
      final updated = transform(current.data.task);
      await _taskRepository.updateTask(orgId: _orgId, task: updated);
      await load();
    } on AppException {
      rethrow;
    }
  }
}
