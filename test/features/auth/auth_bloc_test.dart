import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/auth/domain/entities/auth_session.dart';
import 'package:taskflow/features/auth/presentation/bloc/auth_bloc.dart';

import '../../helpers/fakes.dart';

AuthSession _fakeSession() {
  final now = DateTime.now();
  return AuthSession(
    userId: 'user_001',
    orgId: 'org_a1b2c3',
    role: 'org_admin',
    name: 'Ava',
    email: 'ava@test.com',
    accessToken: 'access',
    refreshToken: 'refresh',
    accessExpiresAt: now.add(const Duration(minutes: 15)),
    refreshExpiresAt: now.add(const Duration(days: 7)),
  );
}

void main() {
  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'emits authenticated when login succeeds',
      build: () {
        final repo = FakeAuthRepository(session: _fakeSession());
        return AuthBloc(repo);
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          email: 'ava@test.com',
          password: 'Password123!',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits unauthenticated when restore finds no session',
      build: () => AuthBloc(FakeAuthRepository()),
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });
}
