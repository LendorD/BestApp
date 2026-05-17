import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';
import '../domain/dota_models.dart';

abstract class DotaStatsApi {
  Future<DotaPlayer> getPlayer(int accountId);

  Future<List<DotaMatch>> getMatches(int accountId);

  Future<DotaSummary> getSummary(int accountId);
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
  Future<DotaPlayer> getPlayer(int accountId) async {
    try {
      final response = await _dio.get<dynamic>('/dota/players/$accountId');
      return DotaPlayer.fromJson(unwrapData<Map<String, dynamic>>(response));
    } catch (error) {
      throw mapDioError(error);
    }
  }

  @override
  Future<List<DotaMatch>> getMatches(int accountId) async {
    try {
      final response = await _dio.get<dynamic>(
        '/dota/players/$accountId/matches',
      );
      final data = unwrapData<List<dynamic>>(response);
      return data
          .map((item) => DotaMatch.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw mapDioError(error);
    }
  }

  @override
  Future<DotaSummary> getSummary(int accountId) async {
    try {
      final response = await _dio.get<dynamic>(
        '/dota/players/$accountId/summary',
      );
      return DotaSummary.fromJson(unwrapData<Map<String, dynamic>>(response));
    } catch (error) {
      throw mapDioError(error);
    }
  }
}

class MockDotaStatsApi implements DotaStatsApi {
  static final _now = DateTime.now();

  @override
  Future<DotaPlayer> getPlayer(int accountId) async {
    await Future<void>.delayed(const Duration(milliseconds: 360));
    return DotaPlayer(
      accountId: accountId,
      personaName: 'Игрок GameMentor',
      avatarFull: '/assets/gamementor/dota/profile-fallback.jpg',
      profileUrl: 'https://www.opendota.com/players/$accountId',
      rankTier: 64,
      createdAt: _now,
      updatedAt: _now,
    );
  }

  @override
  Future<List<DotaMatch>> getMatches(int accountId) async {
    await Future<void>.delayed(const Duration(milliseconds: 520));
    return List.generate(12, (index) {
      final won = index % 3 != 0;
      return DotaMatch(
        matchId: 7900000000 + index,
        accountId: accountId,
        playerSlot: index.isEven ? 2 : 130,
        radiantWin: index.isEven ? won : !won,
        won: won,
        heroId: [1, 8, 14, 35, 74][index % 5],
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
        startTime: _now.subtract(Duration(days: index, hours: index * 2)),
      );
    });
  }

  @override
  Future<DotaSummary> getSummary(int accountId) async {
    await Future<void>.delayed(const Duration(milliseconds: 420));
    return DotaSummary(
      accountId: accountId,
      matches: 20,
      wins: 13,
      losses: 7,
      winrate: 65,
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
  }
}
