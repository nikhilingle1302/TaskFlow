import '../entities/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getProjects(String orgId);

  Future<Project> getProjectById({
    required String orgId,
    required String projectId,
  });

  Future<Project> createProject({
    required String orgId,
    required String name,
    required String description,
  });

  Future<Project> updateProject({
    required String orgId,
    required Project project,
  });

  Future<void> deleteProject({
    required String orgId,
    required String projectId,
    required String role,
  });
}
