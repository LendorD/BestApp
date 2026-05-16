// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'dota_models.freezed.dart';
part 'dota_models.g.dart';

@freezed
class DotaPlayer with _$DotaPlayer {
  const factory DotaPlayer({
    @JsonKey(name: 'account_id') required int accountId,
    @JsonKey(name: 'persona_name') required String personaName,
    @JsonKey(name: 'avatar_full') required String avatarFull,
    @JsonKey(name: 'profile_url') required String profileUrl,
    @JsonKey(name: 'rank_tier') int? rankTier,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _DotaPlayer;

  factory DotaPlayer.fromJson(Map<String, dynamic> json) =>
      _$DotaPlayerFromJson(json);
}

@freezed
class DotaMatch with _$DotaMatch {
  const factory DotaMatch({
    @JsonKey(name: 'match_id') required int matchId,
    @JsonKey(name: 'account_id') required int accountId,
    @JsonKey(name: 'player_slot') required int playerSlot,
    @JsonKey(name: 'radiant_win') required bool radiantWin,
    required bool won,
    @JsonKey(name: 'hero_id') required int heroId,
    required int kills,
    required int deaths,
    required int assists,
    @JsonKey(name: 'duration_seconds') required int durationSeconds,
    @JsonKey(name: 'start_time') required DateTime startTime,
  }) = _DotaMatch;

  factory DotaMatch.fromJson(Map<String, dynamic> json) =>
      _$DotaMatchFromJson(json);
}

@freezed
class DotaHeroSummary with _$DotaHeroSummary {
  const factory DotaHeroSummary({
    @JsonKey(name: 'hero_id') required int heroId,
    required int matches,
    required int wins,
    required double winrate,
  }) = _DotaHeroSummary;

  factory DotaHeroSummary.fromJson(Map<String, dynamic> json) =>
      _$DotaHeroSummaryFromJson(json);
}

@freezed
class DotaSummary with _$DotaSummary {
  const factory DotaSummary({
    @JsonKey(name: 'account_id') required int accountId,
    required int matches,
    required int wins,
    required int losses,
    required double winrate,
    @JsonKey(name: 'average_kills') required double averageKills,
    @JsonKey(name: 'average_deaths') required double averageDeaths,
    @JsonKey(name: 'average_assists') required double averageAssists,
    required double kda,
    @JsonKey(name: 'top_heroes')
    @Default(<DotaHeroSummary>[])
    List<DotaHeroSummary> topHeroes,
    @JsonKey(name: 'snapshot_id') int? snapshotId,
    @JsonKey(name: 'snapshotted_at') DateTime? snapshottedAt,
  }) = _DotaSummary;

  factory DotaSummary.fromJson(Map<String, dynamic> json) =>
      _$DotaSummaryFromJson(json);
}

class DotaAnalysis {
  const DotaAnalysis({
    required this.player,
    required this.summary,
    required this.matches,
  });

  final DotaPlayer player;
  final DotaSummary summary;
  final List<DotaMatch> matches;
}
