class AppConstants {
  static const String appName = 'TaskFlow';
  static const String mockDataAsset =
      'assets/mock_data/taskflow_mock_data.json';
  static const String apiBaseUrl = 'https://api.taskflow.local';

  static const double designWidth = 375;
  static const double designHeight = 812;

  static const String keyAccessToken = 'tf_access_token';
  static const String keyRefreshToken = 'tf_refresh_token';
  static const String keyAccessExpiry = 'tf_access_expiry';
  static const String keyRefreshExpiry = 'tf_refresh_expiry';
  static const String keyUserId = 'tf_user_id';
  static const String keyOrgId = 'tf_org_id';
  static const String keyRole = 'tf_role';
  static const String keyUserName = 'tf_user_name';
  static const String keyUserEmail = 'tf_user_email';
  static const String keyUserAvatar = 'tf_user_avatar';

  static const String keyOfflineMode = 'tf_offline_mode';
  static const String keySimulateError = 'tf_simulate_error';
  static const String keyCachedProjects = 'tf_cached_projects';
  static const String keyCachedTasks = 'tf_cached_tasks';
  static const String keyLastSyncAt = 'tf_last_sync_at';

  static const int minDelayMs = 300;
  static const int maxDelayMs = 700;

  static const String forceNotFoundTaskId = 'task_force_404';
  static const String forceTimeoutProjectId = 'proj_force_timeout';
}
