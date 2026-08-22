import 'dart:convert';

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

class MockDataStore {
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
}
