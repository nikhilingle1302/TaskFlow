import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/auth/domain/entities/auth_session.dart';

AuthSession _session({
  DateTime? accessExpiresAt,
  DateTime? refreshExpiresAt,
}) {
  final now = DateTime.now();
  return AuthSession(
    userId: 'user_001',
    orgId: 'org_a1b2c3',
    role: 'org_admin',
    name: 'Ava',
    email: 'ava@test.com',
    accessToken: 'access',
    refreshToken: 'refresh',
    accessExpiresAt: accessExpiresAt ?? now.add(const Duration(minutes: 15)),
    refreshExpiresAt: refreshExpiresAt ?? now.add(const Duration(days: 7)),
  );
}

void main() {
  group('AuthSession', () {
    test('isAccessExpired is true when access token time passed', () {
      final session = _session(
        accessExpiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );

      expect(session.isAccessExpired, isTrue);
    });

    test('isRefreshExpired is true when refresh token time passed', () {
      final session = _session(
        refreshExpiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(session.isRefreshExpired, isTrue);
    });

    test('copyWith keeps user data and updates tokens', () {
      final session = _session();
      final updated = session.copyWith(accessToken: 'new-access');

      expect(updated.accessToken, 'new-access');
      expect(updated.userId, session.userId);
      expect(updated.email, session.email);
    });
  });
}
