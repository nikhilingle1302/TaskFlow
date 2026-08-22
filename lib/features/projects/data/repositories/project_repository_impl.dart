import 'package:uuid/uuid.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/mock_data_store.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../models/project_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl(this._store);

  final MockDataStore _store;
  final _uuid = const Uuid();

  @override
  Future<List<Project>> getProjects(String orgId) async {
    await _store.ensureLoaded();
    return _store.projects
        .where((p) => p.orgId == orgId)
        .map(_toEntity)
        .toList();
  }

  @override
  Future<Project> getProjectById(String projectId) async {
    await _store.ensureLoaded();
    try {
      return _toEntity(
        _store.projects.firstWhere((p) => p.id == projectId),
      );
    } catch (_) {
      throw NotFoundException('Project $projectId was not found.');
    }
  }

  @override
  Future<Project> createProject({
    required String orgId,
    required String name,
    required String description,
  }) async {
    await _store.ensureLoaded();

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
    return _toEntity(model);
  }

  @override
  Future<Project> updateProject(Project project) async {
    await _store.ensureLoaded();

    final index = _store.projects.indexWhere((p) => p.id == project.id);
    if (index < 0) {
      throw NotFoundException('Project ${project.id} was not found.');
    }

    final updated = _store.projects[index].copyWith(
      name: project.name,
      description: project.description,
      taskCount: project.taskCount,
      status: project.status,
    );
    final list = [..._store.projects];
    list[index] = updated;
    _store.projects = list;
    return _toEntity(updated);
  }

  @override
  Future<void> deleteProject({
    required String projectId,
    required String role,
  }) async {
    await _store.ensureLoaded();

    if (role != 'org_admin') {
      throw const ForbiddenException(
        'Only organization admins can delete projects.',
      );
    }

    final exists = _store.projects.any((p) => p.id == projectId);
    if (!exists) {
      throw NotFoundException('Project $projectId was not found.');
    }

    _store.projects =
        _store.projects.where((p) => p.id != projectId).toList();
    _store.tasks =
        _store.tasks.where((t) => t.projectId != projectId).toList();
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
