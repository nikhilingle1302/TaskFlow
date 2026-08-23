import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow/core/network/mock_data_store.dart';
import 'package:taskflow/core/storage/app_preferences.dart';
import 'package:taskflow/core/storage/offline_cache.dart';

class TestEnvironment {
  TestEnvironment({
    required this.store,
    required this.preferences,
    required this.cache,
  });

  final MockDataStore store;
  final AppPreferences preferences;
  final OfflineCache cache;
}

Future<TestEnvironment> createTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  FlutterSecureStorage.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  final preferences = AppPreferences(sharedPreferences);
  final cache = OfflineCache(sharedPreferences);
  final store = MockDataStore(preferences);
  await store.load();
  return TestEnvironment(store: store, preferences: preferences, cache: cache);
}

Future<MockDataStore> createTestStore() async {
  final env = await createTestEnvironment();
  return env.store;
}
