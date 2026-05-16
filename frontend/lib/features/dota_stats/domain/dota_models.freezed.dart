// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dota_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DotaPlayer _$DotaPlayerFromJson(Map<String, dynamic> json) {
  return _DotaPlayer.fromJson(json);
}

/// @nodoc
mixin _$DotaPlayer {
  @JsonKey(name: 'account_id')
  int get accountId => throw _privateConstructorUsedError;
  @JsonKey(name: 'persona_name')
  String get personaName => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_full')
  String get avatarFull => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_url')
  String get profileUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'rank_tier')
  int? get rankTier => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this DotaPlayer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DotaPlayer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DotaPlayerCopyWith<DotaPlayer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DotaPlayerCopyWith<$Res> {
  factory $DotaPlayerCopyWith(
    DotaPlayer value,
    $Res Function(DotaPlayer) then,
  ) = _$DotaPlayerCopyWithImpl<$Res, DotaPlayer>;
  @useResult
  $Res call({
    @JsonKey(name: 'account_id') int accountId,
    @JsonKey(name: 'persona_name') String personaName,
    @JsonKey(name: 'avatar_full') String avatarFull,
    @JsonKey(name: 'profile_url') String profileUrl,
    @JsonKey(name: 'rank_tier') int? rankTier,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class _$DotaPlayerCopyWithImpl<$Res, $Val extends DotaPlayer>
    implements $DotaPlayerCopyWith<$Res> {
  _$DotaPlayerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DotaPlayer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountId = null,
    Object? personaName = null,
    Object? avatarFull = null,
    Object? profileUrl = null,
    Object? rankTier = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            accountId: null == accountId
                ? _value.accountId
                : accountId // ignore: cast_nullable_to_non_nullable
                      as int,
            personaName: null == personaName
                ? _value.personaName
                : personaName // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarFull: null == avatarFull
                ? _value.avatarFull
                : avatarFull // ignore: cast_nullable_to_non_nullable
                      as String,
            profileUrl: null == profileUrl
                ? _value.profileUrl
                : profileUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            rankTier: freezed == rankTier
                ? _value.rankTier
                : rankTier // ignore: cast_nullable_to_non_nullable
                      as int?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DotaPlayerImplCopyWith<$Res>
    implements $DotaPlayerCopyWith<$Res> {
  factory _$$DotaPlayerImplCopyWith(
    _$DotaPlayerImpl value,
    $Res Function(_$DotaPlayerImpl) then,
  ) = __$$DotaPlayerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'account_id') int accountId,
    @JsonKey(name: 'persona_name') String personaName,
    @JsonKey(name: 'avatar_full') String avatarFull,
    @JsonKey(name: 'profile_url') String profileUrl,
    @JsonKey(name: 'rank_tier') int? rankTier,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class __$$DotaPlayerImplCopyWithImpl<$Res>
    extends _$DotaPlayerCopyWithImpl<$Res, _$DotaPlayerImpl>
    implements _$$DotaPlayerImplCopyWith<$Res> {
  __$$DotaPlayerImplCopyWithImpl(
    _$DotaPlayerImpl _value,
    $Res Function(_$DotaPlayerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DotaPlayer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountId = null,
    Object? personaName = null,
    Object? avatarFull = null,
    Object? profileUrl = null,
    Object? rankTier = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$DotaPlayerImpl(
        accountId: null == accountId
            ? _value.accountId
            : accountId // ignore: cast_nullable_to_non_nullable
                  as int,
        personaName: null == personaName
            ? _value.personaName
            : personaName // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarFull: null == avatarFull
            ? _value.avatarFull
            : avatarFull // ignore: cast_nullable_to_non_nullable
                  as String,
        profileUrl: null == profileUrl
            ? _value.profileUrl
            : profileUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        rankTier: freezed == rankTier
            ? _value.rankTier
            : rankTier // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DotaPlayerImpl implements _DotaPlayer {
  const _$DotaPlayerImpl({
    @JsonKey(name: 'account_id') required this.accountId,
    @JsonKey(name: 'persona_name') required this.personaName,
    @JsonKey(name: 'avatar_full') required this.avatarFull,
    @JsonKey(name: 'profile_url') required this.profileUrl,
    @JsonKey(name: 'rank_tier') this.rankTier,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  });

  factory _$DotaPlayerImpl.fromJson(Map<String, dynamic> json) =>
      _$$DotaPlayerImplFromJson(json);

  @override
  @JsonKey(name: 'account_id')
  final int accountId;
  @override
  @JsonKey(name: 'persona_name')
  final String personaName;
  @override
  @JsonKey(name: 'avatar_full')
  final String avatarFull;
  @override
  @JsonKey(name: 'profile_url')
  final String profileUrl;
  @override
  @JsonKey(name: 'rank_tier')
  final int? rankTier;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'DotaPlayer(accountId: $accountId, personaName: $personaName, avatarFull: $avatarFull, profileUrl: $profileUrl, rankTier: $rankTier, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DotaPlayerImpl &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.personaName, personaName) ||
                other.personaName == personaName) &&
            (identical(other.avatarFull, avatarFull) ||
                other.avatarFull == avatarFull) &&
            (identical(other.profileUrl, profileUrl) ||
                other.profileUrl == profileUrl) &&
            (identical(other.rankTier, rankTier) ||
                other.rankTier == rankTier) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    accountId,
    personaName,
    avatarFull,
    profileUrl,
    rankTier,
    createdAt,
    updatedAt,
  );

  /// Create a copy of DotaPlayer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DotaPlayerImplCopyWith<_$DotaPlayerImpl> get copyWith =>
      __$$DotaPlayerImplCopyWithImpl<_$DotaPlayerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DotaPlayerImplToJson(this);
  }
}

abstract class _DotaPlayer implements DotaPlayer {
  const factory _DotaPlayer({
    @JsonKey(name: 'account_id') required final int accountId,
    @JsonKey(name: 'persona_name') required final String personaName,
    @JsonKey(name: 'avatar_full') required final String avatarFull,
    @JsonKey(name: 'profile_url') required final String profileUrl,
    @JsonKey(name: 'rank_tier') final int? rankTier,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
  }) = _$DotaPlayerImpl;

  factory _DotaPlayer.fromJson(Map<String, dynamic> json) =
      _$DotaPlayerImpl.fromJson;

  @override
  @JsonKey(name: 'account_id')
  int get accountId;
  @override
  @JsonKey(name: 'persona_name')
  String get personaName;
  @override
  @JsonKey(name: 'avatar_full')
  String get avatarFull;
  @override
  @JsonKey(name: 'profile_url')
  String get profileUrl;
  @override
  @JsonKey(name: 'rank_tier')
  int? get rankTier;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of DotaPlayer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DotaPlayerImplCopyWith<_$DotaPlayerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DotaMatch _$DotaMatchFromJson(Map<String, dynamic> json) {
  return _DotaMatch.fromJson(json);
}

/// @nodoc
mixin _$DotaMatch {
  @JsonKey(name: 'match_id')
  int get matchId => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_id')
  int get accountId => throw _privateConstructorUsedError;
  @JsonKey(name: 'player_slot')
  int get playerSlot => throw _privateConstructorUsedError;
  @JsonKey(name: 'radiant_win')
  bool get radiantWin => throw _privateConstructorUsedError;
  bool get won => throw _privateConstructorUsedError;
  @JsonKey(name: 'hero_id')
  int get heroId => throw _privateConstructorUsedError;
  int get kills => throw _privateConstructorUsedError;
  int get deaths => throw _privateConstructorUsedError;
  int get assists => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_seconds')
  int get durationSeconds => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_time')
  DateTime get startTime => throw _privateConstructorUsedError;

  /// Serializes this DotaMatch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DotaMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DotaMatchCopyWith<DotaMatch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DotaMatchCopyWith<$Res> {
  factory $DotaMatchCopyWith(DotaMatch value, $Res Function(DotaMatch) then) =
      _$DotaMatchCopyWithImpl<$Res, DotaMatch>;
  @useResult
  $Res call({
    @JsonKey(name: 'match_id') int matchId,
    @JsonKey(name: 'account_id') int accountId,
    @JsonKey(name: 'player_slot') int playerSlot,
    @JsonKey(name: 'radiant_win') bool radiantWin,
    bool won,
    @JsonKey(name: 'hero_id') int heroId,
    int kills,
    int deaths,
    int assists,
    @JsonKey(name: 'duration_seconds') int durationSeconds,
    @JsonKey(name: 'start_time') DateTime startTime,
  });
}

/// @nodoc
class _$DotaMatchCopyWithImpl<$Res, $Val extends DotaMatch>
    implements $DotaMatchCopyWith<$Res> {
  _$DotaMatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DotaMatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? matchId = null,
    Object? accountId = null,
    Object? playerSlot = null,
    Object? radiantWin = null,
    Object? won = null,
    Object? heroId = null,
    Object? kills = null,
    Object? deaths = null,
    Object? assists = null,
    Object? durationSeconds = null,
    Object? startTime = null,
  }) {
    return _then(
      _value.copyWith(
            matchId: null == matchId
                ? _value.matchId
                : matchId // ignore: cast_nullable_to_non_nullable
                      as int,
            accountId: null == accountId
                ? _value.accountId
                : accountId // ignore: cast_nullable_to_non_nullable
                      as int,
            playerSlot: null == playerSlot
                ? _value.playerSlot
                : playerSlot // ignore: cast_nullable_to_non_nullable
                      as int,
            radiantWin: null == radiantWin
                ? _value.radiantWin
                : radiantWin // ignore: cast_nullable_to_non_nullable
                      as bool,
            won: null == won
                ? _value.won
                : won // ignore: cast_nullable_to_non_nullable
                      as bool,
            heroId: null == heroId
                ? _value.heroId
                : heroId // ignore: cast_nullable_to_non_nullable
                      as int,
            kills: null == kills
                ? _value.kills
                : kills // ignore: cast_nullable_to_non_nullable
                      as int,
            deaths: null == deaths
                ? _value.deaths
                : deaths // ignore: cast_nullable_to_non_nullable
                      as int,
            assists: null == assists
                ? _value.assists
                : assists // ignore: cast_nullable_to_non_nullable
                      as int,
            durationSeconds: null == durationSeconds
                ? _value.durationSeconds
                : durationSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DotaMatchImplCopyWith<$Res>
    implements $DotaMatchCopyWith<$Res> {
  factory _$$DotaMatchImplCopyWith(
    _$DotaMatchImpl value,
    $Res Function(_$DotaMatchImpl) then,
  ) = __$$DotaMatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'match_id') int matchId,
    @JsonKey(name: 'account_id') int accountId,
    @JsonKey(name: 'player_slot') int playerSlot,
    @JsonKey(name: 'radiant_win') bool radiantWin,
    bool won,
    @JsonKey(name: 'hero_id') int heroId,
    int kills,
    int deaths,
    int assists,
    @JsonKey(name: 'duration_seconds') int durationSeconds,
    @JsonKey(name: 'start_time') DateTime startTime,
  });
}

/// @nodoc
class __$$DotaMatchImplCopyWithImpl<$Res>
    extends _$DotaMatchCopyWithImpl<$Res, _$DotaMatchImpl>
    implements _$$DotaMatchImplCopyWith<$Res> {
  __$$DotaMatchImplCopyWithImpl(
    _$DotaMatchImpl _value,
    $Res Function(_$DotaMatchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DotaMatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? matchId = null,
    Object? accountId = null,
    Object? playerSlot = null,
    Object? radiantWin = null,
    Object? won = null,
    Object? heroId = null,
    Object? kills = null,
    Object? deaths = null,
    Object? assists = null,
    Object? durationSeconds = null,
    Object? startTime = null,
  }) {
    return _then(
      _$DotaMatchImpl(
        matchId: null == matchId
            ? _value.matchId
            : matchId // ignore: cast_nullable_to_non_nullable
                  as int,
        accountId: null == accountId
            ? _value.accountId
            : accountId // ignore: cast_nullable_to_non_nullable
                  as int,
        playerSlot: null == playerSlot
            ? _value.playerSlot
            : playerSlot // ignore: cast_nullable_to_non_nullable
                  as int,
        radiantWin: null == radiantWin
            ? _value.radiantWin
            : radiantWin // ignore: cast_nullable_to_non_nullable
                  as bool,
        won: null == won
            ? _value.won
            : won // ignore: cast_nullable_to_non_nullable
                  as bool,
        heroId: null == heroId
            ? _value.heroId
            : heroId // ignore: cast_nullable_to_non_nullable
                  as int,
        kills: null == kills
            ? _value.kills
            : kills // ignore: cast_nullable_to_non_nullable
                  as int,
        deaths: null == deaths
            ? _value.deaths
            : deaths // ignore: cast_nullable_to_non_nullable
                  as int,
        assists: null == assists
            ? _value.assists
            : assists // ignore: cast_nullable_to_non_nullable
                  as int,
        durationSeconds: null == durationSeconds
            ? _value.durationSeconds
            : durationSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DotaMatchImpl implements _DotaMatch {
  const _$DotaMatchImpl({
    @JsonKey(name: 'match_id') required this.matchId,
    @JsonKey(name: 'account_id') required this.accountId,
    @JsonKey(name: 'player_slot') required this.playerSlot,
    @JsonKey(name: 'radiant_win') required this.radiantWin,
    required this.won,
    @JsonKey(name: 'hero_id') required this.heroId,
    required this.kills,
    required this.deaths,
    required this.assists,
    @JsonKey(name: 'duration_seconds') required this.durationSeconds,
    @JsonKey(name: 'start_time') required this.startTime,
  });

  factory _$DotaMatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$DotaMatchImplFromJson(json);

  @override
  @JsonKey(name: 'match_id')
  final int matchId;
  @override
  @JsonKey(name: 'account_id')
  final int accountId;
  @override
  @JsonKey(name: 'player_slot')
  final int playerSlot;
  @override
  @JsonKey(name: 'radiant_win')
  final bool radiantWin;
  @override
  final bool won;
  @override
  @JsonKey(name: 'hero_id')
  final int heroId;
  @override
  final int kills;
  @override
  final int deaths;
  @override
  final int assists;
  @override
  @JsonKey(name: 'duration_seconds')
  final int durationSeconds;
  @override
  @JsonKey(name: 'start_time')
  final DateTime startTime;

  @override
  String toString() {
    return 'DotaMatch(matchId: $matchId, accountId: $accountId, playerSlot: $playerSlot, radiantWin: $radiantWin, won: $won, heroId: $heroId, kills: $kills, deaths: $deaths, assists: $assists, durationSeconds: $durationSeconds, startTime: $startTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DotaMatchImpl &&
            (identical(other.matchId, matchId) || other.matchId == matchId) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.playerSlot, playerSlot) ||
                other.playerSlot == playerSlot) &&
            (identical(other.radiantWin, radiantWin) ||
                other.radiantWin == radiantWin) &&
            (identical(other.won, won) || other.won == won) &&
            (identical(other.heroId, heroId) || other.heroId == heroId) &&
            (identical(other.kills, kills) || other.kills == kills) &&
            (identical(other.deaths, deaths) || other.deaths == deaths) &&
            (identical(other.assists, assists) || other.assists == assists) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    matchId,
    accountId,
    playerSlot,
    radiantWin,
    won,
    heroId,
    kills,
    deaths,
    assists,
    durationSeconds,
    startTime,
  );

  /// Create a copy of DotaMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DotaMatchImplCopyWith<_$DotaMatchImpl> get copyWith =>
      __$$DotaMatchImplCopyWithImpl<_$DotaMatchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DotaMatchImplToJson(this);
  }
}

abstract class _DotaMatch implements DotaMatch {
  const factory _DotaMatch({
    @JsonKey(name: 'match_id') required final int matchId,
    @JsonKey(name: 'account_id') required final int accountId,
    @JsonKey(name: 'player_slot') required final int playerSlot,
    @JsonKey(name: 'radiant_win') required final bool radiantWin,
    required final bool won,
    @JsonKey(name: 'hero_id') required final int heroId,
    required final int kills,
    required final int deaths,
    required final int assists,
    @JsonKey(name: 'duration_seconds') required final int durationSeconds,
    @JsonKey(name: 'start_time') required final DateTime startTime,
  }) = _$DotaMatchImpl;

  factory _DotaMatch.fromJson(Map<String, dynamic> json) =
      _$DotaMatchImpl.fromJson;

  @override
  @JsonKey(name: 'match_id')
  int get matchId;
  @override
  @JsonKey(name: 'account_id')
  int get accountId;
  @override
  @JsonKey(name: 'player_slot')
  int get playerSlot;
  @override
  @JsonKey(name: 'radiant_win')
  bool get radiantWin;
  @override
  bool get won;
  @override
  @JsonKey(name: 'hero_id')
  int get heroId;
  @override
  int get kills;
  @override
  int get deaths;
  @override
  int get assists;
  @override
  @JsonKey(name: 'duration_seconds')
  int get durationSeconds;
  @override
  @JsonKey(name: 'start_time')
  DateTime get startTime;

  /// Create a copy of DotaMatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DotaMatchImplCopyWith<_$DotaMatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DotaHeroSummary _$DotaHeroSummaryFromJson(Map<String, dynamic> json) {
  return _DotaHeroSummary.fromJson(json);
}

/// @nodoc
mixin _$DotaHeroSummary {
  @JsonKey(name: 'hero_id')
  int get heroId => throw _privateConstructorUsedError;
  int get matches => throw _privateConstructorUsedError;
  int get wins => throw _privateConstructorUsedError;
  double get winrate => throw _privateConstructorUsedError;

  /// Serializes this DotaHeroSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DotaHeroSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DotaHeroSummaryCopyWith<DotaHeroSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DotaHeroSummaryCopyWith<$Res> {
  factory $DotaHeroSummaryCopyWith(
    DotaHeroSummary value,
    $Res Function(DotaHeroSummary) then,
  ) = _$DotaHeroSummaryCopyWithImpl<$Res, DotaHeroSummary>;
  @useResult
  $Res call({
    @JsonKey(name: 'hero_id') int heroId,
    int matches,
    int wins,
    double winrate,
  });
}

/// @nodoc
class _$DotaHeroSummaryCopyWithImpl<$Res, $Val extends DotaHeroSummary>
    implements $DotaHeroSummaryCopyWith<$Res> {
  _$DotaHeroSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DotaHeroSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? heroId = null,
    Object? matches = null,
    Object? wins = null,
    Object? winrate = null,
  }) {
    return _then(
      _value.copyWith(
            heroId: null == heroId
                ? _value.heroId
                : heroId // ignore: cast_nullable_to_non_nullable
                      as int,
            matches: null == matches
                ? _value.matches
                : matches // ignore: cast_nullable_to_non_nullable
                      as int,
            wins: null == wins
                ? _value.wins
                : wins // ignore: cast_nullable_to_non_nullable
                      as int,
            winrate: null == winrate
                ? _value.winrate
                : winrate // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DotaHeroSummaryImplCopyWith<$Res>
    implements $DotaHeroSummaryCopyWith<$Res> {
  factory _$$DotaHeroSummaryImplCopyWith(
    _$DotaHeroSummaryImpl value,
    $Res Function(_$DotaHeroSummaryImpl) then,
  ) = __$$DotaHeroSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'hero_id') int heroId,
    int matches,
    int wins,
    double winrate,
  });
}

/// @nodoc
class __$$DotaHeroSummaryImplCopyWithImpl<$Res>
    extends _$DotaHeroSummaryCopyWithImpl<$Res, _$DotaHeroSummaryImpl>
    implements _$$DotaHeroSummaryImplCopyWith<$Res> {
  __$$DotaHeroSummaryImplCopyWithImpl(
    _$DotaHeroSummaryImpl _value,
    $Res Function(_$DotaHeroSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DotaHeroSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? heroId = null,
    Object? matches = null,
    Object? wins = null,
    Object? winrate = null,
  }) {
    return _then(
      _$DotaHeroSummaryImpl(
        heroId: null == heroId
            ? _value.heroId
            : heroId // ignore: cast_nullable_to_non_nullable
                  as int,
        matches: null == matches
            ? _value.matches
            : matches // ignore: cast_nullable_to_non_nullable
                  as int,
        wins: null == wins
            ? _value.wins
            : wins // ignore: cast_nullable_to_non_nullable
                  as int,
        winrate: null == winrate
            ? _value.winrate
            : winrate // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DotaHeroSummaryImpl implements _DotaHeroSummary {
  const _$DotaHeroSummaryImpl({
    @JsonKey(name: 'hero_id') required this.heroId,
    required this.matches,
    required this.wins,
    required this.winrate,
  });

  factory _$DotaHeroSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DotaHeroSummaryImplFromJson(json);

  @override
  @JsonKey(name: 'hero_id')
  final int heroId;
  @override
  final int matches;
  @override
  final int wins;
  @override
  final double winrate;

  @override
  String toString() {
    return 'DotaHeroSummary(heroId: $heroId, matches: $matches, wins: $wins, winrate: $winrate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DotaHeroSummaryImpl &&
            (identical(other.heroId, heroId) || other.heroId == heroId) &&
            (identical(other.matches, matches) || other.matches == matches) &&
            (identical(other.wins, wins) || other.wins == wins) &&
            (identical(other.winrate, winrate) || other.winrate == winrate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, heroId, matches, wins, winrate);

  /// Create a copy of DotaHeroSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DotaHeroSummaryImplCopyWith<_$DotaHeroSummaryImpl> get copyWith =>
      __$$DotaHeroSummaryImplCopyWithImpl<_$DotaHeroSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DotaHeroSummaryImplToJson(this);
  }
}

abstract class _DotaHeroSummary implements DotaHeroSummary {
  const factory _DotaHeroSummary({
    @JsonKey(name: 'hero_id') required final int heroId,
    required final int matches,
    required final int wins,
    required final double winrate,
  }) = _$DotaHeroSummaryImpl;

  factory _DotaHeroSummary.fromJson(Map<String, dynamic> json) =
      _$DotaHeroSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'hero_id')
  int get heroId;
  @override
  int get matches;
  @override
  int get wins;
  @override
  double get winrate;

  /// Create a copy of DotaHeroSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DotaHeroSummaryImplCopyWith<_$DotaHeroSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DotaSummary _$DotaSummaryFromJson(Map<String, dynamic> json) {
  return _DotaSummary.fromJson(json);
}

/// @nodoc
mixin _$DotaSummary {
  @JsonKey(name: 'account_id')
  int get accountId => throw _privateConstructorUsedError;
  int get matches => throw _privateConstructorUsedError;
  int get wins => throw _privateConstructorUsedError;
  int get losses => throw _privateConstructorUsedError;
  double get winrate => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_kills')
  double get averageKills => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_deaths')
  double get averageDeaths => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_assists')
  double get averageAssists => throw _privateConstructorUsedError;
  double get kda => throw _privateConstructorUsedError;
  @JsonKey(name: 'top_heroes')
  List<DotaHeroSummary> get topHeroes => throw _privateConstructorUsedError;
  @JsonKey(name: 'snapshot_id')
  int? get snapshotId => throw _privateConstructorUsedError;
  @JsonKey(name: 'snapshotted_at')
  DateTime? get snapshottedAt => throw _privateConstructorUsedError;

  /// Serializes this DotaSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DotaSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DotaSummaryCopyWith<DotaSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DotaSummaryCopyWith<$Res> {
  factory $DotaSummaryCopyWith(
    DotaSummary value,
    $Res Function(DotaSummary) then,
  ) = _$DotaSummaryCopyWithImpl<$Res, DotaSummary>;
  @useResult
  $Res call({
    @JsonKey(name: 'account_id') int accountId,
    int matches,
    int wins,
    int losses,
    double winrate,
    @JsonKey(name: 'average_kills') double averageKills,
    @JsonKey(name: 'average_deaths') double averageDeaths,
    @JsonKey(name: 'average_assists') double averageAssists,
    double kda,
    @JsonKey(name: 'top_heroes') List<DotaHeroSummary> topHeroes,
    @JsonKey(name: 'snapshot_id') int? snapshotId,
    @JsonKey(name: 'snapshotted_at') DateTime? snapshottedAt,
  });
}

/// @nodoc
class _$DotaSummaryCopyWithImpl<$Res, $Val extends DotaSummary>
    implements $DotaSummaryCopyWith<$Res> {
  _$DotaSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DotaSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountId = null,
    Object? matches = null,
    Object? wins = null,
    Object? losses = null,
    Object? winrate = null,
    Object? averageKills = null,
    Object? averageDeaths = null,
    Object? averageAssists = null,
    Object? kda = null,
    Object? topHeroes = null,
    Object? snapshotId = freezed,
    Object? snapshottedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            accountId: null == accountId
                ? _value.accountId
                : accountId // ignore: cast_nullable_to_non_nullable
                      as int,
            matches: null == matches
                ? _value.matches
                : matches // ignore: cast_nullable_to_non_nullable
                      as int,
            wins: null == wins
                ? _value.wins
                : wins // ignore: cast_nullable_to_non_nullable
                      as int,
            losses: null == losses
                ? _value.losses
                : losses // ignore: cast_nullable_to_non_nullable
                      as int,
            winrate: null == winrate
                ? _value.winrate
                : winrate // ignore: cast_nullable_to_non_nullable
                      as double,
            averageKills: null == averageKills
                ? _value.averageKills
                : averageKills // ignore: cast_nullable_to_non_nullable
                      as double,
            averageDeaths: null == averageDeaths
                ? _value.averageDeaths
                : averageDeaths // ignore: cast_nullable_to_non_nullable
                      as double,
            averageAssists: null == averageAssists
                ? _value.averageAssists
                : averageAssists // ignore: cast_nullable_to_non_nullable
                      as double,
            kda: null == kda
                ? _value.kda
                : kda // ignore: cast_nullable_to_non_nullable
                      as double,
            topHeroes: null == topHeroes
                ? _value.topHeroes
                : topHeroes // ignore: cast_nullable_to_non_nullable
                      as List<DotaHeroSummary>,
            snapshotId: freezed == snapshotId
                ? _value.snapshotId
                : snapshotId // ignore: cast_nullable_to_non_nullable
                      as int?,
            snapshottedAt: freezed == snapshottedAt
                ? _value.snapshottedAt
                : snapshottedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DotaSummaryImplCopyWith<$Res>
    implements $DotaSummaryCopyWith<$Res> {
  factory _$$DotaSummaryImplCopyWith(
    _$DotaSummaryImpl value,
    $Res Function(_$DotaSummaryImpl) then,
  ) = __$$DotaSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'account_id') int accountId,
    int matches,
    int wins,
    int losses,
    double winrate,
    @JsonKey(name: 'average_kills') double averageKills,
    @JsonKey(name: 'average_deaths') double averageDeaths,
    @JsonKey(name: 'average_assists') double averageAssists,
    double kda,
    @JsonKey(name: 'top_heroes') List<DotaHeroSummary> topHeroes,
    @JsonKey(name: 'snapshot_id') int? snapshotId,
    @JsonKey(name: 'snapshotted_at') DateTime? snapshottedAt,
  });
}

/// @nodoc
class __$$DotaSummaryImplCopyWithImpl<$Res>
    extends _$DotaSummaryCopyWithImpl<$Res, _$DotaSummaryImpl>
    implements _$$DotaSummaryImplCopyWith<$Res> {
  __$$DotaSummaryImplCopyWithImpl(
    _$DotaSummaryImpl _value,
    $Res Function(_$DotaSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DotaSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountId = null,
    Object? matches = null,
    Object? wins = null,
    Object? losses = null,
    Object? winrate = null,
    Object? averageKills = null,
    Object? averageDeaths = null,
    Object? averageAssists = null,
    Object? kda = null,
    Object? topHeroes = null,
    Object? snapshotId = freezed,
    Object? snapshottedAt = freezed,
  }) {
    return _then(
      _$DotaSummaryImpl(
        accountId: null == accountId
            ? _value.accountId
            : accountId // ignore: cast_nullable_to_non_nullable
                  as int,
        matches: null == matches
            ? _value.matches
            : matches // ignore: cast_nullable_to_non_nullable
                  as int,
        wins: null == wins
            ? _value.wins
            : wins // ignore: cast_nullable_to_non_nullable
                  as int,
        losses: null == losses
            ? _value.losses
            : losses // ignore: cast_nullable_to_non_nullable
                  as int,
        winrate: null == winrate
            ? _value.winrate
            : winrate // ignore: cast_nullable_to_non_nullable
                  as double,
        averageKills: null == averageKills
            ? _value.averageKills
            : averageKills // ignore: cast_nullable_to_non_nullable
                  as double,
        averageDeaths: null == averageDeaths
            ? _value.averageDeaths
            : averageDeaths // ignore: cast_nullable_to_non_nullable
                  as double,
        averageAssists: null == averageAssists
            ? _value.averageAssists
            : averageAssists // ignore: cast_nullable_to_non_nullable
                  as double,
        kda: null == kda
            ? _value.kda
            : kda // ignore: cast_nullable_to_non_nullable
                  as double,
        topHeroes: null == topHeroes
            ? _value._topHeroes
            : topHeroes // ignore: cast_nullable_to_non_nullable
                  as List<DotaHeroSummary>,
        snapshotId: freezed == snapshotId
            ? _value.snapshotId
            : snapshotId // ignore: cast_nullable_to_non_nullable
                  as int?,
        snapshottedAt: freezed == snapshottedAt
            ? _value.snapshottedAt
            : snapshottedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DotaSummaryImpl implements _DotaSummary {
  const _$DotaSummaryImpl({
    @JsonKey(name: 'account_id') required this.accountId,
    required this.matches,
    required this.wins,
    required this.losses,
    required this.winrate,
    @JsonKey(name: 'average_kills') required this.averageKills,
    @JsonKey(name: 'average_deaths') required this.averageDeaths,
    @JsonKey(name: 'average_assists') required this.averageAssists,
    required this.kda,
    @JsonKey(name: 'top_heroes')
    final List<DotaHeroSummary> topHeroes = const <DotaHeroSummary>[],
    @JsonKey(name: 'snapshot_id') this.snapshotId,
    @JsonKey(name: 'snapshotted_at') this.snapshottedAt,
  }) : _topHeroes = topHeroes;

  factory _$DotaSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DotaSummaryImplFromJson(json);

  @override
  @JsonKey(name: 'account_id')
  final int accountId;
  @override
  final int matches;
  @override
  final int wins;
  @override
  final int losses;
  @override
  final double winrate;
  @override
  @JsonKey(name: 'average_kills')
  final double averageKills;
  @override
  @JsonKey(name: 'average_deaths')
  final double averageDeaths;
  @override
  @JsonKey(name: 'average_assists')
  final double averageAssists;
  @override
  final double kda;
  final List<DotaHeroSummary> _topHeroes;
  @override
  @JsonKey(name: 'top_heroes')
  List<DotaHeroSummary> get topHeroes {
    if (_topHeroes is EqualUnmodifiableListView) return _topHeroes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topHeroes);
  }

  @override
  @JsonKey(name: 'snapshot_id')
  final int? snapshotId;
  @override
  @JsonKey(name: 'snapshotted_at')
  final DateTime? snapshottedAt;

  @override
  String toString() {
    return 'DotaSummary(accountId: $accountId, matches: $matches, wins: $wins, losses: $losses, winrate: $winrate, averageKills: $averageKills, averageDeaths: $averageDeaths, averageAssists: $averageAssists, kda: $kda, topHeroes: $topHeroes, snapshotId: $snapshotId, snapshottedAt: $snapshottedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DotaSummaryImpl &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.matches, matches) || other.matches == matches) &&
            (identical(other.wins, wins) || other.wins == wins) &&
            (identical(other.losses, losses) || other.losses == losses) &&
            (identical(other.winrate, winrate) || other.winrate == winrate) &&
            (identical(other.averageKills, averageKills) ||
                other.averageKills == averageKills) &&
            (identical(other.averageDeaths, averageDeaths) ||
                other.averageDeaths == averageDeaths) &&
            (identical(other.averageAssists, averageAssists) ||
                other.averageAssists == averageAssists) &&
            (identical(other.kda, kda) || other.kda == kda) &&
            const DeepCollectionEquality().equals(
              other._topHeroes,
              _topHeroes,
            ) &&
            (identical(other.snapshotId, snapshotId) ||
                other.snapshotId == snapshotId) &&
            (identical(other.snapshottedAt, snapshottedAt) ||
                other.snapshottedAt == snapshottedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    accountId,
    matches,
    wins,
    losses,
    winrate,
    averageKills,
    averageDeaths,
    averageAssists,
    kda,
    const DeepCollectionEquality().hash(_topHeroes),
    snapshotId,
    snapshottedAt,
  );

  /// Create a copy of DotaSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DotaSummaryImplCopyWith<_$DotaSummaryImpl> get copyWith =>
      __$$DotaSummaryImplCopyWithImpl<_$DotaSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DotaSummaryImplToJson(this);
  }
}

abstract class _DotaSummary implements DotaSummary {
  const factory _DotaSummary({
    @JsonKey(name: 'account_id') required final int accountId,
    required final int matches,
    required final int wins,
    required final int losses,
    required final double winrate,
    @JsonKey(name: 'average_kills') required final double averageKills,
    @JsonKey(name: 'average_deaths') required final double averageDeaths,
    @JsonKey(name: 'average_assists') required final double averageAssists,
    required final double kda,
    @JsonKey(name: 'top_heroes') final List<DotaHeroSummary> topHeroes,
    @JsonKey(name: 'snapshot_id') final int? snapshotId,
    @JsonKey(name: 'snapshotted_at') final DateTime? snapshottedAt,
  }) = _$DotaSummaryImpl;

  factory _DotaSummary.fromJson(Map<String, dynamic> json) =
      _$DotaSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'account_id')
  int get accountId;
  @override
  int get matches;
  @override
  int get wins;
  @override
  int get losses;
  @override
  double get winrate;
  @override
  @JsonKey(name: 'average_kills')
  double get averageKills;
  @override
  @JsonKey(name: 'average_deaths')
  double get averageDeaths;
  @override
  @JsonKey(name: 'average_assists')
  double get averageAssists;
  @override
  double get kda;
  @override
  @JsonKey(name: 'top_heroes')
  List<DotaHeroSummary> get topHeroes;
  @override
  @JsonKey(name: 'snapshot_id')
  int? get snapshotId;
  @override
  @JsonKey(name: 'snapshotted_at')
  DateTime? get snapshottedAt;

  /// Create a copy of DotaSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DotaSummaryImplCopyWith<_$DotaSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
