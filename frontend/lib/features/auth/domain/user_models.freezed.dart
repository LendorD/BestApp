// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  int get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_name')
  String get displayName => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_url')
  String get avatarUrl => throw _privateConstructorUsedError;
  String get bio => throw _privateConstructorUsedError;
  @JsonKey(name: 'favorite_game')
  String get favoriteGame => throw _privateConstructorUsedError;
  @JsonKey(name: 'dota_account_id')
  int? get dotaAccountId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_login_at')
  DateTime? get lastLoginAt => throw _privateConstructorUsedError;

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
    UserProfile value,
    $Res Function(UserProfile) then,
  ) = _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call({
    int id,
    String email,
    String username,
    @JsonKey(name: 'display_name') String displayName,
    @JsonKey(name: 'avatar_url') String avatarUrl,
    String bio,
    @JsonKey(name: 'favorite_game') String favoriteGame,
    @JsonKey(name: 'dota_account_id') int? dotaAccountId,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    @JsonKey(name: 'last_login_at') DateTime? lastLoginAt,
  });
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? username = null,
    Object? displayName = null,
    Object? avatarUrl = null,
    Object? bio = null,
    Object? favoriteGame = null,
    Object? dotaAccountId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastLoginAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarUrl: null == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            bio: null == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String,
            favoriteGame: null == favoriteGame
                ? _value.favoriteGame
                : favoriteGame // ignore: cast_nullable_to_non_nullable
                      as String,
            dotaAccountId: freezed == dotaAccountId
                ? _value.dotaAccountId
                : dotaAccountId // ignore: cast_nullable_to_non_nullable
                      as int?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastLoginAt: freezed == lastLoginAt
                ? _value.lastLoginAt
                : lastLoginAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
    _$UserProfileImpl value,
    $Res Function(_$UserProfileImpl) then,
  ) = __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String email,
    String username,
    @JsonKey(name: 'display_name') String displayName,
    @JsonKey(name: 'avatar_url') String avatarUrl,
    String bio,
    @JsonKey(name: 'favorite_game') String favoriteGame,
    @JsonKey(name: 'dota_account_id') int? dotaAccountId,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    @JsonKey(name: 'last_login_at') DateTime? lastLoginAt,
  });
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
    _$UserProfileImpl _value,
    $Res Function(_$UserProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? username = null,
    Object? displayName = null,
    Object? avatarUrl = null,
    Object? bio = null,
    Object? favoriteGame = null,
    Object? dotaAccountId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastLoginAt = freezed,
  }) {
    return _then(
      _$UserProfileImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarUrl: null == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        bio: null == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String,
        favoriteGame: null == favoriteGame
            ? _value.favoriteGame
            : favoriteGame // ignore: cast_nullable_to_non_nullable
                  as String,
        dotaAccountId: freezed == dotaAccountId
            ? _value.dotaAccountId
            : dotaAccountId // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastLoginAt: freezed == lastLoginAt
            ? _value.lastLoginAt
            : lastLoginAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl({
    required this.id,
    required this.email,
    required this.username,
    @JsonKey(name: 'display_name') required this.displayName,
    @JsonKey(name: 'avatar_url') this.avatarUrl = '',
    this.bio = '',
    @JsonKey(name: 'favorite_game') this.favoriteGame = '',
    @JsonKey(name: 'dota_account_id') this.dotaAccountId,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
    @JsonKey(name: 'last_login_at') this.lastLoginAt,
  });

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final int id;
  @override
  final String email;
  @override
  final String username;
  @override
  @JsonKey(name: 'display_name')
  final String displayName;
  @override
  @JsonKey(name: 'avatar_url')
  final String avatarUrl;
  @override
  @JsonKey()
  final String bio;
  @override
  @JsonKey(name: 'favorite_game')
  final String favoriteGame;
  @override
  @JsonKey(name: 'dota_account_id')
  final int? dotaAccountId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @override
  @JsonKey(name: 'last_login_at')
  final DateTime? lastLoginAt;

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, bio: $bio, favoriteGame: $favoriteGame, dotaAccountId: $dotaAccountId, createdAt: $createdAt, updatedAt: $updatedAt, lastLoginAt: $lastLoginAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.favoriteGame, favoriteGame) ||
                other.favoriteGame == favoriteGame) &&
            (identical(other.dotaAccountId, dotaAccountId) ||
                other.dotaAccountId == dotaAccountId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    email,
    username,
    displayName,
    avatarUrl,
    bio,
    favoriteGame,
    dotaAccountId,
    createdAt,
    updatedAt,
    lastLoginAt,
  );

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(this);
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile({
    required final int id,
    required final String email,
    required final String username,
    @JsonKey(name: 'display_name') required final String displayName,
    @JsonKey(name: 'avatar_url') final String avatarUrl,
    final String bio,
    @JsonKey(name: 'favorite_game') final String favoriteGame,
    @JsonKey(name: 'dota_account_id') final int? dotaAccountId,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
    @JsonKey(name: 'last_login_at') final DateTime? lastLoginAt,
  }) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  int get id;
  @override
  String get email;
  @override
  String get username;
  @override
  @JsonKey(name: 'display_name')
  String get displayName;
  @override
  @JsonKey(name: 'avatar_url')
  String get avatarUrl;
  @override
  String get bio;
  @override
  @JsonKey(name: 'favorite_game')
  String get favoriteGame;
  @override
  @JsonKey(name: 'dota_account_id')
  int? get dotaAccountId;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(name: 'last_login_at')
  DateTime? get lastLoginAt;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) {
  return _AuthResponse.fromJson(json);
}

