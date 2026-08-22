import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class AuthCredentialModel {
  final String email;
  final String password;
  @JsonKey(name: 'org_id')
  final String orgId;
  final String role;

  const AuthCredentialModel({
    required this.email,
    required this.password,
    required this.orgId,
    required this.role,
  });

  factory AuthCredentialModel.fromJson(Map<String, dynamic> json) =>
      _$AuthCredentialModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthCredentialModelToJson(this);
}

@JsonSerializable()
class AuthTokenModel {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  @JsonKey(name: 'access_token_expires_in_seconds')
  final int accessTokenExpiresInSeconds;
  @JsonKey(name: 'refresh_token_expires_in_seconds')
  final int refreshTokenExpiresInSeconds;

  const AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresInSeconds,
    required this.refreshTokenExpiresInSeconds,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokenModelToJson(this);
}
