import '../entities/auth_session.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthSession> refreshSession(AuthSession current);

  Future<User?> findUserByEmail(String email);
}
