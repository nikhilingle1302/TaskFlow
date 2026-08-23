import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/mock_data_store.dart';
import 'core/storage/app_preferences.dart';
import 'core/storage/session_storage.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/repositories/org_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/repositories/org_repository.dart';
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/notifications/domain/repositories/notification_repository.dart';
import 'features/projects/data/repositories/project_repository_impl.dart';
import 'features/projects/domain/repositories/project_repository.dart';
import 'features/tasks/data/repositories/task_repository_impl.dart';
import 'features/tasks/domain/repositories/task_repository.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);
  sl.registerLazySingleton<AppPreferences>(() => AppPreferences(sl()));

  final store = MockDataStore(sl());
  await store.load();
  sl.registerSingleton<MockDataStore>(store);
  sl.registerLazySingleton<SessionStorage>(() => SessionStorage());

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      store: sl(),
      sessionStorage: sl(),
    ),
  );
  sl.registerLazySingleton<OrgRepository>(
    () => OrgRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );
}
