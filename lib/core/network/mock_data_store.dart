import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../../features/auth/data/models/auth_models.dart';
import '../../features/auth/data/models/org_member_model.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/notifications/data/models/notification_model.dart';
import '../../features/projects/data/models/organization_model.dart';
import '../../features/projects/data/models/project_model.dart';
import '../../features/tasks/data/models/comment_model.dart';
import '../../features/tasks/data/models/task_model.dart';
import '../constants/app_constants.dart';
import '../error/app_exception.dart';
import '../storage/app_preferences.dart';

class MockDataStore {
  MockDataStore(this._preferences);

  final AppPreferences _preferences;
  final _random = Random();

  bool _loaded = false;

  List<OrganizationModel> organizations = [];
  List<UserModel> users = [];
  List<OrgMemberModel> orgMembers = [];
  List<ProjectModel> projects = [];
  List<TaskModel> tasks = [];
  List<CommentModel> comments = [];
  List<NotificationModel> notifications = [];
  List<AuthCredentialModel> credentials = [];
  late AuthTokenModel tokenTemplate;

  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;

    final raw = await rootBundle.loadString(AppConstants.mockDataAsset);
    final map = jsonDecode(raw) as Map<String, dynamic>;

    organizations = (map['organizations'] as List)
        .map((e) => OrganizationModel.fromJson(e as Map<String, dynamic>))
        .toList();
    users = (map['users'] as List)
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
    orgMembers = (map['org_members'] as List)
        .map((e) => OrgMemberModel.fromJson(e as Map<String, dynamic>))
        .toList();
    projects = (map['projects'] as List)
        .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
        .toList();
    tasks = (map['tasks'] as List)
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
    comments = (map['comments'] as List)
        .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
        .toList();
    notifications = (map['notifications'] as List)
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final auth = map['auth_mock'] as Map<String, dynamic>;
    credentials = (auth['test_credentials'] as List)
        .map((e) => AuthCredentialModel.fromJson(e as Map<String, dynamic>))
        .toList();
    tokenTemplate = AuthTokenModel.fromJson(
      auth['mock_login_response'] as Map<String, dynamic>,
    );

    _loaded = true;
  }

  Future<void> ensureLoaded() async {
    if (!_loaded) {
      await load();
    }
  }

  Future<void> simulateRequest({bool isWrite = false}) async {
    final delay = AppConstants.minDelayMs +
        _random.nextInt(AppConstants.maxDelayMs - AppConstants.minDelayMs);
    await Future<void>.delayed(Duration(milliseconds: delay));

    if (_preferences.simulateError) {
      throw const NetworkException(
        'Unable to reach TaskFlow right now. Please try again.',
      );
    }

    if (_preferences.offlineMode && isWrite) {
      throw const OfflineException(
        'You are offline. Changes will sync when you reconnect.',
      );
    }
  }

  void applyOrgCache({
    required String orgId,
    List<ProjectModel>? projects,
    List<TaskModel>? tasks,
  }) {
    if (projects != null) {
      final otherProjects = this.projects.where((p) => p.orgId != orgId);
      this.projects = [...otherProjects, ...projects];
    }

    if (tasks != null) {
      final orgProjectIds = this.projects
          .where((project) => project.orgId == orgId)
          .map((project) => project.id)
          .toSet();
      final otherTasks =
          this.tasks.where((task) => !orgProjectIds.contains(task.projectId));
      this.tasks = [...otherTasks, ...tasks];
    }
  }

  List<ProjectModel> projectsForOrg(String orgId) {
    return projects.where((project) => project.orgId == orgId).toList();
  }

  List<TaskModel> tasksForOrg(String orgId) {
    final projectIds =
        projects.where((p) => p.orgId == orgId).map((p) => p.id).toSet();
    return tasks.where((task) => projectIds.contains(task.projectId)).toList();
  }
}
