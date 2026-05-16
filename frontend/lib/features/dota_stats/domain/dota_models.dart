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
    @JsonKey(name: 'gold_per_min') @Default(0) int goldPerMin,
    @JsonKey(name: 'xp_per_min') @Default(0) int xpPerMin,
    @JsonKey(name: 'last_hits') @Default(0) int lastHits,
    @JsonKey(name: 'hero_damage') @Default(0) int heroDamage,
    @JsonKey(name: 'tower_damage') @Default(0) int towerDamage,
    @JsonKey(name: 'hero_healing') @Default(0) int heroHealing,
    @JsonKey(name: 'average_rank') int? averageRank,
    @JsonKey(name: 'party_size') int? partySize,
    @JsonKey(name: 'game_mode') @Default(0) int gameMode,
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

enum DotaStatsPeriod {
  recent('Последние матчи', null),
  week('7 дней', Duration(days: 7)),
  month('30 дней', Duration(days: 30)),
  quarter('90 дней', Duration(days: 90));

  const DotaStatsPeriod(this.label, this.duration);

  final String label;
  final Duration? duration;
}

class DotaComputedStats {
  const DotaComputedStats({
    required this.period,
    required this.matches,
    required this.wins,
    required this.losses,
    required this.winrate,
    required this.averageKills,
    required this.averageDeaths,
    required this.averageAssists,
    required this.kda,
    required this.averageGpm,
    required this.averageXpm,
    required this.averageLastHits,
    required this.averageHeroDamage,
    required this.averageTowerDamage,
    required this.averageHeroHealing,
    required this.averageDurationMinutes,
    required this.topHeroes,
    required this.filteredMatches,
  });

  final DotaStatsPeriod period;
  final int matches;
  final int wins;
  final int losses;
  final double winrate;
  final double averageKills;
  final double averageDeaths;
  final double averageAssists;
  final double kda;
  final double averageGpm;
  final double averageXpm;
  final double averageLastHits;
  final double averageHeroDamage;
  final double averageTowerDamage;
  final double averageHeroHealing;
  final double averageDurationMinutes;
  final List<DotaHeroSummary> topHeroes;
  final List<DotaMatch> filteredMatches;

  static DotaComputedStats fromMatches(
    List<DotaMatch> source,
    DotaStatsPeriod period,
  ) {
    final now = DateTime.now();
    final cutoff = period.duration == null
        ? null
        : now.subtract(period.duration!);
    final matches = cutoff == null
        ? source
        : source.where((match) => match.startTime.isAfter(cutoff)).toList();
    final total = matches.length;

    if (total == 0) {
      return DotaComputedStats(
        period: period,
        matches: 0,
        wins: 0,
        losses: 0,
        winrate: 0,
        averageKills: 0,
        averageDeaths: 0,
        averageAssists: 0,
        kda: 0,
        averageGpm: 0,
        averageXpm: 0,
        averageLastHits: 0,
        averageHeroDamage: 0,
        averageTowerDamage: 0,
        averageHeroHealing: 0,
        averageDurationMinutes: 0,
        topHeroes: const [],
        filteredMatches: const [],
      );
    }

    var wins = 0;
    var kills = 0;
    var deaths = 0;
    var assists = 0;
    var gpm = 0;
    var xpm = 0;
    var lastHits = 0;
    var heroDamage = 0;
    var towerDamage = 0;
    var heroHealing = 0;
    var duration = 0;
    final heroStats = <int, ({int matches, int wins})>{};

    for (final match in matches) {
      if (match.won) wins++;
      kills += match.kills;
      deaths += match.deaths;
      assists += match.assists;
      gpm += match.goldPerMin;
      xpm += match.xpPerMin;
      lastHits += match.lastHits;
      heroDamage += match.heroDamage;
      towerDamage += match.towerDamage;
      heroHealing += match.heroHealing;
      duration += match.durationSeconds;

      final current = heroStats[match.heroId] ?? (matches: 0, wins: 0);
      heroStats[match.heroId] = (
        matches: current.matches + 1,
        wins: current.wins + (match.won ? 1 : 0),
      );
    }

    final topHeroes =
        heroStats.entries.map((entry) {
          return DotaHeroSummary(
            heroId: entry.key,
            matches: entry.value.matches,
            wins: entry.value.wins,
            winrate: _percent(entry.value.wins, entry.value.matches),
          );
        }).toList()..sort((a, b) {
          final byMatches = b.matches.compareTo(a.matches);
          if (byMatches != 0) return byMatches;
          return b.winrate.compareTo(a.winrate);
        });

    return DotaComputedStats(
      period: period,
      matches: total,
      wins: wins,
      losses: total - wins,
      winrate: _percent(wins, total),
      averageKills: _average(kills, total),
      averageDeaths: _average(deaths, total),
      averageAssists: _average(assists, total),
      kda: deaths == 0
          ? (kills + assists).toDouble()
          : _round2((kills + assists) / deaths),
      averageGpm: _average(gpm, total),
      averageXpm: _average(xpm, total),
      averageLastHits: _average(lastHits, total),
      averageHeroDamage: _average(heroDamage, total),
      averageTowerDamage: _average(towerDamage, total),
      averageHeroHealing: _average(heroHealing, total),
      averageDurationMinutes: _average(duration, total) / 60,
      topHeroes: topHeroes.take(5).toList(),
      filteredMatches: matches,
    );
  }
}

double _average(num total, int count) {
  if (count == 0) return 0;
  return _round2(total / count);
}

double _percent(int value, int total) {
  if (total == 0) return 0;
  return _round2(value / total * 100);
}

double _round2(num value) => (value * 100).roundToDouble() / 100;
