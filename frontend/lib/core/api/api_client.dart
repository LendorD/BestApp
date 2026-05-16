import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import 'api_exception.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  );
});

T unwrapData<T>(Response<dynamic> response) {
  final body = response.data;
  if (body is Map<String, dynamic>) {
    final success = body['success'] == true;
    if (success) {
      return body['data'] as T;
    }
    final error = body['error'];
    if (error is Map<String, dynamic>) {
      throw ApiException(
        error['message']?.toString() ?? 'Request failed',
        code: error['code']?.toString(),
        statusCode: response.statusCode,
      );
    }
  }
  throw ApiException(
    'Unexpected API response',
    statusCode: response.statusCode,
  );
}

ApiException mapDioError(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final apiError = data['error'];
      if (apiError is Map<String, dynamic>) {
        return ApiException(
          apiError['message']?.toString() ?? 'Request failed',
          code: apiError['code']?.toString(),
          statusCode: error.response?.statusCode,
        );
      }
    }
    return ApiException(
      error.message ?? 'Network request failed',
      statusCode: error.response?.statusCode,
    );
  }
  if (error is ApiException) {
    return error;
  }
  return ApiException(error.toString());
}
