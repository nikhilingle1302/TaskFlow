import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/mock_data_store.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/storage/offline_cache.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../models/project_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl(
    this._store,
    this._preferences,
    this._cache,
  );

  final MockDataStore _store;
  final AppPreferences _preferences;
  final OfflineCache _cache;
  final _uuid = const Uuid();

  @override
  Future<List<Project>> getProjects(String orgId) async {
    await _store.ensureLoaded();
    await _store.simulateRequest();

    if (_preferences.offlineMode) {
      _restoreOrgCache(orgId);
    }

    final models = _store.projectsForOrg(orgId);
    if (!_preferences.offlineMode) {
      await _cache.saveProjects(orgId, models);
    }

    return models.map(_toEntity).toList();
  }

  @override
  Future<Project> getProjectById({
    required String orgId,
    required String projectId,
  }) async {
    await _store.ensureLoaded();
    await _store.simulateRequest();

    if (projectId == AppConstants.forceTimeoutProjectId) {
      throw const TimeoutException('The request timed out. Please try again.');
    }

    final model = _requireProjectInOrg(orgId: orgId, projectId: projectId);
    return _toEntity(model);
  }

  @override
  Future<Project> createProject({
    required String orgId,
    required String name,
    required String description,
  }) async {
    await _store.ensureLoaded();
    await _store.simulateRequest(isWrite: true);

    if (name.trim().isEmpty) {
      throw const ValidationException('Project name is required.');
    }

    final model = ProjectModel(
      id: 'proj_${_uuid.v4().substring(0, 8)}',
      orgId: orgId,
      name: name.trim(),
      description: description.trim(),
      taskCount: 0,
      status: 'active',
      createdAt: DateTime.now().toUtc(),
    );
    _store.projects = [..._store.projects, model];
    await _cache.saveProjects(orgId, _store.projectsForOrg(orgId));
    return _toEntity(model);
  }

  @override
  Future<Project> updateProject({
    required String orgId,
    required Project project,
  }) async {
    await _store.ensureLoaded();
    await _store.simulateRequest(isWrite: true);

    final existing = _requireProjectInOrg(orgId: orgId, projectId: project.id);
    final index = _store.projects.indexWhere((p) => p.id == existing.id);

    final updated = _store.projects[index].copyWith(
      name: project.name,
      description: project.description,
      taskCount: project.taskCount,
      status: project.status,
    );
    final list = [..._store.projects];
    list[index] = updated;
    _store.projects = list;
    await _cache.saveProjects(orgId, _store.projectsForOrg(orgId));
    return _toEntity(updated);
  }

  @override
  Future<void> deleteProject({
    required String orgId,
    required String projectId,
    required String role,
  }) async {
    await _store.ensureLoaded();
    await _store.simulateRequest(isWrite: true);

    if (role != 'org_admin') {
      throw const ForbiddenException(
        'Only organization admins can delete projects.',
      );
    }

    _requireProjectInOrg(orgId: orgId, projectId: projectId);

    _store.projects =
        _store.projects.where((p) => p.id != projectId).toList();
    _store.tasks =
        _store.tasks.where((t) => t.projectId != projectId).toList();
    await _cache.saveProjects(orgId, _store.projectsForOrg(orgId));
    await _cache.saveTasks(orgId, _store.tasksForOrg(orgId));
  }

  ProjectModel _requireProjectInOrg({
    required String orgId,
    required String projectId,
  }) {
    ProjectModel? model;
    for (final project in _store.projects) {
      if (project.id == projectId) {
        model = project;
        break;
      }
    }
    if (model == null) {
      throw NotFoundException('Project $projectId was not found.');
    }
    if (model.orgId != orgId) {
      throw const ForbiddenException(
        'Project does not belong to your organization.',
      );
    }
    return model;
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

  Project _toEntity(ProjectModel model) {
    return Project(
      id: model.id,
      orgId: model.orgId,
      name: model.name,
      description: model.description,
      taskCount: model.taskCount,
      status: model.status,
      createdAt: model.createdAt,
    );
  }
}
