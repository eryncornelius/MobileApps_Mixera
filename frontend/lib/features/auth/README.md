# Feature: Auth

Autentikasi pembeli: email/password, Google, Facebook; refresh token; navigasi setelah login.

## Struktur

- **`presentation/`** — halaman (`login_page`, `register_page`, `auth_gate_page`, OTP, lupa/reset password), `AuthController`, widget sosial.
- **`data/`** — `AuthRemoteDatasource` memanggil `api/users/` (login, register, Google, Facebook, refresh).

## Backend terkait

- Prefix: **`/api/users/`** — JWT (`login/`, `login/refresh/`), `google/`, `facebook/`, `register/`, `verify-otp/`, `forgot-password/`, `reset-password/`, `me/`.

## Catatan dev

- Token disimpan lewat `TokenStorage`; interceptor di `lib/core/network/`.
- Setelah login sukses, `SellerController` di-reset lewat `AuthController` agar mode seller tidak stale.
- `auth_gate_page` memuat sesi (token + opsi kunci sidik jari) lalu mengarahkan ke shell pembeli atau seller.
