import 'package:taskflow/features/auth/domain/entities/auth_session.dart';
import 'package:taskflow/features/auth/domain/entities/user.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:taskflow/features/auth/domain/repositories/org_repository.dart';
import 'package:taskflow/features/auth/domain/entities/org_member.dart';
import 'package:taskflow/features/projects/domain/entities/organization.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/domain/repositories/project_repository.dart';
import 'package:taskflow/features/tasks/domain/entities/comment.dart';
import 'package:taskflow/features/tasks/domain/entities/task_item.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.session});

  AuthSession? session;
  int loginCalls = 0;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    if (session != null) return session!;
    throw Exception('Invalid credentials');
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<AuthSession?> restoreSession() async => session;

  @override
  Future<AuthSession> refreshSession(AuthSession current) async => current;

  @override
  Future<void> logout() async {
    session = null;
  }

  @override
  Future<User?> findUserByEmail(String email) async => null;
}

class FakeProjectRepository implements ProjectRepository {
  FakeProjectRepository(this.projects);

  final List<Project> projects;

  @override
  Future<List<Project>> getProjects(String orgId) async =>
      projects.where((p) => p.orgId == orgId).toList();

  @override
  Future<Project> getProjectById({
    required String orgId,
    required String projectId,
  }) async =>
      projects.firstWhere((p) => p.id == projectId && p.orgId == orgId);

  @override
  Future<Project> createProject({
    required String orgId,
    required String name,
    required String description,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Project> updateProject({
    required String orgId,
    required Project project,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteProject({
    required String orgId,
    required String projectId,
    required String role,
  }) async {}
}

class FakeOrgRepository implements OrgRepository {
  FakeOrgRepository(this.members);

  final List<User> members;

  @override
  Future<Organization?> getOrganization(String orgId) async => null;

  @override
  Future<List<User>> getMembers(String orgId) async => members;

  @override
  Future<OrgMember?> getMembership({
    required String orgId,
    required String userId,
  }) async =>
      null;

  @override
  bool isUserInOrg({required String orgId, required String userId}) =>
      members.any((m) => m.id == userId);
}

class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository(this.tasks);

  final List<TaskItem> tasks;

  @override
  Future<List<TaskItem>> getTasks({
    required String orgId,
    String? projectId,
    TaskFilter filter = const TaskFilter(),
  }) async {
    var list = tasks;
    if (projectId != null) {
      list = list.where((t) => t.projectId == projectId).toList();
    }
    if (filter.status != null) {
      list = list.where((t) => t.status == filter.status).toList();
    }
    return list;
  }

  @override
  Future<TaskItem> getTaskById({
    required String orgId,
    required String taskId,
  }) async =>
      tasks.firstWhere((t) => t.id == taskId);

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
  }) async =>
      throw UnimplementedError();

  @override
  Future<TaskItem> updateTask({
    required String orgId,
    required TaskItem task,
  }) async =>
      task;

  @override
  Future<void> deleteTask({
    required String orgId,
    required String taskId,
  }) async {}

  @override
  Future<TaskItem> assignTask({
    required String orgId,
    required String taskId,
    required String? userId,
  }) async =>
      throw UnimplementedError();

  @override
  Future<List<Comment>> getComments(String taskId) async => [];

  @override
  Future<Comment> addComment({
    required String taskId,
    required String authorId,
    required String body,
  }) async =>
      throw UnimplementedError();
}

final sampleProjects = [
  Project(
    id: 'proj_1001',
    orgId: 'org_a1b2c3',
    name: 'Website Relaunch',
    description: 'Marketing site',
    taskCount: 2,
    status: 'active',
    createdAt: DateTime.utc(2025, 12, 1),
  ),
];

final sampleMembers = [
  const User(id: 'user_001', name: 'Ava', email: 'ava@test.com'),
  const User(id: 'user_002', name: 'Marcus', email: 'marcus@test.com'),
];

final sampleTasks = [
  TaskItem(
    id: 'task_1',
    projectId: 'proj_1001',
    title: 'Write copy',
    description: 'Homepage text',
    status: 'todo',
    priority: 'high',
    assigneeId: 'user_002',
    dueDate: DateTime.utc(2026, 3, 1),
    createdAt: DateTime.utc(2026, 1, 1),
  ),
  TaskItem(
    id: 'task_2',
    projectId: 'proj_1001',
    title: 'Ship feature',
    description: 'Release block',
    status: 'done',
    priority: 'medium',
    assigneeId: null,
    dueDate: null,
    createdAt: DateTime.utc(2026, 1, 2),
  ),
];
