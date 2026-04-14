# Feature: Notifications

Daftar notifikasi in-app untuk user (baca/belum dibaca), integrasi dengan pengaturan notifikasi profil.

## Struktur

- **`presentation/`** — halaman daftar notifikasi, tile, `NotificationsController`.
- **`data/`** — model item notifikasi, datasource.

## Backend terkait

- Prefix: **`/api/users/`** — path `notifications/`, `notifications/read/`, `notifications/unread-count/` (sesuai backend).

## Catatan dev

- Push FCM terpisah di `lib/core/services/fcm_service.dart`; halaman ini untuk notifikasi yang di-fetch dari API.
