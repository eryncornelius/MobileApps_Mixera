import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central place for API host. Set `API_BASE_URL` in `.env` (no trailing slash),
/// e.g. `http://10.0.2.2:8000` for Android emulator.
class ApiBaseUrl {
  ApiBaseUrl._();

  static String get origin {
    final raw = (dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000').trim();
    if (raw.endsWith('/')) {
      return raw.substring(0, raw.length - 1);
    }
    return raw;
  }

  /// [segment] is the path after `/api/` without slashes, e.g. `users`, `shop`.
  static String module(String segment) {
    final s = segment.replaceFirst(RegExp(r'^/'), '').replaceAll(RegExp(r'/$'), '');
    return '$origin/api/$s';
  }
}
