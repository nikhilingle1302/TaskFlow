import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/projects/data/models/project_model.dart';
import '../../features/tasks/data/models/task_model.dart';
import '../constants/app_constants.dart';

class OfflineCache {
  OfflineCache(this._prefs);

  final SharedPreferences _prefs;

  String _projectsKey(String orgId) => '${AppConstants.keyCachedProjects}_$orgId';

  String _tasksKey(String orgId) => '${AppConstants.keyCachedTasks}_$orgId';

  Future<void> saveProjects(String orgId, List<ProjectModel> projects) async {
    final payload = projects.map((project) => project.toJson()).toList();
    await _prefs.setString(_projectsKey(orgId), jsonEncode(payload));
    await _touchSync();
  }

  Future<void> saveTasks(String orgId, List<TaskModel> tasks) async {
    final payload = tasks.map((task) => task.toJson()).toList();
    await _prefs.setString(_tasksKey(orgId), jsonEncode(payload));
    await _touchSync();
  }

  List<ProjectModel>? loadProjects(String orgId) {
    final raw = _prefs.getString(_projectsKey(orgId));
    if (raw == null) return null;

    final list = jsonDecode(raw) as List;
    return list
        .map((item) => ProjectModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  List<TaskModel>? loadTasks(String orgId) {
    final raw = _prefs.getString(_tasksKey(orgId));
    if (raw == null) return null;

    final list = jsonDecode(raw) as List;
    return list
        .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  DateTime? get lastSyncAt {
    final raw = _prefs.getString(AppConstants.keyLastSyncAt);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  bool hasDataForOrg(String orgId) {
    return _prefs.containsKey(_projectsKey(orgId)) ||
        _prefs.containsKey(_tasksKey(orgId));
  }

  Future<void> _touchSync() async {
    await _prefs.setString(
      AppConstants.keyLastSyncAt,
      DateTime.now().toUtc().toIso8601String(),
    );
  }
}
