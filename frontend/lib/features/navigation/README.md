# Feature: Navigation

Shell aplikasi pembeli: bottom navigation dan komposisi tab utama (home, shop, cart, profil, dsb. sesuai router).

## Struktur

- **`presentation/`** — widget navbar / shell yang membungkus halaman fitur lain.

## Backend terkait

- Tidak memanggil API langsung; hanya routing & layout.

## Catatan dev

- Rute named ada di `lib/app/routes/`; sesuaikan index tab dengan `app_router` / `RouteNames`.
