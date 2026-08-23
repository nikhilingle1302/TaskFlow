import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../../tasks/domain/repositories/task_repository.dart';
import '../../domain/repositories/project_repository.dart';
import 'project_state.dart';

export 'project_state.dart';

class ProjectCubit extends Cubit<ProjectState> {
  ProjectCubit({
    required ProjectRepository projectRepository,
    required TaskRepository taskRepository,
    required String orgId,
    required String role,
  })  : _projectRepository = projectRepository,
        _taskRepository = taskRepository,
        _orgId = orgId,
        _role = role,
        super(const ProjectInitial());

  final ProjectRepository _projectRepository;
  final TaskRepository _taskRepository;
  final String _orgId;
  final String _role;

  bool get isAdmin => _role == 'org_admin';

  Future<void> load() async {
    emit(const ProjectLoading());
    try {
      final projects = await _projectRepository.getProjects(_orgId);
      final tasks = await _taskRepository.getTasks(orgId: _orgId);

      if (projects.isEmpty) {
        emit(ProjectEmpty(isAdmin: isAdmin));
        return;
      }

      final items = projects.map((project) {
        final projectTasks =
            tasks.where((task) => task.projectId == project.id).toList();
        final doneCount =
            projectTasks.where((task) => task.status == 'done').length;
        return ProjectListItem(
          project: project,
          doneCount: doneCount,
          totalCount: projectTasks.length,
        );
      }).toList();

      emit(
        ProjectLoaded(
          items: items,
          filtered: items,
          query: '',
          isAdmin: isAdmin,
        ),
      );
    } on AppException catch (e) {
      emit(ProjectFailure(message: e.message));
    } catch (_) {
      emit(const ProjectFailure(message: 'Could not load projects.'));
    }
  }

  void search(String query) {
    final current = state;
    if (current is! ProjectLoaded) return;

    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      emit(current.copyWith(filtered: current.items, query: ''));
      return;
    }

    final filtered = current.items.where((item) {
      final project = item.project;
      return project.name.toLowerCase().contains(trimmed) ||
          project.description.toLowerCase().contains(trimmed);
    }).toList();

    emit(current.copyWith(filtered: filtered, query: query));
  }

  Future<void> createProject({
    required String name,
    required String description,
  }) async {
    final current = state;
    if (current is! ProjectLoaded && current is! ProjectEmpty) return;

    try {
      await _projectRepository.createProject(
        orgId: _orgId,
        name: name,
        description: description,
      );
      await load();
    } on AppException catch (e) {
      if (current is ProjectLoaded) {
        emit(ProjectActionFailure(message: e.message, previous: current));
        emit(current);
      }
    }
  }

  Future<void> updateProject({
    required String projectId,
    required String name,
    required String description,
  }) async {
    final current = state;

    try {
      final existing = current is ProjectLoaded
          ? current.items
              .firstWhere((item) => item.project.id == projectId)
              .project
          : await _projectRepository.getProjectById(
              orgId: _orgId,
              projectId: projectId,
            );

      await _projectRepository.updateProject(
        orgId: _orgId,
        project: existing.copyWith(name: name, description: description),
      );

      if (current is ProjectLoaded || current is ProjectEmpty) {
        await load();
      }
    } on AppException catch (e) {
      if (current is ProjectLoaded) {
        emit(ProjectActionFailure(message: e.message, previous: current));
        emit(current);
      } else {
        rethrow;
      }
    }
  }

  Future<void> deleteProject(String projectId) async {
    final current = state;

    try {
      await _projectRepository.deleteProject(
        orgId: _orgId,
        projectId: projectId,
        role: _role,
      );

      if (current is ProjectLoaded || current is ProjectEmpty) {
        await load();
      }
    } on AppException catch (e) {
      if (current is ProjectLoaded) {
        emit(ProjectActionFailure(message: e.message, previous: current));
        emit(current);
      } else {
        rethrow;
      }
    }
  }
}

extension on ProjectLoaded {
  ProjectLoaded copyWith({
    List<ProjectListItem>? items,
    List<ProjectListItem>? filtered,
    String? query,
    bool? isAdmin,
  }) {
    return ProjectLoaded(
      items: items ?? this.items,
      filtered: filtered ?? this.filtered,
      query: query ?? this.query,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
