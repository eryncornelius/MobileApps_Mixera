import 'package:dio/dio.dart';

import '../auth/token_refresh_helper.dart';
import '../storage/token_storage.dart';

/// Injects `Authorization: Bearer …` and on **401** refreshes the access token
/// once then retries the request (queued so concurrent calls share one refresh).
class AuthTokenInterceptor extends QueuedInterceptor {
  AuthTokenInterceptor(this._dio);

  final Dio _dio;
  static const String _retryExtraKey = '__mixera_auth_retry__';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }
    final auth = err.requestOptions.headers['Authorization'];
    if (auth == null) {
      return handler.next(err);
    }
    if (auth is String && !auth.startsWith('Bearer ')) {
      return handler.next(err);
    }
    if (err.requestOptions.extra[_retryExtraKey] == true) {
      return handler.next(err);
    }

    final ok = await TokenRefreshHelper.tryRefresh();
    if (!ok) {
      return handler.next(err);
    }
    final newAccess = await TokenStorage.getAccessToken();
    if (newAccess == null || newAccess.isEmpty) {
      return handler.next(err);
    }

    final nextHeaders = Map<String, dynamic>.from(err.requestOptions.headers);
    nextHeaders['Authorization'] = 'Bearer $newAccess';
    final nextExtra = Map<String, dynamic>.from(err.requestOptions.extra);
    nextExtra[_retryExtraKey] = true;

    final ro = err.requestOptions.copyWith(
      headers: nextHeaders,
      extra: nextExtra,
    );

    try {
      final res = await _dio.fetch(ro);
      handler.resolve(res);
    } on DioException catch (e) {
      handler.next(e);
    } catch (_) {
      handler.next(err);
    }
  }
}
