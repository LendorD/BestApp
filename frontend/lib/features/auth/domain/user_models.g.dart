// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      favoriteGame: json['favorite_game'] as String? ?? '',
      dotaAccountId: (json['dota_account_id'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastLoginAt: json['last_login_at'] == null
          ? null
          : DateTime.parse(json['last_login_at'] as String),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'bio': instance.bio,
      'favorite_game': instance.favoriteGame,
      'dota_account_id': instance.dotaAccountId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'last_login_at': instance.lastLoginAt?.toIso8601String(),
    };

_$AuthResponseImpl _$$AuthResponseImplFromJson(Map<String, dynamic> json) =>
    _$AuthResponseImpl(
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AuthResponseImplToJson(_$AuthResponseImpl instance) =>
    <String, dynamic>{'user': instance.user};

_$RegisterUserRequestImpl _$$RegisterUserRequestImplFromJson(
  Map<String, dynamic> json,
) => _$RegisterUserRequestImpl(
  email: json['email'] as String,
  username: json['username'] as String,
  password: json['password'] as String,
  displayName: json['display_name'] as String,
);

Map<String, dynamic> _$$RegisterUserRequestImplToJson(
  _$RegisterUserRequestImpl instance,
) => <String, dynamic>{
  'email': instance.email,
  'username': instance.username,
  'password': instance.password,
  'display_name': instance.displayName,
};

_$LoginUserRequestImpl _$$LoginUserRequestImplFromJson(
  Map<String, dynamic> json,
) => _$LoginUserRequestImpl(
  identity: json['identity'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$$LoginUserRequestImplToJson(
  _$LoginUserRequestImpl instance,
) => <String, dynamic>{
  'identity': instance.identity,
  'password': instance.password,
};

_$UpdateUserProfileRequestImpl _$$UpdateUserProfileRequestImplFromJson(
  Map<String, dynamic> json,
) => _$UpdateUserProfileRequestImpl(
  displayName: json['display_name'] as String,
  avatarUrl: json['avatar_url'] as String,
  bio: json['bio'] as String,
  favoriteGame: json['favorite_game'] as String,
  dotaAccountId: (json['dota_account_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$$UpdateUserProfileRequestImplToJson(
  _$UpdateUserProfileRequestImpl instance,
) => <String, dynamic>{
  'display_name': instance.displayName,
  'avatar_url': instance.avatarUrl,
  'bio': instance.bio,
  'favorite_game': instance.favoriteGame,
  'dota_account_id': instance.dotaAccountId,
};
