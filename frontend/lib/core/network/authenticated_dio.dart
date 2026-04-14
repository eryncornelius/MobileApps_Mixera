import 'package:dio/dio.dart';

import 'auth_token_interceptor.dart';

/// Dio for **authenticated** Mixera API modules. Do **not** use for
/// `/login/`, `/register/`, `/login/refresh/` — use a plain [Dio] there.
Dio createAuthenticatedDio({
  required String baseUrl,
  Duration connectTimeout = const Duration(seconds: 15),
  Duration receiveTimeout = const Duration(seconds: 15),
  Duration? sendTimeout,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  dio.interceptors.add(AuthTokenInterceptor(dio));
  return dio;
}
