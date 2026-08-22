import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';
import '../../features/auth/domain/entities/auth_session.dart';

class SessionStorage {
  SessionStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> save(AuthSession session) async {
    await Future.wait([
      _storage.write(
        key: AppConstants.keyAccessToken,
        value: session.accessToken,
      ),
      _storage.write(
        key: AppConstants.keyRefreshToken,
        value: session.refreshToken,
      ),
      _storage.write(
        key: AppConstants.keyAccessExpiry,
        value: session.accessExpiresAt.toIso8601String(),
      ),
      _storage.write(
        key: AppConstants.keyRefreshExpiry,
        value: session.refreshExpiresAt.toIso8601String(),
      ),
      _storage.write(key: AppConstants.keyUserId, value: session.userId),
      _storage.write(key: AppConstants.keyOrgId, value: session.orgId),
      _storage.write(key: AppConstants.keyRole, value: session.role),
      _storage.write(key: AppConstants.keyUserName, value: session.name),
      _storage.write(key: AppConstants.keyUserEmail, value: session.email),
      _storage.write(
        key: AppConstants.keyUserAvatar,
        value: session.avatarUrl ?? '',
      ),
    ]);
  }

  Future<AuthSession?> read() async {
    final values = await Future.wait([
      _storage.read(key: AppConstants.keyAccessToken),
      _storage.read(key: AppConstants.keyRefreshToken),
      _storage.read(key: AppConstants.keyAccessExpiry),
      _storage.read(key: AppConstants.keyRefreshExpiry),
      _storage.read(key: AppConstants.keyUserId),
      _storage.read(key: AppConstants.keyOrgId),
      _storage.read(key: AppConstants.keyRole),
      _storage.read(key: AppConstants.keyUserName),
      _storage.read(key: AppConstants.keyUserEmail),
      _storage.read(key: AppConstants.keyUserAvatar),
    ]);

    final access = values[0];
    final refresh = values[1];
    final accessExp = values[2];
    final refreshExp = values[3];
    final userId = values[4];
    final orgId = values[5];
    final role = values[6];
    final name = values[7];
    final email = values[8];
    final avatar = values[9];

    if (access == null ||
        refresh == null ||
        accessExp == null ||
        refreshExp == null ||
        userId == null ||
        orgId == null ||
        role == null ||
        name == null ||
        email == null) {
      return null;
    }

    return AuthSession(
      userId: userId,
      orgId: orgId,
      role: role,
      name: name,
      email: email,
      avatarUrl: (avatar == null || avatar.isEmpty) ? null : avatar,
      accessToken: access,
      refreshToken: refresh,
      accessExpiresAt: DateTime.parse(accessExp),
      refreshExpiresAt: DateTime.parse(refreshExp),
    );
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: AppConstants.keyAccessToken),
      _storage.delete(key: AppConstants.keyRefreshToken),
      _storage.delete(key: AppConstants.keyAccessExpiry),
      _storage.delete(key: AppConstants.keyRefreshExpiry),
      _storage.delete(key: AppConstants.keyUserId),
      _storage.delete(key: AppConstants.keyOrgId),
      _storage.delete(key: AppConstants.keyRole),
      _storage.delete(key: AppConstants.keyUserName),
      _storage.delete(key: AppConstants.keyUserEmail),
      _storage.delete(key: AppConstants.keyUserAvatar),
    ]);
  }
}
