import 'package:uuid/uuid.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/mock_data_store.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required MockDataStore store,
    required SessionStorage sessionStorage,
  })  : _store = store,
        _sessionStorage = sessionStorage;

  final MockDataStore _store;
  final SessionStorage _sessionStorage;
  final _uuid = const Uuid();

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await _store.ensureLoaded();

    AuthCredentialModel? match;
    for (final credential in _store.credentials) {
      if (credential.email.toLowerCase() == email.trim().toLowerCase() &&
          credential.password == password) {
        match = credential;
        break;
      }
    }

    if (match == null) {
      throw const AuthException('Invalid email or password.');
    }

    final user = _store.users.firstWhere(
      (u) => u.email.toLowerCase() == match!.email.toLowerCase(),
    );

    final session =
        _sessionFrom(user: user, orgId: match.orgId, role: match.role);
    await _sessionStorage.save(session);
    return session;
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _store.ensureLoaded();

    final exists = _store.users.any(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
    );
    if (exists) {
      throw const AuthException('An account with that email already exists.');
    }

    final user = UserModel(
      id: 'user_${_uuid.v4().substring(0, 8)}',
      name: name.trim(),
      email: email.trim().toLowerCase(),
    );
    _store.users = [..._store.users, user];

    final orgId = _store.organizations.first.id;
    _store.credentials = [
      ..._store.credentials,
      AuthCredentialModel(
        email: user.email,
        password: password,
        orgId: orgId,
        role: 'member',
      ),
    ];

    final session =
        _sessionFrom(user: user, orgId: orgId, role: 'member');
    await _sessionStorage.save(session);
    return session;
  }

  @override
  Future<AuthSession?> restoreSession() async {
    await _store.ensureLoaded();
    final stored = await _sessionStorage.read();
    if (stored == null) return null;

    if (stored.isRefreshExpired) {
      await _sessionStorage.clear();
      return null;
    }

    if (stored.isAccessExpired) {
      return refreshSession(stored);
    }

    return stored;
  }

  @override
  Future<AuthSession> refreshSession(AuthSession current) async {
    await _store.ensureLoaded();

    if (current.isRefreshExpired) {
      await _sessionStorage.clear();
      throw const AuthException('Session expired. Please sign in again.');
    }

    final now = DateTime.now();
    final token = _store.tokenTemplate;
    final refreshed = current.copyWith(
      accessToken: '${token.accessToken}.${now.millisecondsSinceEpoch}',
      accessExpiresAt: now.add(
        Duration(seconds: token.accessTokenExpiresInSeconds),
      ),
    );
    await _sessionStorage.save(refreshed);
    return refreshed;
  }

  @override
  Future<void> logout() async {
    await _sessionStorage.clear();
  }

  @override
  Future<User?> findUserByEmail(String email) async {
    await _store.ensureLoaded();
    try {
      final model = _store.users.firstWhere(
        (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
      );
      return _toUser(model);
    } catch (_) {
      return null;
    }
  }

  AuthSession _sessionFrom({
    required UserModel user,
    required String orgId,
    required String role,
  }) {
    final now = DateTime.now();
    final token = _store.tokenTemplate;
    return AuthSession(
      userId: user.id,
      orgId: orgId,
      role: role,
      name: user.name,
      email: user.email,
      avatarUrl: user.avatarUrl,
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
      accessExpiresAt:
          now.add(Duration(seconds: token.accessTokenExpiresInSeconds)),
      refreshExpiresAt:
          now.add(Duration(seconds: token.refreshTokenExpiresInSeconds)),
    );
  }

  User _toUser(UserModel model) {
    return User(
      id: model.id,
      name: model.name,
      email: model.email,
      avatarUrl: model.avatarUrl,
    );
  }
}
