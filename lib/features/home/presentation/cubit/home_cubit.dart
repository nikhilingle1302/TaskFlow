import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../projects/domain/repositories/project_repository.dart';
import '../../../tasks/domain/entities/task_item.dart';
import '../../../tasks/domain/repositories/task_repository.dart';
import 'home_state.dart';

export 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required ProjectRepository projectRepository,
    required TaskRepository taskRepository,
    required String orgId,
    required String userName,
  })  : _projectRepository = projectRepository,
        _taskRepository = taskRepository,
        _orgId = orgId,
        _userName = userName,
        super(const HomeInitial());

  final ProjectRepository _projectRepository;
  final TaskRepository _taskRepository;
  final String _orgId;
  final String _userName;

  Future<void> load() async {
    emit(const HomeLoading());
    try {
      final projects = await _projectRepository.getProjects(_orgId);
      final tasks = await _taskRepository.getTasks(orgId: _orgId);
      final overdueCount = _countOverdue(tasks);

      if (projects.isEmpty) {
        emit(HomeEmpty(userName: _userName));
        return;
      }

      final items = projects.map((project) {
        final projectTasks =
            tasks.where((task) => task.projectId == project.id).toList();
        final doneCount =
            projectTasks.where((task) => task.status == 'done').length;
        return HomeProjectItem(
          project: project,
          doneCount: doneCount,
          totalCount: projectTasks.length,
        );
      }).toList();

      emit(
        HomeLoaded(
          userName: _userName,
          projectCount: projects.length,
          taskCount: tasks.length,
          overdueCount: overdueCount,
          projects: items,
        ),
      );
    } catch (_) {
      emit(const HomeFailure(message: 'Could not load dashboard data.'));
    }
  }

  int _countOverdue(List<TaskItem> tasks) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    return tasks.where((task) {
      if (task.status == 'done') return false;
      final due = task.dueDate;
      if (due == null) return false;
      final dueDay = DateTime(due.year, due.month, due.day);
      return dueDay.isBefore(startOfToday);
    }).length;
  }
}
