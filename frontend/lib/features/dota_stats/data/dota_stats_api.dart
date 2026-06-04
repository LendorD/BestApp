import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';
import '../domain/dota_models.dart';

abstract class DotaStatsApi {
  Future<DotaAnalysis> getAnalysis(
    int accountId, {
    String period = 'all',
    String role = 'all',
  });
}

final dotaStatsApiProvider = Provider<DotaStatsApi>((ref) {
  if (AppConfig.useMockApi) {
    return MockDotaStatsApi();
  }
  return HttpDotaStatsApi(ref.watch(dioProvider));
});

class HttpDotaStatsApi implements DotaStatsApi {
  const HttpDotaStatsApi(this._dio);

  final Dio _dio;

  @override
  Future<DotaAnalysis> getAnalysis(
    int accountId, {
    String period = 'all',
    String role = 'all',
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/dota/lab/players/$accountId/dashboard',
        queryParameters: {'period': period, 'role': role},
      );
      final dashboard = unwrapData<Map<String, dynamic>>(response);
      return DotaAnalysis(
        player: _playerFromDashboardJson(accountId, dashboard),
        summary: _summaryFromDashboardJson(accountId, dashboard),
        matches: _matchesFromDashboardJson(accountId, dashboard),
      );
    } catch (error) {
      throw mapDioError(error);
    }
  }
}

DotaPlayer _playerFromDashboardJson(int accountId, Map<String, dynamic> json) {
  final player = json['player'] as Map<String, dynamic>? ?? const {};
  return DotaPlayer(
    accountId: (player['account_id'] as num?)?.toInt() ?? accountId,
    personaName: player['persona_name'] as String? ?? 'Игрок $accountId',
    avatarFull:
        player['avatar_full'] as String? ??
        '/assets/gamementor/dota/profile-fallback.jpg',
    profileUrl:
        player['profile_url'] as String? ??
        'https://www.opendota.com/players/$accountId',
    rankTier: (player['rank_tier'] as num?)?.toInt(),
    updatedAt: DateTime.tryParse('${json['generated_at']}'),
  );
}

DotaSummary _summaryFromDashboardJson(
  int accountId,
  Map<String, dynamic> json,
) {
  final summary = json['summary'] as Map<String, dynamic>? ?? const {};
  final heroPerformance =
      json['hero_performance'] as Map<String, dynamic>? ?? const {};
  final bestHeroes = heroPerformance['best'] as List<dynamic>? ?? const [];

  return DotaSummary(
    accountId: accountId,
    matches: (summary['matches'] as num?)?.toInt() ?? 0,
    wins: (summary['wins'] as num?)?.toInt() ?? 0,
    losses: (summary['losses'] as num?)?.toInt() ?? 0,
    winrate: (summary['winrate'] as num?)?.toDouble() ?? 0,
    averageKills: (summary['average_kills'] as num?)?.toDouble() ?? 0,
    averageDeaths: (summary['average_deaths'] as num?)?.toDouble() ?? 0,
    averageAssists: (summary['average_assists'] as num?)?.toDouble() ?? 0,
    kda: (summary['average_kda'] as num?)?.toDouble() ?? 0,
    topHeroes: [
      for (final item in bestHeroes)
        if (item is Map<String, dynamic>)
          DotaHeroSummary(
            heroId: (item['hero_id'] as num?)?.toInt() ?? 0,
            matches: (item['matches'] as num?)?.toInt() ?? 0,
            wins: (item['wins'] as num?)?.toInt() ?? 0,
            winrate: (item['winrate'] as num?)?.toDouble() ?? 0,
          ),
    ],
    snapshottedAt: DateTime.tryParse('${json['generated_at']}'),
  );
}

List<DotaMatch> _matchesFromDashboardJson(
  int accountId,
  Map<String, dynamic> json,
) {
  final matches = json['matches'] as List<dynamic>? ?? const [];
  return [
    for (final item in matches)
      if (item is Map<String, dynamic>)
        _matchFromDashboardJson(accountId, item),
  ];
}

