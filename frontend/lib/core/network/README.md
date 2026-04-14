# Networking (Mixera Flutter)

## Base URL

- Set **`API_BASE_URL`** in `frontend/.env` (host only, no trailing slash), e.g. `http://10.0.2.2:8000` for Android emulator.
- Use **`ApiBaseUrl.module('users')`**, **`ApiBaseUrl.module('payments')`**, etc., for Dio `baseUrl`.

## Authenticated API calls

- Use **`createAuthenticatedDio(baseUrl: ApiBaseUrl.module('…'))`** for any endpoint that requires JWT.
- The **`AuthTokenInterceptor`** attaches `Authorization: Bearer <access>` and on **401** calls **`TokenRefreshHelper.tryRefresh()`** then retries the request **once** (queued so parallel requests do not stampede refresh).

## Unauthenticated calls (login, register, refresh)

- Keep a **plain `Dio`** without `AuthTokenInterceptor` in **`AuthRemoteDatasource`** so login/register are not forced to send a stale Bearer token.

## Cold start vs in-session

- **`AuthGatePage`** still refreshes on `SessionUnauthorizedException` when validating `/me/` after splash.
- In-session API calls rely on the **interceptor** so short access tokens do not feel like random logouts.

## Backend

- JWT lifetimes live in Django **`SIMPLE_JWT`** (`JWT_ACCESS_MINUTES`, `JWT_REFRESH_DAYS` in `.env`).
