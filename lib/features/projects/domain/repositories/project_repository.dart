import '../entities/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getProjects(String orgId);

  Future<Project> getProjectById(String projectId);

  Future<Project> createProject({
    required String orgId,
    required String name,
    required String description,
  });

  Future<Project> updateProject(Project project);

  Future<void> deleteProject({
    required String projectId,
    required String role,
  });
}
