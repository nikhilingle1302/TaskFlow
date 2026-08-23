import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow/core/error/app_exception.dart';
import 'package:taskflow/core/storage/session_storage.dart';
import 'package:taskflow/features/auth/data/repositories/auth_repository_impl.dart';

import '../../helpers/test_data.dart';

void main() {
  late AuthRepositoryImpl repository;

  setUp(() async {
    final store = await createTestStore();
    repository = AuthRepositoryImpl(
      store: store,
      sessionStorage: SessionStorage(),
    );
  });

  group('AuthRepositoryImpl', () {
    test('login succeeds with mock admin credentials', () async {
      final session = await repository.login(
        email: 'ava.admin@nimbusdigital.test',
        password: 'Password123!',
      );

      expect(session.orgId, 'org_a1b2c3');
      expect(session.role, 'org_admin');
      expect(session.email, 'ava.admin@nimbusdigital.test');
    });

    test('login fails with wrong password', () async {
      expect(
        () => repository.login(
          email: 'ava.admin@nimbusdigital.test',
          password: 'wrong-password',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('refreshSession returns a new access token when access expired', () async {
      final session = await repository.login(
        email: 'ava.admin@nimbusdigital.test',
        password: 'Password123!',
      );

      final expired = session.copyWith(
        accessExpiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );

      final refreshed = await repository.refreshSession(expired);

      expect(refreshed.accessToken, isNot(expired.accessToken));
      expect(refreshed.userId, session.userId);
    });

    test('logout clears stored session', () async {
      await repository.login(
        email: 'ava.admin@nimbusdigital.test',
        password: 'Password123!',
      );

      await repository.logout();
      final restored = await repository.restoreSession();

      expect(restored, isNull);
    });
  });
}
