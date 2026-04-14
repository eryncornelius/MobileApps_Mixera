/// Thrown when `/me/` returns 401 (access JWT expired or invalid).
class SessionUnauthorizedException implements Exception {
  const SessionUnauthorizedException();
}
