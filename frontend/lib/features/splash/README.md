# Feature: Splash

Layar pembuka awal aplikasi (branding / transisi singkat) sebelum masuk ke auth gate atau login.

## Struktur

- **`presentation/`** — `splash_page` dan widget terkait.

## Backend terkait

- Tidak wajib memanggil API; bila ada preflight ringan, jangan blokir navigasi terlalu lama.

## Catatan dev

- Alur navigasi lanjutan ditentukan oleh `app_router` / initial route setelah splash.
