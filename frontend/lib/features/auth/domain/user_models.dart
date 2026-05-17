// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_models.freezed.dart';
part 'user_models.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required int id,
    required String email,
    required String username,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'avatar_url') @Default('') String avatarUrl,
    @Default('') String bio,
    @JsonKey(name: 'favorite_game') @Default('') String favoriteGame,
    @JsonKey(name: 'dota_account_id') int? dotaAccountId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'last_login_at') DateTime? lastLoginAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({required UserProfile user}) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

@freezed
class RegisterUserRequest with _$RegisterUserRequest {
  const factory RegisterUserRequest({
    required String email,
    required String username,
    required String password,
    @JsonKey(name: 'display_name') required String displayName,
  }) = _RegisterUserRequest;

  factory RegisterUserRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterUserRequestFromJson(json);
}

@freezed
class LoginUserRequest with _$LoginUserRequest {
  const factory LoginUserRequest({
    required String identity,
    required String password,
  }) = _LoginUserRequest;

  factory LoginUserRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginUserRequestFromJson(json);
}

@freezed
class UpdateUserProfileRequest with _$UpdateUserProfileRequest {
  const factory UpdateUserProfileRequest({
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'avatar_url') required String avatarUrl,
    required String bio,
    @JsonKey(name: 'favorite_game') required String favoriteGame,
    @JsonKey(name: 'dota_account_id') int? dotaAccountId,
  }) = _UpdateUserProfileRequest;

  factory UpdateUserProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserProfileRequestFromJson(json);
}
