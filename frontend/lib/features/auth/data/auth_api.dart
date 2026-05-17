import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/config/app_config.dart';
import '../domain/user_models.dart';

abstract class AuthApi {
  Future<UserProfile> register(RegisterUserRequest request);

  Future<UserProfile> login(LoginUserRequest request);

  Future<UserProfile> getProfile(int userId);

  Future<UserProfile> updateProfile(
    int userId,
    UpdateUserProfileRequest request,
  );
}

final authApiProvider = Provider<AuthApi>((ref) {
  if (AppConfig.useMockApi) {
    return MockAuthApi();
  }
  return HttpAuthApi(ref.watch(dioProvider));
});

class HttpAuthApi implements AuthApi {
  const HttpAuthApi(this._dio);

  final Dio _dio;

  @override
  Future<UserProfile> register(RegisterUserRequest request) async {
    try {
      final response = await _dio.post<dynamic>(
        '/auth/register',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(
        unwrapData<Map<String, dynamic>>(response),
      ).user;
    } catch (error) {
      throw mapDioError(error);
    }
  }

  @override
  Future<UserProfile> login(LoginUserRequest request) async {
    try {
      final response = await _dio.post<dynamic>(
        '/auth/login',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(
        unwrapData<Map<String, dynamic>>(response),
      ).user;
    } catch (error) {
      throw mapDioError(error);
    }
  }

  @override
  Future<UserProfile> getProfile(int userId) async {
    try {
      final response = await _dio.get<dynamic>('/users/$userId/profile');
      return UserProfile.fromJson(unwrapData<Map<String, dynamic>>(response));
    } catch (error) {
      throw mapDioError(error);
    }
  }

  @override
  Future<UserProfile> updateProfile(
    int userId,
    UpdateUserProfileRequest request,
  ) async {
    try {
      final response = await _dio.put<dynamic>(
        '/users/$userId/profile',
        data: request.toJson(),
      );
      return UserProfile.fromJson(unwrapData<Map<String, dynamic>>(response));
    } catch (error) {
      throw mapDioError(error);
    }
  }
}

class MockAuthApi implements AuthApi {
  static const _password = '123456';
  static UserProfile? _user;

  @override
  Future<UserProfile> register(RegisterUserRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 360));
    if (request.password.length < 6) {
      throw const ApiException('Пароль должен быть не короче 6 символов');
    }
    final now = DateTime.now();
    _user = UserProfile(
      id: 1,
      email: request.email.trim().toLowerCase(),
      username: request.username.trim().toLowerCase(),
      displayName: request.displayName.trim().isEmpty
          ? request.username.trim()
          : request.displayName.trim(),
      avatarUrl: '/assets/gamementor/dota/profile-fallback.jpg',
      bio: 'Тренирую раскидки CS2 и разбираю решения в Dota 2.',
      favoriteGame: 'CS2 + Dota 2',
      dotaAccountId: 369102305,
      createdAt: now,
      updatedAt: now,
    );
    return _user!;
  }

  @override
  Future<UserProfile> login(LoginUserRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (_user == null) {
      await register(
        RegisterUserRequest(
          email: 'demo@gamementor.local',
          username: 'demo',
          password: _password,
          displayName: 'Demo Player',
        ),
      );
    }
    if (request.password != _password) {
      throw const ApiException('Неверный email или пароль');
    }
    return _user!;
  }

  @override
  Future<UserProfile> getProfile(int userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (_user == null || _user!.id != userId) {
      throw const ApiException('Профиль не найден', code: 'not_found');
    }
    return _user!;
  }

  @override
  Future<UserProfile> updateProfile(
    int userId,
    UpdateUserProfileRequest request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    final current = await getProfile(userId);
    _user = current.copyWith(
      displayName: request.displayName,
      avatarUrl: request.avatarUrl,
      bio: request.bio,
      favoriteGame: request.favoriteGame,
      dotaAccountId: request.dotaAccountId,
      updatedAt: DateTime.now(),
    );
    return _user!;
  }
}
