// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthCredentialModel _$AuthCredentialModelFromJson(Map<String, dynamic> json) =>
    AuthCredentialModel(
      email: json['email'] as String,
      password: json['password'] as String,
      orgId: json['org_id'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$AuthCredentialModelToJson(
        AuthCredentialModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'org_id': instance.orgId,
      'role': instance.role,
    };

AuthTokenModel _$AuthTokenModelFromJson(Map<String, dynamic> json) =>
    AuthTokenModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      accessTokenExpiresInSeconds:
          (json['access_token_expires_in_seconds'] as num).toInt(),
      refreshTokenExpiresInSeconds:
          (json['refresh_token_expires_in_seconds'] as num).toInt(),
    );

Map<String, dynamic> _$AuthTokenModelToJson(AuthTokenModel instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'access_token_expires_in_seconds': instance.accessTokenExpiresInSeconds,
      'refresh_token_expires_in_seconds': instance.refreshTokenExpiresInSeconds,
    };
