import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/repositories/org_repository.dart';
import '../../../projects/domain/repositories/project_repository.dart';
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
  })  : _taskRepository = taskRepository,
        _projectRepository = projectRepository,
        _orgRepository = orgRepository,
        _taskId = taskId,
        _orgId = orgId,
        super(const TaskDetailInitial());

  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;
  final OrgRepository _orgRepository;
  final String _taskId;
  final String _orgId;

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
          ),
        ),
      );
    } catch (_) {
      emit(const TaskDetailFailure(message: 'Could not load task.'));
    }
  }
}
