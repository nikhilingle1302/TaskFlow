import 'package:get_it/get_it.dart';

import 'core/network/mock_data_store.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final store = MockDataStore();
  await store.load();
  sl.registerSingleton<MockDataStore>(store);
}
