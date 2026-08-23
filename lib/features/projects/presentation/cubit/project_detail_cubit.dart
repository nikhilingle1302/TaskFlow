import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/repositories/org_repository.dart';
import '../../../tasks/domain/entities/comment.dart';
import '../../../tasks/domain/repositories/task_repository.dart';
import '../../domain/repositories/project_repository.dart';
import 'project_detail_state.dart';

export 'project_detail_state.dart';

class ProjectDetailCubit extends Cubit<ProjectDetailState> {
  ProjectDetailCubit({
    required ProjectRepository projectRepository,
    required TaskRepository taskRepository,
    required OrgRepository orgRepository,
    required String projectId,
    required String orgId,
    required String role,
  })  : _projectRepository = projectRepository,
        _taskRepository = taskRepository,
        _orgRepository = orgRepository,
        _projectId = projectId,
        _orgId = orgId,
        _role = role,
        super(const ProjectDetailInitial());

  final ProjectRepository _projectRepository;
  final TaskRepository _taskRepository;
  final OrgRepository _orgRepository;
  final String _projectId;
  final String _orgId;
  final String _role;

  Future<void> load() async {
    emit(const ProjectDetailLoading());
    try {
      final project = await _projectRepository.getProjectById(_projectId);
      final tasks =
          await _taskRepository.getTasks(orgId: _orgId, projectId: _projectId);
      final members = await _orgRepository.getMembers(_orgId);

      final summary = <String, int>{
        'todo': 0,
        'in_progress': 0,
        'review': 0,
        'done': 0,
      };
      for (final task in tasks) {
        summary[task.status] = (summary[task.status] ?? 0) + 1;
      }

      final comments = <Comment>[];
      for (final task in tasks) {
        final taskComments = await _taskRepository.getComments(task.id);
        comments.addAll(taskComments);
      }
      comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(
        ProjectDetailLoaded(
          ProjectDetailData(
            project: project,
            taskSummary: summary,
            tasks: tasks,
            members: members,
            comments: comments,
            isAdmin: _role == 'org_admin',
          ),
        ),
      );
    } catch (_) {
      emit(const ProjectDetailFailure(message: 'Could not load project.'));
    }
  }
}
