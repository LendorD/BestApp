import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/config/app_config.dart';
import '../domain/cs2_models.dart';

abstract class Cs2GrenadesApi {
  Future<List<CS2Map>> getMaps();

  Future<List<CS2Grenade>> getGrenades({
    String? map,
    String? side,
    String? type,
    String? difficulty,
  });

  Future<CS2Grenade> getGrenade(int id);

  Future<CS2Grenade> createGrenade(CreateCS2GrenadeRequest request);
}

final cs2GrenadesApiProvider = Provider<Cs2GrenadesApi>((ref) {
  if (AppConfig.useMockApi) {
    return MockCs2GrenadesApi();
  }
  return HttpCs2GrenadesApi(ref.watch(dioProvider));
});

class HttpCs2GrenadesApi implements Cs2GrenadesApi {
  const HttpCs2GrenadesApi(this._dio);

  final Dio _dio;

  @override
  Future<List<CS2Map>> getMaps() async {
    try {
      final response = await _dio.get<dynamic>('/cs2/maps');
      final data = unwrapData<List<dynamic>>(response);
      return data
          .map((item) => CS2Map.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw mapDioError(error);
    }
  }

  @override
  Future<List<CS2Grenade>> getGrenades({
    String? map,
    String? side,
    String? type,
    String? difficulty,
  }) async {
    try {
      final query = <String, dynamic>{
        if (map != null && map.isNotEmpty) 'map': map,
        if (side != null && side.isNotEmpty) 'side': side,
        if (type != null && type.isNotEmpty) 'type': type,
        if (difficulty != null && difficulty.isNotEmpty)
          'difficulty': difficulty,
      };
      final response = await _dio.get<dynamic>(
        '/cs2/grenades',
        queryParameters: query,
      );
      final data = unwrapData<List<dynamic>>(response);
      return data
          .map((item) => CS2Grenade.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw mapDioError(error);
    }
  }

  @override
  Future<CS2Grenade> getGrenade(int id) async {
    try {
      final response = await _dio.get<dynamic>('/cs2/grenades/$id');
      return CS2Grenade.fromJson(unwrapData<Map<String, dynamic>>(response));
    } catch (error) {
      throw mapDioError(error);
    }
  }

  @override
  Future<CS2Grenade> createGrenade(CreateCS2GrenadeRequest request) async {
    try {
      final response = await _dio.post<dynamic>(
        '/cs2/grenades',
        data: request.toJson(),
      );
      return CS2Grenade.fromJson(unwrapData<Map<String, dynamic>>(response));
    } catch (error) {
      throw mapDioError(error);
    }
  }
}

class MockCs2GrenadesApi implements Cs2GrenadesApi {
  static final _now = DateTime.now();
  static final List<CS2Map> _maps = [
    for (final entry in const [
      ('mirage', 'Mirage'),
      ('inferno', 'Inferno'),
      ('dust2', 'Dust2'),
      ('nuke', 'Nuke'),
      ('ancient', 'Ancient'),
      ('anubis', 'Anubis'),
      ('vertigo', 'Vertigo'),
    ].indexed)
      CS2Map(
        id: entry.$1 + 1,
        code: entry.$2.$1,
        displayName: entry.$2.$2,
        createdAt: _now,
        updatedAt: _now,
      ),
  ];

  static final List<CS2Grenade> _grenades = [
    CS2Grenade(
      id: 1,
      map: 'mirage',
      side: 'T',
      type: 'smoke',
      title: 'Смок Window с T spawn',
      description: 'Стабильный смок для раннего контроля мида.',
      fromPosition: 'T spawn',
      toPosition: 'Window',
      difficulty: 'easy',
      imageUrl: '/assets/gamementor/cs2/grenades/mirage-window-smoke.jpg',
      videoUrl: 'https://example.com/mirage-window-smoke',
      tags: ['mid', 'default', 'execute'],
      createdAt: _now,
      updatedAt: _now,
    ),
    CS2Grenade(
      id: 2,
      map: 'inferno',
      side: 'T',
      type: 'flash',
      title: 'Pop flash на Banana',
      description: 'Высокая флешка под выход и давление на close banana.',
      fromPosition: 'T ramp',
      toPosition: 'Top banana',
      difficulty: 'medium',
      imageUrl: '/assets/gamementor/cs2/grenades/inferno-banana-flash.jpg',
      videoUrl: 'https://example.com/inferno-banana-flash',
      tags: ['banana', 'entry', 'flash'],
      createdAt: _now,
      updatedAt: _now,
    ),
    CS2Grenade(
      id: 3,
      map: 'nuke',
      side: 'T',
      type: 'molotov',
      title: 'Молотов для зачистки Hut',
      description: 'Выгоняет игрока из hut и помогает безопасно выйти на A.',
      fromPosition: 'Lobby',
      toPosition: 'Hut',
      difficulty: 'easy',
      imageUrl: '/assets/gamementor/cs2/grenades/nuke-hut-molotov.jpg',
      videoUrl: 'https://example.com/nuke-hut-molly',
      tags: ['a-site', 'lobby', 'clear'],
      createdAt: _now,
      updatedAt: _now,
    ),
    CS2Grenade(
      id: 4,
      map: 'anubis',
      side: 'CT',
      type: 'he',
      title: 'Тайминговая HE в B main',
      description:
          'Наказывает быстрый выход B main, особенно вместе с lane flash.',
      fromPosition: 'B connector',
      toPosition: 'B main',
      difficulty: 'hard',
      imageUrl: '/assets/gamementor/cs2/grenades/anubis-b-main-he.jpg',
      videoUrl: 'https://example.com/anubis-b-main-he',
      tags: ['anti-rush', 'b-site', 'damage'],
      createdAt: _now,
      updatedAt: _now,
    ),
  ];

  @override
  Future<List<CS2Map>> getMaps() async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    return _maps;
  }

  @override
  Future<List<CS2Grenade>> getGrenades({
    String? map,
    String? side,
    String? type,
    String? difficulty,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 420));
    return _grenades.where((grenade) {
      return (map == null || map.isEmpty || grenade.map == map) &&
          (side == null || side.isEmpty || grenade.side == side) &&
          (type == null || type.isEmpty || grenade.type == type) &&
          (difficulty == null ||
              difficulty.isEmpty ||
              grenade.difficulty == difficulty);
    }).toList();
  }

  @override
  Future<CS2Grenade> getGrenade(int id) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _grenades.firstWhere(
      (grenade) => grenade.id == id,
      orElse: () =>
          throw const ApiException('Grenade not found', code: 'not_found'),
    );
  }

  @override
  Future<CS2Grenade> createGrenade(CreateCS2GrenadeRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final grenade = CS2Grenade(
      id:
          (_grenades.map((item) => item.id).reduce((a, b) => a > b ? a : b)) +
          1,
      map: request.map,
      side: request.side,
      type: request.type,
      title: request.title,
      description: request.description,
      fromPosition: request.fromPosition,
      toPosition: request.toPosition,
      difficulty: request.difficulty,
      imageUrl: request.imageUrl,
      videoUrl: request.videoUrl,
      tags: request.tags,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _grenades.insert(0, grenade);
    return grenade;
  }
}