DotaMatch _matchFromDashboardJson(int accountId, Map<String, dynamic> json) {
  final matchId = json['match_id'];
  final won = json['won'] as bool? ?? false;
  return DotaMatch(
    matchId: matchId is int ? matchId : int.tryParse('$matchId') ?? 0,
    accountId: (json['account_id'] as num?)?.toInt() ?? accountId,
    playerSlot: (json['player_slot'] as num?)?.toInt() ?? 0,
    radiantWin: json['radiant_win'] as bool? ?? won,
    won: won,
    heroId: (json['hero_id'] as num?)?.toInt() ?? 0,
    kills: (json['kills'] as num?)?.toInt() ?? 0,
    deaths: (json['deaths'] as num?)?.toInt() ?? 0,
    assists: (json['assists'] as num?)?.toInt() ?? 0,
    goldPerMin: (json['gold_per_min'] as num?)?.toInt() ?? 0,
    xpPerMin: (json['xp_per_min'] as num?)?.toInt() ?? 0,
    lastHits: (json['last_hits'] as num?)?.toInt() ?? 0,
    heroDamage: (json['hero_damage'] as num?)?.toInt() ?? 0,
    towerDamage: (json['tower_damage'] as num?)?.toInt() ?? 0,
    heroHealing: (json['hero_healing'] as num?)?.toInt() ?? 0,
    averageRank: (json['average_rank'] as num?)?.toInt(),
    partySize: (json['party_size'] as num?)?.toInt(),
    gameMode: (json['game_mode'] as num?)?.toInt() ?? 0,
    durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
    startTime: DateTime.tryParse('${json['start_time']}') ?? DateTime.now(),
  );
}

class MockDotaStatsApi implements DotaStatsApi {
  static final _now = DateTime.now();

  @override
  Future<DotaAnalysis> getAnalysis(
    int accountId, {
    String period = 'all',
    String role = 'all',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 520));
    final player = DotaPlayer(
      accountId: accountId,
      personaName: 'Игрок GameMentor',
      avatarFull: '/assets/gamementor/dota/profile-fallback.jpg',
      profileUrl: 'https://www.opendota.com/players/$accountId',
      rankTier: 64,
      createdAt: _now,
      updatedAt: _now,
    );
    final matches = List.generate(28, (index) {
      final won = index % 4 != 0 && index % 9 != 0;
      final heroIds = [1, 8, 14, 35, 74, 41, 39, 21];
      final dayOffset = index < 10 ? index : 10 + (index - 10) * 3;
      return DotaMatch(
        matchId: 7900000000 + index,
        accountId: accountId,
        playerSlot: index.isEven ? 2 : 130,
        radiantWin: index.isEven ? won : !won,
        won: won,
        heroId: heroIds[index % heroIds.length],
        kills: 4 + (index * 2) % 14,
        deaths: 2 + index % 8,
        assists: 7 + (index * 3) % 18,
        goldPerMin: 420 + (index * 37) % 260,
        xpPerMin: 510 + (index * 41) % 310,
        lastHits: 80 + (index * 23) % 220,
        heroDamage: 9000 + index * 1450,
        towerDamage: index.isEven ? 1200 + index * 320 : index * 90,
        heroHealing: index % 4 == 0 ? 2800 + index * 140 : 0,
        averageRank: 65,
        partySize: index % 3 == 0 ? 2 : null,
        gameMode: 22,
        durationSeconds: 1850 + index * 73,
        startTime: _now.subtract(Duration(days: dayOffset, hours: index * 2)),
      );
    });
    final summary = DotaSummary(
      accountId: accountId,
      matches: 28,
      wins: 18,
      losses: 10,
      winrate: 64.3,
      averageKills: 9.4,
      averageDeaths: 5.7,
      averageAssists: 16.2,
      kda: 4.49,
      topHeroes: const [
        DotaHeroSummary(heroId: 35, matches: 7, wins: 5, winrate: 71.4),
        DotaHeroSummary(heroId: 8, matches: 5, wins: 4, winrate: 80),
        DotaHeroSummary(heroId: 74, matches: 4, wins: 2, winrate: 50),
      ],
      snapshotId: 101,
      snapshottedAt: DateTime(2026, 5, 16, 12),
    );
    return DotaAnalysis(player: player, summary: summary, matches: matches);
  }
}
