// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dota_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DotaPlayerImpl _$$DotaPlayerImplFromJson(Map<String, dynamic> json) =>
    _$DotaPlayerImpl(
      accountId: (json['account_id'] as num).toInt(),
      personaName: json['persona_name'] as String,
      avatarFull: json['avatar_full'] as String,
      profileUrl: json['profile_url'] as String,
      rankTier: (json['rank_tier'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$DotaPlayerImplToJson(_$DotaPlayerImpl instance) =>
    <String, dynamic>{
      'account_id': instance.accountId,
      'persona_name': instance.personaName,
      'avatar_full': instance.avatarFull,
      'profile_url': instance.profileUrl,
      'rank_tier': instance.rankTier,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_$DotaMatchImpl _$$DotaMatchImplFromJson(Map<String, dynamic> json) =>
    _$DotaMatchImpl(
      matchId: (json['match_id'] as num).toInt(),
      accountId: (json['account_id'] as num).toInt(),
      playerSlot: (json['player_slot'] as num).toInt(),
      radiantWin: json['radiant_win'] as bool,
      won: json['won'] as bool,
      heroId: (json['hero_id'] as num).toInt(),
      kills: (json['kills'] as num).toInt(),
      deaths: (json['deaths'] as num).toInt(),
      assists: (json['assists'] as num).toInt(),
      durationSeconds: (json['duration_seconds'] as num).toInt(),
      startTime: DateTime.parse(json['start_time'] as String),
    );

Map<String, dynamic> _$$DotaMatchImplToJson(_$DotaMatchImpl instance) =>
    <String, dynamic>{
      'match_id': instance.matchId,
      'account_id': instance.accountId,
      'player_slot': instance.playerSlot,
      'radiant_win': instance.radiantWin,
      'won': instance.won,
      'hero_id': instance.heroId,
      'kills': instance.kills,
      'deaths': instance.deaths,
      'assists': instance.assists,
      'duration_seconds': instance.durationSeconds,
      'start_time': instance.startTime.toIso8601String(),
    };

_$DotaHeroSummaryImpl _$$DotaHeroSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$DotaHeroSummaryImpl(
  heroId: (json['hero_id'] as num).toInt(),
  matches: (json['matches'] as num).toInt(),
  wins: (json['wins'] as num).toInt(),
  winrate: (json['winrate'] as num).toDouble(),
);

Map<String, dynamic> _$$DotaHeroSummaryImplToJson(
  _$DotaHeroSummaryImpl instance,
) => <String, dynamic>{
  'hero_id': instance.heroId,
  'matches': instance.matches,
  'wins': instance.wins,
  'winrate': instance.winrate,
};

_$DotaSummaryImpl _$$DotaSummaryImplFromJson(Map<String, dynamic> json) =>
    _$DotaSummaryImpl(
      accountId: (json['account_id'] as num).toInt(),
      matches: (json['matches'] as num).toInt(),
      wins: (json['wins'] as num).toInt(),
      losses: (json['losses'] as num).toInt(),
      winrate: (json['winrate'] as num).toDouble(),
      averageKills: (json['average_kills'] as num).toDouble(),
      averageDeaths: (json['average_deaths'] as num).toDouble(),
      averageAssists: (json['average_assists'] as num).toDouble(),
      kda: (json['kda'] as num).toDouble(),
      topHeroes:
          (json['top_heroes'] as List<dynamic>?)
              ?.map((e) => DotaHeroSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <DotaHeroSummary>[],
      snapshotId: (json['snapshot_id'] as num?)?.toInt(),
      snapshottedAt: json['snapshotted_at'] == null
          ? null
          : DateTime.parse(json['snapshotted_at'] as String),
    );

Map<String, dynamic> _$$DotaSummaryImplToJson(_$DotaSummaryImpl instance) =>
    <String, dynamic>{
      'account_id': instance.accountId,
      'matches': instance.matches,
      'wins': instance.wins,
      'losses': instance.losses,
      'winrate': instance.winrate,
      'average_kills': instance.averageKills,
      'average_deaths': instance.averageDeaths,
      'average_assists': instance.averageAssists,
      'kda': instance.kda,
      'top_heroes': instance.topHeroes,
      'snapshot_id': instance.snapshotId,
      'snapshotted_at': instance.snapshottedAt?.toIso8601String(),
    };
