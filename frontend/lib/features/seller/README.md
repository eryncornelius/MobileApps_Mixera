# Feature: Seller

Mode penjual: dashboard, produk, pesanan, saldo/finance, notifikasi seller.

## Struktur

- **`presentation/`** — `seller_shell_page` (tab), halaman tambah/edit produk, order detail, finance, channels.
- **`data/`** — `seller_remote_datasource`.
- **`presentation/controllers/`** — `SellerController` (lazy GetX; di-reset saat login/logout lewat `AuthController`).

## Backend terkait

- Prefix: **`/api/sellers/`**.

## Catatan dev

- Setelah login (termasuk Google), pastikan instance controller seller baru agar `onInit` memuat data dengan JWT terbaru.
