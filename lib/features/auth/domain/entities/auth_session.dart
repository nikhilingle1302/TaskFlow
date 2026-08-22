class AuthSession {
  final String userId;
  final String orgId;
  final String role;
  final String name;
  final String email;
  final String? avatarUrl;
  final String accessToken;
  final String refreshToken;
  final DateTime accessExpiresAt;
  final DateTime refreshExpiresAt;

  const AuthSession({
    required this.userId,
    required this.orgId,
    required this.role,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
    required this.refreshExpiresAt,
  });

  bool get isAdmin => role == 'org_admin';

  bool get isAccessExpired => DateTime.now().isAfter(accessExpiresAt);

  bool get isRefreshExpired => DateTime.now().isAfter(refreshExpiresAt);

  AuthSession copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? accessExpiresAt,
    DateTime? refreshExpiresAt,
  }) {
    return AuthSession(
      userId: userId,
      orgId: orgId,
      role: role,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      accessExpiresAt: accessExpiresAt ?? this.accessExpiresAt,
      refreshExpiresAt: refreshExpiresAt ?? this.refreshExpiresAt,
    );
  }
}
