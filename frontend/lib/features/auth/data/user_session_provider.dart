import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/user_models.dart';
import 'auth_api.dart';

const _sessionUserIdKey = 'gamementor.session.user_id';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final userSessionProvider =
    AsyncNotifierProvider<UserSessionNotifier, UserProfile?>(
      UserSessionNotifier.new,
    );

class UserSessionNotifier extends AsyncNotifier<UserProfile?> {
  @override
  FutureOr<UserProfile?> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    final userId = prefs.getInt(_sessionUserIdKey);
    if (userId == null) {
      return null;
    }

    try {
      return await ref.watch(authApiProvider).getProfile(userId);
    } catch (_) {
      await prefs.remove(_sessionUserIdKey);
      return null;
    }
  }

  Future<UserProfile> register(RegisterUserRequest request) async {
    return _runAuthAction(() => ref.read(authApiProvider).register(request));
  }

  Future<UserProfile> login(LoginUserRequest request) async {
    return _runAuthAction(() => ref.read(authApiProvider).login(request));
  }

  Future<UserProfile> updateProfile(UpdateUserProfileRequest request) async {
    final current = state.valueOrNull;
    if (current == null) {
      throw StateError('Профиль не найден');
    }

    state = const AsyncLoading<UserProfile?>().copyWithPrevious(state);
    try {
      final user = await ref
          .read(authApiProvider)
          .updateProfile(current.id, request);
      state = AsyncData(user);
      return user;
    } catch (error, stackTrace) {
      state = AsyncError<UserProfile?>(
        error,
        stackTrace,
      ).copyWithPrevious(state);
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.remove(_sessionUserIdKey);
    state = const AsyncData(null);
  }

  Future<UserProfile> _runAuthAction(
    Future<UserProfile> Function() action,
  ) async {
    state = const AsyncLoading<UserProfile?>();
    try {
      final user = await action();
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setInt(_sessionUserIdKey, user.id);
      state = AsyncData(user);
      return user;
    } catch (error, stackTrace) {
      state = AsyncError<UserProfile?>(error, stackTrace);
      rethrow;
    }
  }
}
