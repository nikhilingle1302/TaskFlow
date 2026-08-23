import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/mock_data_store.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/storage/offline_cache.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/task_item.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/comment_model.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(
    this._store,
    this._preferences,
    this._cache,
  );

  final MockDataStore _store;
  final AppPreferences _preferences;
  final OfflineCache _cache;
  final _uuid = const Uuid();

  @override
  Future<List<TaskItem>> getTasks({
    required String orgId,
    String? projectId,
    TaskFilter filter = const TaskFilter(),
  }) async {
    await _store.ensureLoaded();
    await _store.simulateRequest();

    if (_preferences.offlineMode) {
      _restoreOrgCache(orgId);
    }

    if (projectId != null) {
      _requireProjectInOrg(orgId: orgId, projectId: projectId);
    }

    final projectIds = _store.projects
        .where((p) => p.orgId == orgId)
        .map((p) => p.id)
        .toSet();

    var list = _store.tasks.where((t) => projectIds.contains(t.projectId));
    if (projectId != null) {
      list = list.where((t) => t.projectId == projectId);
    }

    final models = list.where((t) => _matchesFilter(t, filter)).toList();
    if (!_preferences.offlineMode) {
      await _cache.saveTasks(orgId, _store.tasksForOrg(orgId));
    }

    return models.map(_toEntity).toList();
  }

  @override
  Future<TaskItem> getTaskById({
    required String orgId,
    required String taskId,
  }) async {
    await _store.ensureLoaded();
    await _store.simulateRequest();

    if (taskId == AppConstants.forceNotFoundTaskId) {
      throw NotFoundException('Task $taskId was not found.');
    }

    final model = _requireTaskInOrg(orgId: orgId, taskId: taskId);
    return _toEntity(model);
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
    await _store.simulateRequest(isWrite: true);

    if (title.trim().isEmpty) {
      throw const ValidationException('Task title is required.');
    }

    _requireProjectInOrg(orgId: orgId, projectId: projectId);

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
    await _cache.saveTasks(orgId, _store.tasksForOrg(orgId));
    await _cache.saveProjects(orgId, _store.projectsForOrg(orgId));
    return _toEntity(model);
  }

  @override
  Future<TaskItem> updateTask({
    required String orgId,
    required TaskItem task,
  }) async {
    await _store.ensureLoaded();
    await _store.simulateRequest(isWrite: true);

    if (task.title.trim().isEmpty) {
      throw const ValidationException('Task title is required.');
    }

    final existing = _requireTaskInOrg(orgId: orgId, taskId: task.id);
    _requireProjectInOrg(orgId: orgId, projectId: task.projectId);

    if (task.assigneeId != null) {
      _assertUserInOrg(orgId, task.assigneeId!);
    }

    final index = _store.tasks.indexWhere((t) => t.id == existing.id);
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
    await _cache.saveTasks(orgId, _store.tasksForOrg(orgId));
    return _toEntity(updated);
  }

  @override
  Future<void> deleteTask({
    required String orgId,
    required String taskId,
  }) async {
    await _store.ensureLoaded();
    await _store.simulateRequest(isWrite: true);

    final existing = _requireTaskInOrg(orgId: orgId, taskId: taskId);
    final projectId = existing.projectId;

    _store.tasks = _store.tasks.where((t) => t.id != taskId).toList();
    _store.comments =
        _store.comments.where((c) => c.taskId != taskId).toList();
    _bumpTaskCount(projectId, -1);
    await _cache.saveTasks(orgId, _store.tasksForOrg(orgId));
    await _cache.saveProjects(orgId, _store.projectsForOrg(orgId));
  }

  @override
  Future<TaskItem> assignTask({
    required String orgId,
    required String taskId,
    required String? userId,
  }) async {
    await _store.ensureLoaded();
    await _store.simulateRequest(isWrite: true);

    final existing = _requireTaskInOrg(orgId: orgId, taskId: taskId);

    if (userId != null) {
      _assertUserInOrg(orgId, userId);
    }

    final index = _store.tasks.indexWhere((t) => t.id == existing.id);
    final updated = _store.tasks[index].copyWith(
      assigneeId: userId,
      clearAssignee: userId == null,
    );
    final list = [..._store.tasks];
    list[index] = updated;
    _store.tasks = list;
    await _cache.saveTasks(orgId, _store.tasksForOrg(orgId));
    return _toEntity(updated);
  }

  @override
  Future<List<Comment>> getComments(String taskId) async {
    await _store.ensureLoaded();
    await _store.simulateRequest();
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
    await _store.simulateRequest(isWrite: true);

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

  TaskModel _requireTaskInOrg({
    required String orgId,
    required String taskId,
  }) {
    TaskModel? task;
    for (final item in _store.tasks) {
      if (item.id == taskId) {
        task = item;
        break;
      }
    }
    if (task == null) {
      throw NotFoundException('Task $taskId was not found.');
    }
    _requireProjectInOrg(orgId: orgId, projectId: task.projectId);
    return task;
  }

  void _requireProjectInOrg({
    required String orgId,
    required String projectId,
  }) {
    final index = _store.projects.indexWhere((p) => p.id == projectId);
    if (index < 0) {
      throw NotFoundException('Project $projectId was not found.');
    }
    if (_store.projects[index].orgId != orgId) {
      throw const ForbiddenException(
        'Project does not belong to your organization.',
      );
    }
  }

  void _restoreOrgCache(String orgId) {
    final cachedProjects = _cache.loadProjects(orgId);
    final cachedTasks = _cache.loadTasks(orgId);
    if (cachedProjects == null && cachedTasks == null) return;

    _store.applyOrgCache(
      orgId: orgId,
      projects: cachedProjects,
      tasks: cachedTasks,
    );
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
