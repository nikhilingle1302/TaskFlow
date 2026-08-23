import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../../auth/domain/repositories/org_repository.dart';
import '../../../projects/domain/repositories/project_repository.dart';
import '../../domain/entities/task_item.dart';
import '../../domain/repositories/task_repository.dart';
import 'task_state.dart';

export 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit({
    required TaskRepository taskRepository,
    required ProjectRepository projectRepository,
    required OrgRepository orgRepository,
    required String orgId,
  })  : _taskRepository = taskRepository,
        _projectRepository = projectRepository,
        _orgRepository = orgRepository,
        _orgId = orgId,
        super(const TaskInitial());

  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;
  final OrgRepository _orgRepository;
  final String _orgId;

  Future<void> load() async {
    emit(const TaskLoading());
    try {
      final projects = await _projectRepository.getProjects(_orgId);
      final members = await _orgRepository.getMembers(_orgId);
      final tasks = await _taskRepository.getTasks(orgId: _orgId);

      if (tasks.isEmpty) {
        emit(TaskEmpty(projects: projects, members: members));
        return;
      }

      final projectNames = {
        for (final project in projects) project.id: project.name,
      };
      final memberMap = {for (final member in members) member.id: member};

      final items = tasks.map((task) {
        return TaskListItem(
          task: task,
          projectName: projectNames[task.projectId] ?? 'Unknown project',
          assignee: task.assigneeId == null
              ? null
              : memberMap[task.assigneeId],
        );
      }).toList();

      items.sort((a, b) {
        final aDue = a.task.dueDate;
        final bDue = b.task.dueDate;
        if (aDue == null && bDue == null) {
          return b.task.createdAt.compareTo(a.task.createdAt);
        }
        if (aDue == null) return 1;
        if (bDue == null) return -1;
        return aDue.compareTo(bDue);
      });

      final loaded = TaskLoaded(
        allItems: items,
        sections: const [],
        flatItems: const [],
        query: '',
        status: null,
        priority: null,
        projectId: null,
        assigneeId: null,
        projects: projects,
        members: members,
      );

      emit(_applyFilters(loaded));
    } on AppException catch (e) {
      emit(TaskFailure(message: e.message));
    } catch (_) {
      emit(const TaskFailure(message: 'Could not load tasks.'));
    }
  }

  void search(String query) {
    final current = state;
    if (current is! TaskLoaded) return;
    emit(_applyFilters(current.copyWith(query: query)));
  }

  void setStatus(String? status) {
    final current = state;
    if (current is! TaskLoaded) return;
    emit(
      _applyFilters(
        current.copyWith(
          status: status,
          clearStatus: status == null,
        ),
      ),
    );
  }

  void applyFilters({
    String? priority,
    String? projectId,
    String? assigneeId,
  }) {
    final current = state;
    if (current is! TaskLoaded) return;

    emit(
      _applyFilters(
        current.copyWith(
          priority: priority,
          projectId: projectId,
          assigneeId: assigneeId,
          clearPriority: priority == null,
          clearProjectId: projectId == null,
          clearAssigneeId: assigneeId == null,
        ),
      ),
    );
  }

  void clearFilters() {
    final current = state;
    if (current is! TaskLoaded) return;

    emit(
      _applyFilters(
        current.copyWith(
          clearPriority: true,
          clearProjectId: true,
          clearAssigneeId: true,
        ),
      ),
    );
  }

  TaskLoaded _applyFilters(TaskLoaded state) {
    final query = state.query.trim().toLowerCase();

    var filtered = state.allItems.where((item) {
      final task = item.task;

      if (state.status != null && task.status != state.status) {
        return false;
      }
      if (state.priority != null && task.priority != state.priority) {
        return false;
      }
      if (state.projectId != null && task.projectId != state.projectId) {
        return false;
      }
      if (state.assigneeId != null && task.assigneeId != state.assigneeId) {
        return false;
      }
      if (query.isNotEmpty) {
        final haystack =
            '${task.title} ${task.description} ${item.projectName}'.toLowerCase();
        if (!haystack.contains(query)) return false;
      }

      return true;
    }).toList();

    if (state.status == null) {
      return state.copyWith(
        sections: _groupByDate(filtered),
        flatItems: const [],
      );
    }

    return state.copyWith(
      sections: const [],
      flatItems: filtered,
    );
  }

  List<TaskSectionGroup> _groupByDate(List<TaskListItem> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final overdue = <TaskListItem>[];
    final todayItems = <TaskListItem>[];
    final upcoming = <TaskListItem>[];
    final done = <TaskListItem>[];

    for (final item in items) {
      final task = item.task;
      if (task.status == 'done') {
        done.add(item);
        continue;
      }

      final due = task.dueDate;
      if (due == null) {
        upcoming.add(item);
        continue;
      }

      final dueDay = DateTime(due.year, due.month, due.day);
      if (dueDay.isBefore(today)) {
        overdue.add(item);
      } else if (dueDay == today) {
        todayItems.add(item);
      } else {
        upcoming.add(item);
      }
    }

    final groups = <TaskSectionGroup>[];
    if (overdue.isNotEmpty) {
      groups.add(TaskSectionGroup(title: 'Overdue', items: overdue));
    }
    if (todayItems.isNotEmpty) {
      groups.add(TaskSectionGroup(title: 'Today', items: todayItems));
    }
    if (upcoming.isNotEmpty) {
      groups.add(TaskSectionGroup(title: 'Upcoming', items: upcoming));
    }
    if (done.isNotEmpty) {
      groups.add(TaskSectionGroup(title: 'Done', items: done));
    }

    return groups;
  }

  Future<String?> createTask({
    required String projectId,
    required String title,
    required String description,
    required String status,
    required String priority,
    String? assigneeId,
    DateTime? dueDate,
  }) async {
    final current = state;

    try {
      final task = await _taskRepository.createTask(
        orgId: _orgId,
        projectId: projectId,
        title: title,
        description: description,
        status: status,
        priority: priority,
        assigneeId: assigneeId,
        dueDate: dueDate,
      );
      await load();
      return task.id;
    } on AppException catch (e) {
      if (current is TaskLoaded || current is TaskEmpty) {
        emit(TaskActionFailure(message: e.message, previous: current));
        emit(current);
      }
      return null;
    }
  }

  Future<bool> updateTask({
    required TaskItem task,
  }) async {
    final current = state;

    try {
      await _taskRepository.updateTask(orgId: _orgId, task: task);
      if (current is TaskLoaded || current is TaskEmpty) {
        await load();
      }
      return true;
    } on AppException catch (e) {
      if (current is TaskLoaded) {
        emit(TaskActionFailure(message: e.message, previous: current));
        emit(current);
      }
      rethrow;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    final current = state;

    try {
      await _taskRepository.deleteTask(taskId);
      if (current is TaskLoaded || current is TaskEmpty) {
        await load();
      }
      return true;
    } on AppException catch (e) {
      if (current is TaskLoaded) {
        emit(TaskActionFailure(message: e.message, previous: current));
        emit(current);
      }
      rethrow;
    }
  }
}