/// @nodoc
mixin _$AuthResponse {
  UserProfile get user => throw _privateConstructorUsedError;

  /// Serializes this AuthResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthResponseCopyWith<AuthResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResponseCopyWith<$Res> {
  factory $AuthResponseCopyWith(
    AuthResponse value,
    $Res Function(AuthResponse) then,
  ) = _$AuthResponseCopyWithImpl<$Res, AuthResponse>;
  @useResult
  $Res call({UserProfile user});

  $UserProfileCopyWith<$Res> get user;
}

/// @nodoc
class _$AuthResponseCopyWithImpl<$Res, $Val extends AuthResponse>
    implements $AuthResponseCopyWith<$Res> {
  _$AuthResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? user = null}) {
    return _then(
      _value.copyWith(
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as UserProfile,
          )
          as $Val,
    );
  }

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserProfileCopyWith<$Res> get user {
    return $UserProfileCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthResponseImplCopyWith<$Res>
    implements $AuthResponseCopyWith<$Res> {
  factory _$$AuthResponseImplCopyWith(
    _$AuthResponseImpl value,
    $Res Function(_$AuthResponseImpl) then,
  ) = __$$AuthResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({UserProfile user});

  @override
  $UserProfileCopyWith<$Res> get user;
}

/// @nodoc
class __$$AuthResponseImplCopyWithImpl<$Res>
    extends _$AuthResponseCopyWithImpl<$Res, _$AuthResponseImpl>
    implements _$$AuthResponseImplCopyWith<$Res> {
  __$$AuthResponseImplCopyWithImpl(
    _$AuthResponseImpl _value,
    $Res Function(_$AuthResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? user = null}) {
    return _then(
      _$AuthResponseImpl(
        user: null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as UserProfile,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthResponseImpl implements _AuthResponse {
  const _$AuthResponseImpl({required this.user});

  factory _$AuthResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthResponseImplFromJson(json);

  @override
  final UserProfile user;

  @override
  String toString() {
    return 'AuthResponse(user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResponseImpl &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, user);

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResponseImplCopyWith<_$AuthResponseImpl> get copyWith =>
      __$$AuthResponseImplCopyWithImpl<_$AuthResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthResponseImplToJson(this);
  }
}

abstract class _AuthResponse implements AuthResponse {
  const factory _AuthResponse({required final UserProfile user}) =
      _$AuthResponseImpl;

  factory _AuthResponse.fromJson(Map<String, dynamic> json) =
      _$AuthResponseImpl.fromJson;

  @override
  UserProfile get user;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthResponseImplCopyWith<_$AuthResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RegisterUserRequest _$RegisterUserRequestFromJson(Map<String, dynamic> json) {
  return _RegisterUserRequest.fromJson(json);
}

/// @nodoc
mixin _$RegisterUserRequest {
  String get email => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_name')
  String get displayName => throw _privateConstructorUsedError;

  /// Serializes this RegisterUserRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RegisterUserRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegisterUserRequestCopyWith<RegisterUserRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterUserRequestCopyWith<$Res> {
  factory $RegisterUserRequestCopyWith(
    RegisterUserRequest value,
    $Res Function(RegisterUserRequest) then,
  ) = _$RegisterUserRequestCopyWithImpl<$Res, RegisterUserRequest>;
  @useResult
  $Res call({
    String email,
    String username,
    String password,
    @JsonKey(name: 'display_name') String displayName,
  });
}

/// @nodoc
class _$RegisterUserRequestCopyWithImpl<$Res, $Val extends RegisterUserRequest>
    implements $RegisterUserRequestCopyWith<$Res> {
  _$RegisterUserRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegisterUserRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? username = null,
    Object? password = null,
    Object? displayName = null,
  }) {
    return _then(
      _value.copyWith(
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RegisterUserRequestImplCopyWith<$Res>
    implements $RegisterUserRequestCopyWith<$Res> {
  factory _$$RegisterUserRequestImplCopyWith(
    _$RegisterUserRequestImpl value,
    $Res Function(_$RegisterUserRequestImpl) then,
  ) = __$$RegisterUserRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String email,
    String username,
    String password,
    @JsonKey(name: 'display_name') String displayName,
  });
}

/// @nodoc
class __$$RegisterUserRequestImplCopyWithImpl<$Res>
    extends _$RegisterUserRequestCopyWithImpl<$Res, _$RegisterUserRequestImpl>
    implements _$$RegisterUserRequestImplCopyWith<$Res> {
  __$$RegisterUserRequestImplCopyWithImpl(
    _$RegisterUserRequestImpl _value,
    $Res Function(_$RegisterUserRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RegisterUserRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? username = null,
    Object? password = null,
    Object? displayName = null,
  }) {
    return _then(
      _$RegisterUserRequestImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RegisterUserRequestImpl implements _RegisterUserRequest {
  const _$RegisterUserRequestImpl({
    required this.email,
    required this.username,
    required this.password,
    @JsonKey(name: 'display_name') required this.displayName,
  });

  factory _$RegisterUserRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$RegisterUserRequestImplFromJson(json);

  @override
  final String email;
  @override
  final String username;
  @override
  final String password;
  @override
  @JsonKey(name: 'display_name')
  final String displayName;

  @override
  String toString() {
    return 'RegisterUserRequest(email: $email, username: $username, password: $password, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterUserRequestImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, email, username, password, displayName);

  /// Create a copy of RegisterUserRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterUserRequestImplCopyWith<_$RegisterUserRequestImpl> get copyWith =>
      __$$RegisterUserRequestImplCopyWithImpl<_$RegisterUserRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RegisterUserRequestImplToJson(this);
  }
}

abstract class _RegisterUserRequest implements RegisterUserRequest {
  const factory _RegisterUserRequest({
    required final String email,
    required final String username,
    required final String password,
    @JsonKey(name: 'display_name') required final String displayName,
  }) = _$RegisterUserRequestImpl;

  factory _RegisterUserRequest.fromJson(Map<String, dynamic> json) =
      _$RegisterUserRequestImpl.fromJson;

  @override
  String get email;
  @override
  String get username;
  @override
  String get password;
  @override
  @JsonKey(name: 'display_name')
  String get displayName;

  /// Create a copy of RegisterUserRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterUserRequestImplCopyWith<_$RegisterUserRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LoginUserRequest _$LoginUserRequestFromJson(Map<String, dynamic> json) {
  return _LoginUserRequest.fromJson(json);
}

/// @nodoc
mixin _$LoginUserRequest {
  String get identity => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;

  /// Serializes this LoginUserRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginUserRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginUserRequestCopyWith<LoginUserRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginUserRequestCopyWith<$Res> {
  factory $LoginUserRequestCopyWith(
    LoginUserRequest value,
    $Res Function(LoginUserRequest) then,
  ) = _$LoginUserRequestCopyWithImpl<$Res, LoginUserRequest>;
  @useResult
  $Res call({String identity, String password});
}

/// @nodoc
class _$LoginUserRequestCopyWithImpl<$Res, $Val extends LoginUserRequest>
    implements $LoginUserRequestCopyWith<$Res> {
  _$LoginUserRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginUserRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? identity = null, Object? password = null}) {
    return _then(
      _value.copyWith(
            identity: null == identity
                ? _value.identity
                : identity // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LoginUserRequestImplCopyWith<$Res>
    implements $LoginUserRequestCopyWith<$Res> {
  factory _$$LoginUserRequestImplCopyWith(
    _$LoginUserRequestImpl value,
    $Res Function(_$LoginUserRequestImpl) then,
  ) = __$$LoginUserRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String identity, String password});
}

/// @nodoc
class __$$LoginUserRequestImplCopyWithImpl<$Res>
    extends _$LoginUserRequestCopyWithImpl<$Res, _$LoginUserRequestImpl>
    implements _$$LoginUserRequestImplCopyWith<$Res> {
  __$$LoginUserRequestImplCopyWithImpl(
    _$LoginUserRequestImpl _value,
    $Res Function(_$LoginUserRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoginUserRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? identity = null, Object? password = null}) {
    return _then(
      _$LoginUserRequestImpl(
        identity: null == identity
            ? _value.identity
            : identity // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginUserRequestImpl implements _LoginUserRequest {
  const _$LoginUserRequestImpl({
    required this.identity,
    required this.password,
  });

  factory _$LoginUserRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginUserRequestImplFromJson(json);

  @override
  final String identity;
  @override
  final String password;

  @override
  String toString() {
    return 'LoginUserRequest(identity: $identity, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginUserRequestImpl &&
            (identical(other.identity, identity) ||
                other.identity == identity) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, identity, password);

  /// Create a copy of LoginUserRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginUserRequestImplCopyWith<_$LoginUserRequestImpl> get copyWith =>
      __$$LoginUserRequestImplCopyWithImpl<_$LoginUserRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginUserRequestImplToJson(this);
  }
}

abstract class _LoginUserRequest implements LoginUserRequest {
  const factory _LoginUserRequest({
    required final String identity,
    required final String password,
  }) = _$LoginUserRequestImpl;

  factory _LoginUserRequest.fromJson(Map<String, dynamic> json) =
      _$LoginUserRequestImpl.fromJson;

  @override
  String get identity;
  @override
  String get password;

  /// Create a copy of LoginUserRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginUserRequestImplCopyWith<_$LoginUserRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateUserProfileRequest _$UpdateUserProfileRequestFromJson(
  Map<String, dynamic> json,
) {
  return _UpdateUserProfileRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateUserProfileRequest {
  @JsonKey(name: 'display_name')
  String get displayName => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_url')
  String get avatarUrl => throw _privateConstructorUsedError;
  String get bio => throw _privateConstructorUsedError;
  @JsonKey(name: 'favorite_game')
  String get favoriteGame => throw _privateConstructorUsedError;
  @JsonKey(name: 'dota_account_id')
  int? get dotaAccountId => throw _privateConstructorUsedError;

  /// Serializes this UpdateUserProfileRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateUserProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateUserProfileRequestCopyWith<UpdateUserProfileRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateUserProfileRequestCopyWith<$Res> {
  factory $UpdateUserProfileRequestCopyWith(
    UpdateUserProfileRequest value,
    $Res Function(UpdateUserProfileRequest) then,
  ) = _$UpdateUserProfileRequestCopyWithImpl<$Res, UpdateUserProfileRequest>;
  @useResult
  $Res call({
    @JsonKey(name: 'display_name') String displayName,
    @JsonKey(name: 'avatar_url') String avatarUrl,
    String bio,
    @JsonKey(name: 'favorite_game') String favoriteGame,
    @JsonKey(name: 'dota_account_id') int? dotaAccountId,
  });
}

/// @nodoc
class _$UpdateUserProfileRequestCopyWithImpl<
  $Res,
  $Val extends UpdateUserProfileRequest
>
    implements $UpdateUserProfileRequestCopyWith<$Res> {
  _$UpdateUserProfileRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateUserProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? displayName = null,
    Object? avatarUrl = null,
    Object? bio = null,
    Object? favoriteGame = null,
    Object? dotaAccountId = freezed,
  }) {
    return _then(
      _value.copyWith(
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarUrl: null == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            bio: null == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String,
            favoriteGame: null == favoriteGame
                ? _value.favoriteGame
                : favoriteGame // ignore: cast_nullable_to_non_nullable
                      as String,
            dotaAccountId: freezed == dotaAccountId
                ? _value.dotaAccountId
                : dotaAccountId // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UpdateUserProfileRequestImplCopyWith<$Res>
    implements $UpdateUserProfileRequestCopyWith<$Res> {
  factory _$$UpdateUserProfileRequestImplCopyWith(
    _$UpdateUserProfileRequestImpl value,
    $Res Function(_$UpdateUserProfileRequestImpl) then,
  ) = __$$UpdateUserProfileRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'display_name') String displayName,
    @JsonKey(name: 'avatar_url') String avatarUrl,
    String bio,
    @JsonKey(name: 'favorite_game') String favoriteGame,
    @JsonKey(name: 'dota_account_id') int? dotaAccountId,
  });
}

/// @nodoc
class __$$UpdateUserProfileRequestImplCopyWithImpl<$Res>
    extends
        _$UpdateUserProfileRequestCopyWithImpl<
          $Res,
          _$UpdateUserProfileRequestImpl
        >
    implements _$$UpdateUserProfileRequestImplCopyWith<$Res> {
  __$$UpdateUserProfileRequestImplCopyWithImpl(
    _$UpdateUserProfileRequestImpl _value,
    $Res Function(_$UpdateUserProfileRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateUserProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? displayName = null,
    Object? avatarUrl = null,
    Object? bio = null,
    Object? favoriteGame = null,
    Object? dotaAccountId = freezed,
  }) {
    return _then(
      _$UpdateUserProfileRequestImpl(
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarUrl: null == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        bio: null == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String,
        favoriteGame: null == favoriteGame
            ? _value.favoriteGame
            : favoriteGame // ignore: cast_nullable_to_non_nullable
                  as String,
        dotaAccountId: freezed == dotaAccountId
            ? _value.dotaAccountId
            : dotaAccountId // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateUserProfileRequestImpl implements _UpdateUserProfileRequest {
  const _$UpdateUserProfileRequestImpl({
    @JsonKey(name: 'display_name') required this.displayName,
    @JsonKey(name: 'avatar_url') required this.avatarUrl,
    required this.bio,
    @JsonKey(name: 'favorite_game') required this.favoriteGame,
    @JsonKey(name: 'dota_account_id') this.dotaAccountId,
  });

  factory _$UpdateUserProfileRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateUserProfileRequestImplFromJson(json);

  @override
  @JsonKey(name: 'display_name')
  final String displayName;
  @override
  @JsonKey(name: 'avatar_url')
  final String avatarUrl;
  @override
  final String bio;
  @override
  @JsonKey(name: 'favorite_game')
  final String favoriteGame;
  @override
  @JsonKey(name: 'dota_account_id')
  final int? dotaAccountId;

  @override
  String toString() {
    return 'UpdateUserProfileRequest(displayName: $displayName, avatarUrl: $avatarUrl, bio: $bio, favoriteGame: $favoriteGame, dotaAccountId: $dotaAccountId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateUserProfileRequestImpl &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.favoriteGame, favoriteGame) ||
                other.favoriteGame == favoriteGame) &&
            (identical(other.dotaAccountId, dotaAccountId) ||
                other.dotaAccountId == dotaAccountId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    displayName,
    avatarUrl,
    bio,
    favoriteGame,
    dotaAccountId,
  );

  /// Create a copy of UpdateUserProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateUserProfileRequestImplCopyWith<_$UpdateUserProfileRequestImpl>
  get copyWith =>
      __$$UpdateUserProfileRequestImplCopyWithImpl<
        _$UpdateUserProfileRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateUserProfileRequestImplToJson(this);
  }
}

abstract class _UpdateUserProfileRequest implements UpdateUserProfileRequest {
  const factory _UpdateUserProfileRequest({
    @JsonKey(name: 'display_name') required final String displayName,
    @JsonKey(name: 'avatar_url') required final String avatarUrl,
    required final String bio,
    @JsonKey(name: 'favorite_game') required final String favoriteGame,
    @JsonKey(name: 'dota_account_id') final int? dotaAccountId,
  }) = _$UpdateUserProfileRequestImpl;

  factory _UpdateUserProfileRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateUserProfileRequestImpl.fromJson;

  @override
  @JsonKey(name: 'display_name')
  String get displayName;
  @override
  @JsonKey(name: 'avatar_url')
  String get avatarUrl;
  @override
  String get bio;
  @override
  @JsonKey(name: 'favorite_game')
  String get favoriteGame;
  @override
  @JsonKey(name: 'dota_account_id')
  int? get dotaAccountId;

  /// Create a copy of UpdateUserProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateUserProfileRequestImplCopyWith<_$UpdateUserProfileRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
