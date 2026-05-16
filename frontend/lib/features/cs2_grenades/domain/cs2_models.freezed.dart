// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cs2_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CS2Map _$CS2MapFromJson(Map<String, dynamic> json) {
  return _CS2Map.fromJson(json);
}

/// @nodoc
mixin _$CS2Map {
  int get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_name')
  String get displayName => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CS2Map to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CS2Map
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CS2MapCopyWith<CS2Map> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CS2MapCopyWith<$Res> {
  factory $CS2MapCopyWith(CS2Map value, $Res Function(CS2Map) then) =
      _$CS2MapCopyWithImpl<$Res, CS2Map>;
  @useResult
  $Res call({
    int id,
    String code,
    @JsonKey(name: 'display_name') String displayName,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$CS2MapCopyWithImpl<$Res, $Val extends CS2Map>
    implements $CS2MapCopyWith<$Res> {
  _$CS2MapCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CS2Map
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? displayName = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CS2MapImplCopyWith<$Res> implements $CS2MapCopyWith<$Res> {
  factory _$$CS2MapImplCopyWith(
    _$CS2MapImpl value,
    $Res Function(_$CS2MapImpl) then,
  ) = __$$CS2MapImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String code,
    @JsonKey(name: 'display_name') String displayName,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$CS2MapImplCopyWithImpl<$Res>
    extends _$CS2MapCopyWithImpl<$Res, _$CS2MapImpl>
    implements _$$CS2MapImplCopyWith<$Res> {
  __$$CS2MapImplCopyWithImpl(
    _$CS2MapImpl _value,
    $Res Function(_$CS2MapImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CS2Map
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? displayName = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$CS2MapImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CS2MapImpl implements _CS2Map {
  const _$CS2MapImpl({
    required this.id,
    required this.code,
    @JsonKey(name: 'display_name') required this.displayName,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  factory _$CS2MapImpl.fromJson(Map<String, dynamic> json) =>
      _$$CS2MapImplFromJson(json);

  @override
  final int id;
  @override
  final String code;
  @override
  @JsonKey(name: 'display_name')
  final String displayName;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'CS2Map(id: $id, code: $code, displayName: $displayName, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CS2MapImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, code, displayName, createdAt, updatedAt);

  /// Create a copy of CS2Map
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CS2MapImplCopyWith<_$CS2MapImpl> get copyWith =>
      __$$CS2MapImplCopyWithImpl<_$CS2MapImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CS2MapImplToJson(this);
  }
}

abstract class _CS2Map implements CS2Map {
  const factory _CS2Map({
    required final int id,
    required final String code,
    @JsonKey(name: 'display_name') required final String displayName,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$CS2MapImpl;

  factory _CS2Map.fromJson(Map<String, dynamic> json) = _$CS2MapImpl.fromJson;

  @override
  int get id;
  @override
  String get code;
  @override
  @JsonKey(name: 'display_name')
  String get displayName;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of CS2Map
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CS2MapImplCopyWith<_$CS2MapImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CS2Grenade _$CS2GrenadeFromJson(Map<String, dynamic> json) {
  return _CS2Grenade.fromJson(json);
}

/// @nodoc
mixin _$CS2Grenade {
  int get id => throw _privateConstructorUsedError;
  String get map => throw _privateConstructorUsedError;
  String get side => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'from_position')
  String get fromPosition => throw _privateConstructorUsedError;
  @JsonKey(name: 'to_position')
  String get toPosition => throw _privateConstructorUsedError;
  String get difficulty => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'video_url')
  String get videoUrl => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CS2Grenade to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CS2Grenade
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CS2GrenadeCopyWith<CS2Grenade> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CS2GrenadeCopyWith<$Res> {
  factory $CS2GrenadeCopyWith(
    CS2Grenade value,
    $Res Function(CS2Grenade) then,
  ) = _$CS2GrenadeCopyWithImpl<$Res, CS2Grenade>;
  @useResult
  $Res call({
    int id,
    String map,
    String side,
    String type,
    String title,
    String description,
    @JsonKey(name: 'from_position') String fromPosition,
    @JsonKey(name: 'to_position') String toPosition,
    String difficulty,
    @JsonKey(name: 'image_url') String imageUrl,
    @JsonKey(name: 'video_url') String videoUrl,
    List<String> tags,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$CS2GrenadeCopyWithImpl<$Res, $Val extends CS2Grenade>
    implements $CS2GrenadeCopyWith<$Res> {
  _$CS2GrenadeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CS2Grenade
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? map = null,
    Object? side = null,
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? fromPosition = null,
    Object? toPosition = null,
    Object? difficulty = null,
    Object? imageUrl = null,
    Object? videoUrl = null,
    Object? tags = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            map: null == map
                ? _value.map
                : map // ignore: cast_nullable_to_non_nullable
                      as String,
            side: null == side
                ? _value.side
                : side // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            fromPosition: null == fromPosition
                ? _value.fromPosition
                : fromPosition // ignore: cast_nullable_to_non_nullable
                      as String,
            toPosition: null == toPosition
                ? _value.toPosition
                : toPosition // ignore: cast_nullable_to_non_nullable
                      as String,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            videoUrl: null == videoUrl
                ? _value.videoUrl
                : videoUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CS2GrenadeImplCopyWith<$Res>
    implements $CS2GrenadeCopyWith<$Res> {
  factory _$$CS2GrenadeImplCopyWith(
    _$CS2GrenadeImpl value,
    $Res Function(_$CS2GrenadeImpl) then,
  ) = __$$CS2GrenadeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String map,
    String side,
    String type,
    String title,
    String description,
    @JsonKey(name: 'from_position') String fromPosition,
    @JsonKey(name: 'to_position') String toPosition,
    String difficulty,
    @JsonKey(name: 'image_url') String imageUrl,
    @JsonKey(name: 'video_url') String videoUrl,
    List<String> tags,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$CS2GrenadeImplCopyWithImpl<$Res>
    extends _$CS2GrenadeCopyWithImpl<$Res, _$CS2GrenadeImpl>
    implements _$$CS2GrenadeImplCopyWith<$Res> {
  __$$CS2GrenadeImplCopyWithImpl(
    _$CS2GrenadeImpl _value,
    $Res Function(_$CS2GrenadeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CS2Grenade
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? map = null,
    Object? side = null,
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? fromPosition = null,
    Object? toPosition = null,
    Object? difficulty = null,
    Object? imageUrl = null,
    Object? videoUrl = null,
    Object? tags = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$CS2GrenadeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        map: null == map
            ? _value.map
            : map // ignore: cast_nullable_to_non_nullable
                  as String,
        side: null == side
            ? _value.side
            : side // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        fromPosition: null == fromPosition
            ? _value.fromPosition
            : fromPosition // ignore: cast_nullable_to_non_nullable
                  as String,
        toPosition: null == toPosition
            ? _value.toPosition
            : toPosition // ignore: cast_nullable_to_non_nullable
                  as String,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        videoUrl: null == videoUrl
            ? _value.videoUrl
            : videoUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CS2GrenadeImpl implements _CS2Grenade {
  const _$CS2GrenadeImpl({
    required this.id,
    required this.map,
    required this.side,
    required this.type,
    required this.title,
    required this.description,
    @JsonKey(name: 'from_position') required this.fromPosition,
    @JsonKey(name: 'to_position') required this.toPosition,
    required this.difficulty,
    @JsonKey(name: 'image_url') required this.imageUrl,
    @JsonKey(name: 'video_url') required this.videoUrl,
    final List<String> tags = const <String>[],
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  }) : _tags = tags;

  factory _$CS2GrenadeImpl.fromJson(Map<String, dynamic> json) =>
      _$$CS2GrenadeImplFromJson(json);

  @override
  final int id;
  @override
  final String map;
  @override
  final String side;
  @override
  final String type;
  @override
  final String title;
  @override
  final String description;
  @override
  @JsonKey(name: 'from_position')
  final String fromPosition;
  @override
  @JsonKey(name: 'to_position')
  final String toPosition;
  @override
  final String difficulty;
  @override
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @override
  @JsonKey(name: 'video_url')
  final String videoUrl;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'CS2Grenade(id: $id, map: $map, side: $side, type: $type, title: $title, description: $description, fromPosition: $fromPosition, toPosition: $toPosition, difficulty: $difficulty, imageUrl: $imageUrl, videoUrl: $videoUrl, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CS2GrenadeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.map, map) || other.map == map) &&
            (identical(other.side, side) || other.side == side) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.fromPosition, fromPosition) ||
                other.fromPosition == fromPosition) &&
            (identical(other.toPosition, toPosition) ||
                other.toPosition == toPosition) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    map,
    side,
    type,
    title,
    description,
    fromPosition,
    toPosition,
    difficulty,
    imageUrl,
    videoUrl,
    const DeepCollectionEquality().hash(_tags),
    createdAt,
    updatedAt,
  );

  /// Create a copy of CS2Grenade
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CS2GrenadeImplCopyWith<_$CS2GrenadeImpl> get copyWith =>
      __$$CS2GrenadeImplCopyWithImpl<_$CS2GrenadeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CS2GrenadeImplToJson(this);
  }
}

abstract class _CS2Grenade implements CS2Grenade {
  const factory _CS2Grenade({
    required final int id,
    required final String map,
    required final String side,
    required final String type,
    required final String title,
    required final String description,
    @JsonKey(name: 'from_position') required final String fromPosition,
    @JsonKey(name: 'to_position') required final String toPosition,
    required final String difficulty,
    @JsonKey(name: 'image_url') required final String imageUrl,
    @JsonKey(name: 'video_url') required final String videoUrl,
    final List<String> tags,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$CS2GrenadeImpl;

  factory _CS2Grenade.fromJson(Map<String, dynamic> json) =
      _$CS2GrenadeImpl.fromJson;

  @override
  int get id;
  @override
  String get map;
  @override
  String get side;
  @override
  String get type;
  @override
  String get title;
  @override
  String get description;
  @override
  @JsonKey(name: 'from_position')
  String get fromPosition;
  @override
  @JsonKey(name: 'to_position')
  String get toPosition;
  @override
  String get difficulty;
  @override
  @JsonKey(name: 'image_url')
  String get imageUrl;
  @override
  @JsonKey(name: 'video_url')
  String get videoUrl;
  @override
  List<String> get tags;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of CS2Grenade
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CS2GrenadeImplCopyWith<_$CS2GrenadeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateCS2GrenadeRequest _$CreateCS2GrenadeRequestFromJson(
  Map<String, dynamic> json,
) {
  return _CreateCS2GrenadeRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateCS2GrenadeRequest {
  String get map => throw _privateConstructorUsedError;
  String get side => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'from_position')
  String get fromPosition => throw _privateConstructorUsedError;
  @JsonKey(name: 'to_position')
  String get toPosition => throw _privateConstructorUsedError;
  String get difficulty => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'video_url')
  String get videoUrl => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;

  /// Serializes this CreateCS2GrenadeRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateCS2GrenadeRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateCS2GrenadeRequestCopyWith<CreateCS2GrenadeRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateCS2GrenadeRequestCopyWith<$Res> {
  factory $CreateCS2GrenadeRequestCopyWith(
    CreateCS2GrenadeRequest value,
    $Res Function(CreateCS2GrenadeRequest) then,
  ) = _$CreateCS2GrenadeRequestCopyWithImpl<$Res, CreateCS2GrenadeRequest>;
  @useResult
  $Res call({
    String map,
    String side,
    String type,
    String title,
    String description,
    @JsonKey(name: 'from_position') String fromPosition,
    @JsonKey(name: 'to_position') String toPosition,
    String difficulty,
    @JsonKey(name: 'image_url') String imageUrl,
    @JsonKey(name: 'video_url') String videoUrl,
    List<String> tags,
  });
}

/// @nodoc
class _$CreateCS2GrenadeRequestCopyWithImpl<
  $Res,
  $Val extends CreateCS2GrenadeRequest
>
    implements $CreateCS2GrenadeRequestCopyWith<$Res> {
  _$CreateCS2GrenadeRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateCS2GrenadeRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? map = null,
    Object? side = null,
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? fromPosition = null,
    Object? toPosition = null,
    Object? difficulty = null,
    Object? imageUrl = null,
    Object? videoUrl = null,
    Object? tags = null,
  }) {
    return _then(
      _value.copyWith(
            map: null == map
                ? _value.map
                : map // ignore: cast_nullable_to_non_nullable
                      as String,
            side: null == side
                ? _value.side
                : side // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            fromPosition: null == fromPosition
                ? _value.fromPosition
                : fromPosition // ignore: cast_nullable_to_non_nullable
                      as String,
            toPosition: null == toPosition
                ? _value.toPosition
                : toPosition // ignore: cast_nullable_to_non_nullable
                      as String,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            videoUrl: null == videoUrl
                ? _value.videoUrl
                : videoUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateCS2GrenadeRequestImplCopyWith<$Res>
    implements $CreateCS2GrenadeRequestCopyWith<$Res> {
  factory _$$CreateCS2GrenadeRequestImplCopyWith(
    _$CreateCS2GrenadeRequestImpl value,
    $Res Function(_$CreateCS2GrenadeRequestImpl) then,
  ) = __$$CreateCS2GrenadeRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String map,
    String side,
    String type,
    String title,
    String description,
    @JsonKey(name: 'from_position') String fromPosition,
    @JsonKey(name: 'to_position') String toPosition,
    String difficulty,
    @JsonKey(name: 'image_url') String imageUrl,
    @JsonKey(name: 'video_url') String videoUrl,
    List<String> tags,
  });
}

/// @nodoc
class __$$CreateCS2GrenadeRequestImplCopyWithImpl<$Res>
    extends
        _$CreateCS2GrenadeRequestCopyWithImpl<
          $Res,
          _$CreateCS2GrenadeRequestImpl
        >
    implements _$$CreateCS2GrenadeRequestImplCopyWith<$Res> {
  __$$CreateCS2GrenadeRequestImplCopyWithImpl(
    _$CreateCS2GrenadeRequestImpl _value,
    $Res Function(_$CreateCS2GrenadeRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateCS2GrenadeRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? map = null,
    Object? side = null,
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? fromPosition = null,
    Object? toPosition = null,
    Object? difficulty = null,
    Object? imageUrl = null,
    Object? videoUrl = null,
    Object? tags = null,
  }) {
    return _then(
      _$CreateCS2GrenadeRequestImpl(
        map: null == map
            ? _value.map
            : map // ignore: cast_nullable_to_non_nullable
                  as String,
        side: null == side
            ? _value.side
            : side // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        fromPosition: null == fromPosition
            ? _value.fromPosition
            : fromPosition // ignore: cast_nullable_to_non_nullable
                  as String,
        toPosition: null == toPosition
            ? _value.toPosition
            : toPosition // ignore: cast_nullable_to_non_nullable
                  as String,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        videoUrl: null == videoUrl
            ? _value.videoUrl
            : videoUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateCS2GrenadeRequestImpl implements _CreateCS2GrenadeRequest {
  const _$CreateCS2GrenadeRequestImpl({
    required this.map,
    required this.side,
    required this.type,
    required this.title,
    required this.description,
    @JsonKey(name: 'from_position') required this.fromPosition,
    @JsonKey(name: 'to_position') required this.toPosition,
    required this.difficulty,
    @JsonKey(name: 'image_url') required this.imageUrl,
    @JsonKey(name: 'video_url') required this.videoUrl,
    final List<String> tags = const <String>[],
  }) : _tags = tags;

  factory _$CreateCS2GrenadeRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateCS2GrenadeRequestImplFromJson(json);

  @override
  final String map;
  @override
  final String side;
  @override
  final String type;
  @override
  final String title;
  @override
  final String description;
  @override
  @JsonKey(name: 'from_position')
  final String fromPosition;
  @override
  @JsonKey(name: 'to_position')
  final String toPosition;
  @override
  final String difficulty;
  @override
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @override
  @JsonKey(name: 'video_url')
  final String videoUrl;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  String toString() {
    return 'CreateCS2GrenadeRequest(map: $map, side: $side, type: $type, title: $title, description: $description, fromPosition: $fromPosition, toPosition: $toPosition, difficulty: $difficulty, imageUrl: $imageUrl, videoUrl: $videoUrl, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateCS2GrenadeRequestImpl &&
            (identical(other.map, map) || other.map == map) &&
            (identical(other.side, side) || other.side == side) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.fromPosition, fromPosition) ||
                other.fromPosition == fromPosition) &&
            (identical(other.toPosition, toPosition) ||
                other.toPosition == toPosition) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    map,
    side,
    type,
    title,
    description,
    fromPosition,
    toPosition,
    difficulty,
    imageUrl,
    videoUrl,
    const DeepCollectionEquality().hash(_tags),
  );

  /// Create a copy of CreateCS2GrenadeRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateCS2GrenadeRequestImplCopyWith<_$CreateCS2GrenadeRequestImpl>
  get copyWith =>
      __$$CreateCS2GrenadeRequestImplCopyWithImpl<
        _$CreateCS2GrenadeRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateCS2GrenadeRequestImplToJson(this);
  }
}

abstract class _CreateCS2GrenadeRequest implements CreateCS2GrenadeRequest {
  const factory _CreateCS2GrenadeRequest({
    required final String map,
    required final String side,
    required final String type,
    required final String title,
    required final String description,
    @JsonKey(name: 'from_position') required final String fromPosition,
    @JsonKey(name: 'to_position') required final String toPosition,
    required final String difficulty,
    @JsonKey(name: 'image_url') required final String imageUrl,
    @JsonKey(name: 'video_url') required final String videoUrl,
    final List<String> tags,
  }) = _$CreateCS2GrenadeRequestImpl;

  factory _CreateCS2GrenadeRequest.fromJson(Map<String, dynamic> json) =
      _$CreateCS2GrenadeRequestImpl.fromJson;

  @override
  String get map;
  @override
  String get side;
  @override
  String get type;
  @override
  String get title;
  @override
  String get description;
  @override
  @JsonKey(name: 'from_position')
  String get fromPosition;
  @override
  @JsonKey(name: 'to_position')
  String get toPosition;
  @override
  String get difficulty;
  @override
  @JsonKey(name: 'image_url')
  String get imageUrl;
  @override
  @JsonKey(name: 'video_url')
  String get videoUrl;
  @override
  List<String> get tags;

  /// Create a copy of CreateCS2GrenadeRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateCS2GrenadeRequestImplCopyWith<_$CreateCS2GrenadeRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
