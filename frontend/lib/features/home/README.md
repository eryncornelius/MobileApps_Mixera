# Feature: Home

Beranda pembeli setelah login: sapaan, rekomendasi, promo, pratinjau wardrobe, aksi cepat.

## Struktur

- **`presentation/`** — `home_page`, widget section, `HomeController`.
- **`data/`** — datasource dashboard/rekomendasi, model banner & dashboard.
- **`domain/`** — use case / repository abstrak (bila dipakai).

## Backend terkait

- Data umumnya dari **`/api/users/`** atau modul shop/wardrobe tergantung endpoint yang dipanggil `HomeRemoteDatasource` (cek file datasource).

## Catatan dev

- Ini entry utama tab beranda di `main_shell`; jangan taruh logika berat blocking di `build()`.
