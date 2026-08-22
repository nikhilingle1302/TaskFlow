import 'package:uuid/uuid.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/mock_data_store.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/task_item.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/comment_model.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._store);

  final MockDataStore _store;
  final _uuid = const Uuid();

  @override
  Future<List<TaskItem>> getTasks({
    required String orgId,
    String? projectId,
    TaskFilter filter = const TaskFilter(),
  }) async {
    await _store.ensureLoaded();

    final projectIds = _store.projects
        .where((p) => p.orgId == orgId)
        .map((p) => p.id)
        .toSet();

    var list = _store.tasks.where((t) => projectIds.contains(t.projectId));
    if (projectId != null) {
      list = list.where((t) => t.projectId == projectId);
    }

    return list.where((t) => _matchesFilter(t, filter)).map(_toEntity).toList();
  }

  @override
  Future<TaskItem> getTaskById(String taskId) async {
    await _store.ensureLoaded();
    try {
      return _toEntity(_store.tasks.firstWhere((t) => t.id == taskId));
    } catch (_) {
      throw NotFoundException('Task $taskId was not found.');
    }
  }

  @override
  Future<TaskItem> createTask({
    required String orgId,
    required String projectId,
    required String title,
    required String description,
    required String status,
    required String priority,
    String? assigneeId,
    DateTime? dueDate,
  }) async {
    await _store.ensureLoaded();

    if (title.trim().isEmpty) {
      throw const ValidationException('Task title is required.');
    }

    final projectIndex =
        _store.projects.indexWhere((p) => p.id == projectId);
    if (projectIndex < 0) {
      throw NotFoundException('Project $projectId was not found.');
    }
    if (_store.projects[projectIndex].orgId != orgId) {
      throw const ForbiddenException('Project does not belong to your org.');
    }

    if (assigneeId != null) {
      _assertUserInOrg(orgId, assigneeId);
    }

    final model = TaskModel(
      id: 'task_${_uuid.v4().substring(0, 8)}',
      projectId: projectId,
      title: title.trim(),
      description: description.trim(),
      status: status,
      priority: priority,
      assigneeId: assigneeId,
      dueDate: dueDate,
      createdAt: DateTime.now().toUtc(),
    );
    _store.tasks = [..._store.tasks, model];
    _bumpTaskCount(projectId, 1);
    return _toEntity(model);
  }

  @override
  Future<TaskItem> updateTask({
    required String orgId,
    required TaskItem task,
  }) async {
    await _store.ensureLoaded();

    if (task.title.trim().isEmpty) {
      throw const ValidationException('Task title is required.');
    }
    if (task.assigneeId != null) {
      _assertUserInOrg(orgId, task.assigneeId!);
    }

    final index = _store.tasks.indexWhere((t) => t.id == task.id);
    if (index < 0) {
      throw NotFoundException('Task ${task.id} was not found.');
    }

    final updated = _store.tasks[index].copyWith(
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      assigneeId: task.assigneeId,
      dueDate: task.dueDate,
      clearAssignee: task.assigneeId == null,
      clearDueDate: task.dueDate == null,
    );
    final list = [..._store.tasks];
    list[index] = updated;
    _store.tasks = list;
    return _toEntity(updated);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _store.ensureLoaded();

    final index = _store.tasks.indexWhere((t) => t.id == taskId);
    if (index < 0) {
      throw NotFoundException('Task $taskId was not found.');
    }

    final projectId = _store.tasks[index].projectId;
    _store.tasks = _store.tasks.where((t) => t.id != taskId).toList();
    _store.comments =
        _store.comments.where((c) => c.taskId != taskId).toList();
    _bumpTaskCount(projectId, -1);
  }

  @override
  Future<TaskItem> assignTask({
    required String orgId,
    required String taskId,
    required String? userId,
  }) async {
    await _store.ensureLoaded();

    if (userId != null) {
      _assertUserInOrg(orgId, userId);
    }

    final index = _store.tasks.indexWhere((t) => t.id == taskId);
    if (index < 0) {
      throw NotFoundException('Task $taskId was not found.');
    }

    final updated = _store.tasks[index].copyWith(
      assigneeId: userId,
      clearAssignee: userId == null,
    );
    final list = [..._store.tasks];
    list[index] = updated;
    _store.tasks = list;
    return _toEntity(updated);
  }

  @override
  Future<List<Comment>> getComments(String taskId) async {
    await _store.ensureLoaded();
    return _store.comments
        .where((c) => c.taskId == taskId)
        .map(_toComment)
        .toList();
  }

  @override
  Future<Comment> addComment({
    required String taskId,
    required String authorId,
    required String body,
  }) async {
    await _store.ensureLoaded();

    if (body.trim().isEmpty) {
      throw const ValidationException('Comment cannot be empty.');
    }

    final exists = _store.tasks.any((t) => t.id == taskId);
    if (!exists) {
      throw NotFoundException('Task $taskId was not found.');
    }

    final model = CommentModel(
      id: 'cmt_${_uuid.v4().substring(0, 8)}',
      taskId: taskId,
      authorId: authorId,
      body: body.trim(),
      createdAt: DateTime.now().toUtc(),
    );
    _store.comments = [..._store.comments, model];
    return _toComment(model);
  }

  bool _matchesFilter(TaskModel task, TaskFilter filter) {
    if (filter.status != null && task.status != filter.status) return false;
    if (filter.priority != null && task.priority != filter.priority) {
      return false;
    }
    if (filter.assigneeId != null && task.assigneeId != filter.assigneeId) {
      return false;
    }
    if (filter.dueFrom != null) {
      if (task.dueDate == null || task.dueDate!.isBefore(filter.dueFrom!)) {
        return false;
      }
    }
    if (filter.dueTo != null) {
      if (task.dueDate == null || task.dueDate!.isAfter(filter.dueTo!)) {
        return false;
      }
    }
    return true;
  }

  void _assertUserInOrg(String orgId, String userId) {
    final ok = _store.orgMembers.any(
      (m) => m.orgId == orgId && m.userId == userId,
    );
    if (!ok) {
      throw const ValidationException(
        'Cannot assign a user outside the current organization.',
      );
    }
  }

  void _bumpTaskCount(String projectId, int delta) {
    final index = _store.projects.indexWhere((p) => p.id == projectId);
    if (index < 0) return;
    final project = _store.projects[index];
    final list = [..._store.projects];
    list[index] = project.copyWith(
      taskCount: (project.taskCount + delta).clamp(0, 9999),
    );
    _store.projects = list;
  }

  TaskItem _toEntity(TaskModel model) {
    return TaskItem(
      id: model.id,
      projectId: model.projectId,
      title: model.title,
      description: model.description,
      status: model.status,
      priority: model.priority,
      assigneeId: model.assigneeId,
      dueDate: model.dueDate,
      createdAt: model.createdAt,
    );
  }

  Comment _toComment(CommentModel model) {
    return Comment(
      id: model.id,
      taskId: model.taskId,
      authorId: model.authorId,
      body: model.body,
      createdAt: model.createdAt,
    );
  }
}
